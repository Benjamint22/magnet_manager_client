import 'dart:core';

enum ServiceStatus {
  RUNNING,
  EXITED,
  FAILED,
}

class Service {
  String _name;
  ServiceStatus _active;
  String _description;

  String get name => _name;
  ServiceStatus get active => _active;
  String get description => _description;

  static ServiceStatus statusFromString(String status) {
    switch (status.toUpperCase()) {
      case "RUNNING":
        return ServiceStatus.RUNNING;
      case "EXITED":
        return ServiceStatus.EXITED;
      case "FAILED":
        return ServiceStatus.FAILED;
    }
    throw ArgumentError();
  }

  Service(String name, ServiceStatus active, String description) : _name = name, _active = active, _description = description;

  static Service fromJSON(dynamic json) => Service(
    json["name"], 
    Service.statusFromString(json["active"]),
    json["description"],
  );
}