import 'package:flutter/material.dart';
import './fragment_home.dart';
import './fragment_services.dart';
import './fragmentdefinition.dart';
import '../../classes/session.dart';

class ManageScreen extends StatefulWidget {
  ManageScreen(Session session, {Key key}) : _session = session, super(key: key);

  final Session _session;

  @override
  State<StatefulWidget> createState() => ManageScreenState(_session);
}

class ManageScreenState extends State<ManageScreen> {
  // Objects
  final List<FragmentDefinition> _fragments;
  final Session _session;
  final GlobalKey _scaffoldKey = GlobalKey();

  // States
  FragmentDefinition _currentFragment;

  ManageScreenState(Session session) : 
    _session = session,
    _fragments = [
      FragmentDefinition<HomeFragment>(
        "Home",
        Icons.home,
        (scaffoldKey, drawer) => Builder(
          builder: (context) {
            return HomeFragment(scaffoldKey, drawer);
          },
        )
      ),
      FragmentDefinition<ServicesFragment>(
        "Services",
        Icons.list,
        (scaffoldKey, drawer) => Builder(
          builder: (context) {
            return ServicesFragment(scaffoldKey, drawer, session);
          },
        )
      ),
    ]
  {
    _currentFragment = _fragments[0];
  }

  void _exitScreen() {
    Navigator.of(context)..pop()..pop();
  }

  Drawer _getDrawer() {
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

  @override
  void initState() {
      super.initState();
    }

  @override
  Widget build(BuildContext context) {
    return _currentFragment.getScaffold(_scaffoldKey, _getDrawer());
  }
}