import 'requester.dart';
import 'service.dart';

const String base_url = "https://benjamintaillon.com:25569";
const Duration timeoutDuration = Duration(seconds: 8);

class BadLoginException implements Exception {}
class BadPasswordException implements Exception {}
class InvalidKeyError implements Exception {}
class TimeoutException implements Exception {}

class Session {
  String _key;

  Session(String key) : _key = key;

  Stream<Service> listServices() async* {
    Response response = await Requester.post(
      "$base_url/services/list",
      {
        "key": _key,
      },
      true,
    ).timeout(timeoutDuration, onTimeout: () => throw TimeoutException());
    if (response.statusCode == 403)
      throw InvalidKeyError();
    if (response.statusCode == 200) {
      for (dynamic jsonService in response.jsonBody) {
        yield Service.fromJSON(jsonService);
      }
      return;
    }
    throw new FallThroughError();
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
      return Session(response.jsonBody["key"]);
    }
    throw FallThroughError();
  }
}