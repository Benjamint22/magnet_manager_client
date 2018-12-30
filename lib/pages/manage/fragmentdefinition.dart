import 'package:flutter/material.dart';

typedef Builder FragmentBuilder<T extends StatefulFragment>(Key scaffoldKey, Drawer drawer);

abstract class FragmentState<T extends StatefulFragment> extends State<T> {
  Widget buildAppBar();
  Widget buildBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      appBar: buildAppBar(),
      body: buildBody(),
      drawer: widget._drawer,
    );
  }
}

abstract class StatefulFragment extends StatefulWidget {
  final Drawer _drawer;
  final Key _scaffoldKey;

  const StatefulFragment(this._scaffoldKey, this._drawer, {Key key}) : super(key: key);

  FragmentState<StatefulFragment> createStateFragment();

  @override
  State<StatefulWidget> createState() => createStateFragment();
}

class FragmentDefinition<T extends StatefulFragment> {
  final String _name;
  final IconData _icon;
  final FragmentBuilder<T> _builder;

  const FragmentDefinition(this._name, this._icon, this._builder);

  String get name => _name;
  IconData get icon => _icon;

  Widget getScaffold(Key scaffoldKey, Drawer drawer) {
    return _builder(scaffoldKey, drawer);
  }
}