import 'dart:async';

import 'package:flutter/material.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import './fragmentdefinition.dart';
import '../../classes/session.dart';
import '../../classes/service.dart';
import '../../widgets/loading.dart';

Color colorFromStatus(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.ACTIVE:
      return Colors.green;
    case ServiceStatus.INACTIVE:
      return Colors.red;
    case ServiceStatus.FAILED:
      return Colors.orange;
  }
  throw FallThroughError();
}

IconData iconFromStatus(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.ACTIVE:
      return Icons.check_circle;
    case ServiceStatus.INACTIVE:
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
  Loading _loading;

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
    try {
      List<Service> services = await widget.session.listServices();
      _allServices = services;
      setState(() {
        _searching = false;
        _displayedServices = _allServices;
      });
    } on InvalidKeyException {
      await _showError("Session expired", "Your current session has expired. Please log back in.");
      Navigator.of(context).pop();
    } on TimeoutException {
      _showError("Timeout", "The server has not responded and the request has timed out.");
    }
  }

  Future<void> _executeAction(Service service, ServiceAction action) async {
    _loading.show("Executing...");
    bool checkStatus = true;
    try {
      await widget._session.executeAction(service, action);
    } on InvalidKeyException {
      _loading.hide();
      await _showError("Session expired", "Your current session has expired. Please log back in.");
      Navigator.of(context).pop();
      return;
    } on InternalServerError catch (e) {
      _showError("Internal server error", e.message);
    } on TimeoutException {
      _showError("Timeout", "The server has not responded and the request has timed out.");
      checkStatus = false;
    }
    _loading.hide();
    if (checkStatus) {
      ServiceStatus newStatus = await widget._session.getStatus(service);
      setState(() {
        service.active = newStatus;
      });
    }
  }

  Future<void> _showError(String title, String content) async {
    Completer c = Completer();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            c.complete();
            return true;
          },
          child: AlertDialog(
            title: Text(title),
            content: Text(content.trimRight()),
            contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                  c.complete();
                },
              )
            ],
          )
        );
      }
    );
    return c.future;
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
    return Builder(
      builder: (context) {
        if (_loading == null) {
          _loading = new Loading(context);
        } else {
          _loading.context = context;
        }
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
              Service currentService = _displayedServices[index];
              return Container(
                height: 72,
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    children:[
                      Expanded(
                        child: ListTile(
                          key: Key(currentService.name),
                          title: Text(currentService.name),
                          subtitle: Text(currentService.description),
                          leading: CircleAvatar(
                            backgroundColor: colorFromStatus(currentService.active),
                            child: Icon(
                              iconFromStatus(currentService.active),
                              color: Colors.white,
                            ),
                          ),
                        )
                      ),
                      PopupMenuButton<ServiceAction>(
                        onSelected: (action) async {
                          await _executeAction(currentService, action);
                        },
                        itemBuilder: (context) {
                          if (currentService.active == ServiceStatus.ACTIVE)
                          {
                            return <PopupMenuItem<ServiceAction>>[
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.STOP,
                                child: Text("Stop"),
                              ),
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.RESTART,
                                child: Text("Restart"),
                              )
                            ];
                          } else {
                            return <PopupMenuItem<ServiceAction>>[
                              PopupMenuItem<ServiceAction>(
                                value: ServiceAction.START,
                                child: Text("Start"),
                              )
                            ];
                          }
                        },
                      )
                    ]
                  ),
                ),
              );
            },
          )
        );
      }
    );
  }
}