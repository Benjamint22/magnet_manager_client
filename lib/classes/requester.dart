import 'dart:io';
import 'dart:convert';

class BadCertificateException implements Exception {}

class Response {
  int _statusCode;
  dynamic _body;

  int get statusCode => _statusCode;
  dynamic get body => _body;
  dynamic get jsonBody => json.decode(_body);

  Response(int statusCode, dynamic body) : _statusCode = statusCode, _body = body;
}

class Requester {
  static Future<Response> post(String url, dynamic data, bool readBody) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
      //throw BadCertificateException();
    };
    HttpClientResponse response = await client
      .postUrl(Uri.parse(url))
      .then((request) {
        request.headers.set('content-type', 'application/json');
        return request;
      })
      .then((request) => request..add(utf8.encode(json.encode(data))))
      .then((request) => request.close());
    dynamic body;
    if (readBody) {
      body = await response.transform(utf8.decoder).join();
    }
    return Response(response.statusCode, body);
  }
}