import 'package:flutter/material.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
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
  final Session _session;

  const ServicesFragment(Key scaffoldKey, Drawer drawer, Session session, {Key key}) : _session = session, super(scaffoldKey, drawer, key: key);

  Session get session => _session;

  @override
  FragmentState<ServicesFragment> createStateFragment() => _ServicesFragmentState();
}

class _ServicesFragmentState extends FragmentState<ServicesFragment> {
  // Objects
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  List<Service> _allServices;

  // States
  List<Service> _displayedServices;
  bool _searching;

  void _onTyped(String text) {
    final String criteria = text.toLowerCase();
    setState(() {
      _displayedServices = _allServices.where(
        (service) => 
          service.name.toLowerCase().contains(criteria) || 
          service.description.toLowerCase().contains(criteria)
      ).toList();
    });
  }

  Future<void> _refresh() async {
    List<Service> services = await widget.session.listServices().toList();
    _allServices = services;
    setState(() {
      _searching = false;
      _displayedServices = _allServices;
    });
  }

  @override
  void initState() {
    setState(() {
      _searching = false;
      _allServices = _displayedServices = [];
    });
    _refresh();
    super.initState();
  }

  @override
  Widget buildAppBar() {
    if (!_searching) {
      return AppBar(
        title: Text("Services"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searching = true;
                _searchController.text = "";
              });
            },
          ),
        ]
      );
    }
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: TextField(
        autofocus: true,
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search a service...",
          border: InputBorder.none,
        ),
        onChanged: _onTyped,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _searching = false;
              _displayedServices = _allServices;
            });
          },
        ),
      ]
    );
  }

  @override
  Widget buildBody() {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: (_) async {
        await _refresh();
        _refreshController.sendBack(true, RefreshStatus.completed);
      },
      child: ListView.builder(
        itemCount: _displayedServices.length,
        physics: const AlwaysScrollableScrollPhysics (),
        itemBuilder: (context, index) {
          return ListTile(
            key: Key(_displayedServices[index].name),
            title: Text(_displayedServices[index].name),
            subtitle: Text(_displayedServices[index].description),
            leading: CircleAvatar(
              backgroundColor: colorFromStatus(_displayedServices[index].active),
              child: Icon(iconFromStatus(_displayedServices[index].active), color: Colors.white,),
            )
          );
        },
      )
    );
  }
}