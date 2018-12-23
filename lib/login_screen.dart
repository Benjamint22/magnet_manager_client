import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magnet_manager/widgets/loading.dart';
import 'package:ssh/ssh.dart';

const String host = "benjamintaillon.com";
const int port = 22;
const Duration timeoutDuration = Duration(seconds: 6);

const SnackBar timeoutSnackBar = SnackBar(
  content: Text("Timed out. Could not reach server."),
  duration: Duration(seconds: 4),
);

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contexts
  BuildContext _scaffoldContext;

  Loading _loading;

  // States
  String _errorText;

  // Field values
  String _username;
  String _password;

  // Helper functions
  Future<String> _tryConnect(SSHClient client) async {
    try {
      return await client.connect();
    } on PlatformException catch (e) {
      return e.code;
    }
  }

  // Events
  String _validateUsername(String value) {
    if (value.isEmpty) {
      return "Please type in a username.";
    }
    _formKey.currentState.save();
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return "Please type in a password.";
    }
    _formKey.currentState.save();
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _loading.show("Attempting to connect...");
    SSHClient client = SSHClient(
        host: host, port: port, username: _username, passwordOrKey: _password);
    String result;
    result = await _tryConnect(client).timeout(timeoutDuration, onTimeout: () {
      _loading.hide();
      Scaffold.of(_scaffoldContext).showSnackBar(timeoutSnackBar);
    });
    switch (result) {
      case "connection_failure":
        _loading.hide();
        setState(() {
          _errorText = "Wrong credentials.";
        });
        break;
      case "session_connected":
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context;
          _loading = Loading(_scaffoldContext);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MAGNET Login",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextFormField(
                        validator: _validateUsername,
                        decoration: new InputDecoration(
                          labelText: "Username"
                        ),
                        onSaved: (value) => _username = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextFormField(
                        validator: _validatePassword,
                        obscureText: true,
                        decoration: new InputDecoration(
                          labelText: "Password", errorText: _errorText
                        ),
                        onSaved: (value) => _password = value,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: RaisedButton(
                            onPressed: _submit, child: Text("Login")
                        )
                    )
                  ],
                )
              )
            ],
          );
        }
      ),
    );
  }
}
