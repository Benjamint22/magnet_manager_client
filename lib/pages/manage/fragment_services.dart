import 'package:flutter/material.dart';
import './fragmentdefinition.dart';
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

class ServicesFragment extends StatefulFragment {
  ServicesFragment(Key scaffoldKey, Drawer drawer, Session session, {Key key}) : _session = session, super(scaffoldKey, drawer, key: key);

  final Session _session;

  Session get session => _session;

  @override
  FragmentState<ServicesFragment> createStateFragment() => _ServicesFragmentState();
}

class _ServicesFragmentState extends FragmentState<ServicesFragment> {
  // Objects
  List<Service> _services = [];

  @override
  void initState() {
    widget.session.listServices().toList().then((services) {
      setState(() {
        _services = services;
      });
    });
    super.initState();
  }

  @override
  Widget buildAppBar() {
    return AppBar(
      title: Text("Services"),
    );
  }

  @override
  Widget buildBody() {
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