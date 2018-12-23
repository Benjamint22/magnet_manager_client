import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssh/ssh.dart';

const String host = "benjamintaillon.com";
const int port = 22;
const String username = "benjamin";
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

  OverlayEntry _loading;

  // States
  String _errorText;

  // Field values
  String _password;

  // Helper functions
  Future<String> _tryConnect(SSHClient client) async {
    try {
      return await client.connect();
    } on PlatformException catch (e) {
      return e.code;
    }
  }

  void _showLoading() {
    Overlay.of(_scaffoldContext)
        .insert(_loading = OverlayEntry(builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              Opacity(
                opacity: 0.3,
                child: const ModalBarrier(dismissible: false, color: Colors.grey),
              ),
              AlertDialog(
                  title: Text("Attempting to connect..."),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator()],
                  )
                )
            ],
          );
        }
      )
    );
  }

  void _hideLoading() {
    _loading.remove();
    _loading = null;
  }

  // Events
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
    _showLoading();
    SSHClient client = SSHClient(
        host: host, port: port, username: username, passwordOrKey: _password);
    String result;
    result = await _tryConnect(client).timeout(timeoutDuration, onTimeout: () {
      _hideLoading();
      Scaffold.of(_scaffoldContext).showSnackBar(timeoutSnackBar);
    });
    switch (result) {
      case "connection_failure":
        _hideLoading();
        setState(() {
          _errorText = "Wrong password.";
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
