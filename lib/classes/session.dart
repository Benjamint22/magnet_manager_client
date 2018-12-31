import 'requester.dart';
import 'service.dart';

const String base_url = "https://benjamintaillon.com:25569";
const Duration timeoutDuration = Duration(seconds: 8);

class BadLoginException implements Exception {}
class BadPasswordException implements Exception {}
class InvalidKeyException implements Exception {}
class TimeoutException implements Exception {}
class InvalidServiceException implements Exception {}
class InternalServerError implements Exception {
  final String _message;
  String get message => _message;
  InternalServerError({message}) : _message = message;
}

class Session {
  String _key;
  String _username;

  String get username => _username;

  Session(String key, String username) : _key = key, _username = username;

  Future<List<Service>> listServices() async {
    Response response = await Requester.post(
      "$base_url/services/list",
      {
        "key": _key,
      },
      true,
    ).timeout(timeoutDuration, onTimeout: () => throw TimeoutException());
    switch (response.statusCode) {
      case 403:
        throw InvalidKeyException();
      case 200:
        break;
      default:
        throw FallThroughError();
    }
    List<Service> services = <Service>[];
    for (dynamic jsonService in response.jsonBody) {
      services.add(Service.fromJSON(jsonService));
    }
    return services;
  }

  Future<void> executeAction(Service service, ServiceAction action) async {
    String strAction;
    switch (action) {
      case ServiceAction.START:
        strAction = "start";
        break;
      case ServiceAction.STOP:
        strAction = "stop";
        break;
      case ServiceAction.RESTART:
        strAction = "restart";
        break;
    }
    Response response = await Requester.post(
      "$base_url/services/$strAction",
      {
        "key": _key,
        "serviceName": service.name,
      },
      true,
    ).timeout(timeoutDuration, onTimeout: () => throw TimeoutException());
    switch (response.statusCode) {
      case 403:
        throw InvalidKeyException();
      case 404:
        throw InvalidServiceException();
      case 500:
        throw InternalServerError(
          message: response.body
        );
      case 200:
        break;
      default:
        throw FallThroughError();
    }
  }

  Future<ServiceStatus> getStatus(Service service) async {
    Response response = await Requester.post(
      "$base_url/services/status",
      {
        "key": _key,
        "serviceName": service.name,
      },
      true,
    ).timeout(timeoutDuration, onTimeout: () => throw TimeoutException());
    switch (response.statusCode) {
      case 403:
        throw InvalidKeyException();
      case 404:
        throw InvalidServiceException();
      case 200:
        break;
      default:
        throw FallThroughError();
    }
    return Service.statusFromString(response.body.toString().trimRight());
  }

  static Future<Session> login(String login, String password) async {
    Response response = await Requester.post(
      "$base_url/login", 
      {
        "login": login,
        "password": password,
      }, 
      true,
    ).timeout(timeoutDuration, onTimeout: () => throw TimeoutException());
    if (response.statusCode == 401) {
      if (response.body == "login")
        throw BadLoginException();
      else if (response.body == "password")
        throw BadPasswordException();
      else
        throw FallThroughError();
    } else if (response.statusCode == 200) {
      return Session(response.jsonBody["key"], login);
    }
    throw FallThroughError();
  }
}