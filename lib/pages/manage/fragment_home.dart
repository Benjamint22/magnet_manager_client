import 'package:flutter/material.dart';
import './fragmentdefinition.dart';

class HomeFragment extends StatefulFragment {
  HomeFragment(Key scaffoldKey, Drawer drawer, {Key key}) : super(scaffoldKey, drawer, key: key);

  @override
  FragmentState<HomeFragment> createStateFragment() => _HomeFragmentState();
}

class _HomeFragmentState extends FragmentState<HomeFragment> {
  _HomeFragmentState();

  @override
  Widget buildAppBar() {
    return AppBar(
      title: Text("Home"),
    );
  }

  @override
  Widget buildBody() {
    return Center(
      child: Text("This is the home screen.")
    );
  }
}