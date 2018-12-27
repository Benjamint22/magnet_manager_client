import 'package:flutter/material.dart';

class FragmentDefinition {
  String _name;
  IconData _icon;
  Builder _fragment;

  String get name => _name;
  IconData get icon => _icon;
  Builder get fragment => _fragment;

  FragmentDefinition(String name, IconData icon, Builder fragment) : _name = name, _icon = icon, _fragment = fragment;
}