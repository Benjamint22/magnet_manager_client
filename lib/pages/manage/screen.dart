import 'package:flutter/material.dart';
import './fragment_home.dart';
import './fragment_services.dart';
import './fragmentdefinition.dart';
import '../../classes/session.dart';
import '../../classes/service.dart';

class ManageScreen extends StatefulWidget {
  ManageScreen(Session session, {Key key}) : _session = session, super(key: key);

  Session _session;

  @override
  State<StatefulWidget> createState() => _ManageScreenState(_session);
}

class _ManageScreenState extends State<ManageScreen> {
  // Objects
  final List<FragmentDefinition> _fragments;
  final Session _session;

  // States
  FragmentDefinition _currentFragment;

  // Properties
  Drawer get _drawer {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      onPressed: _exitScreen,
                    ),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _session.username,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ]
                ),
              ]
            ),
            decoration: BoxDecoration(
              color: ThemeData.light().primaryColor
            ),
          ),
          Column(
            children: _fragments.map((fragment) => ListTile(
              leading: Icon(fragment.icon),
              title: Text(fragment.name),
              selected: fragment == _currentFragment,
              onTap: () {
                setState(() {
                  _currentFragment = fragment;
                });
                Navigator.of(context).pop();
              }
            )).toList()
          )
        ]
      )
    );
  }

  _ManageScreenState(Session session) : 
    _session = session,
    _fragments = [
      FragmentDefinition(
        "Home",
        Icons.home,
        Builder(
          builder: (context) {
            return HomeFragment();
          }
        )
      ),
      FragmentDefinition(
        "Services",
        Icons.list,
        Builder(
          builder: (context) {
            return ServicesFragment(session);
          }
        )
      ),
    ]
  {
    _currentFragment = _fragments[0];
  }

  void _exitScreen() {
    Navigator.of(context)..pop()..pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage MAGNET"),
      ),
      drawer: _drawer,
      body: _currentFragment.fragment,
    );
  }
}