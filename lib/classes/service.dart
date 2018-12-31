import 'dart:core';

enum ServiceAction {
  START,
  STOP,
  RESTART
}

enum ServiceStatus {
  ACTIVE,
  INACTIVE,
  FAILED,
}

class Service {
  String _name;
  ServiceStatus active;
  String _description;

  String get name => _name;
  String get description => _description;

  static ServiceStatus statusFromString(String status) {
    switch (status.toUpperCase()) {
      case "ACTIVE":
        return ServiceStatus.ACTIVE;
      case "INACTIVE":
        return ServiceStatus.INACTIVE;
      case "FAILED":
        return ServiceStatus.FAILED;
    }
    throw ArgumentError();
  }

  Service(this._name, this.active, this._description);

  static Service fromJSON(dynamic json) => Service(
    json["name"], 
    Service.statusFromString(json["active"].toString().trimRight()),
    json["description"],
  );
}