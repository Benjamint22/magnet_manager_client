import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';

class ManageScreen extends StatefulWidget {
  ManageScreen(SSHClient client, {Key key}) : _client = client, super(key: key);

  SSHClient _client;

  @override
  State<StatefulWidget> createState() => _ManageScreenState(_client);
}

class _ManageScreenState extends State<ManageScreen> {
  _ManageScreenState(SSHClient client) : _client = client;

  SSHClient _client;

  @override
  Widget build(BuildContext context) {
    return null;
  }
}