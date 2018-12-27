import 'package:flutter/material.dart';
import '../../classes/session.dart';
import '../../classes/service.dart';

Color colorFromStatus(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.RUNNING:
      return Colors.green;
    case ServiceStatus.EXITED:
      return Colors.red;
    case ServiceStatus.FAILED:
      return Colors.orange;
  }
  throw FallThroughError();
}

IconData iconFromStatus(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.RUNNING:
      return Icons.check_circle;
    case ServiceStatus.EXITED:
      return Icons.remove_circle;
    case ServiceStatus.FAILED:
      return Icons.error;
  }
  throw FallThroughError();
}

class ServicesFragment extends StatefulWidget {
  ServicesFragment(Session session, {Key key}) : _session = session, super(key: key);

  final Session _session;

  @override
  State<ServicesFragment> createState() => _ServicesFragmentState(_session);
}

class _ServicesFragmentState extends State<ServicesFragment> {
  _ServicesFragmentState(Session session) : _session = session {
    session.listServices().toList().then((services) {
      setState(() {
        _services = services;
      });
    });
  }

  // Objects
  Session _session;
  List<Service> _services = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _services.length,
      physics: const AlwaysScrollableScrollPhysics (),
      itemBuilder: (context, index) {
        return ListTile(
          key: Key(_services[index].name),
          title: Text(_services[index].name),
          subtitle: Text(_services[index].description),
          leading: CircleAvatar(
            backgroundColor: colorFromStatus(_services[index].active),
            child: Icon(iconFromStatus(_services[index].active), color: Colors.white,),
          )
        );
      },
    );
  }
}