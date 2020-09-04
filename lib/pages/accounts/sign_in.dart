import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:compres/services/auth.dart';
import 'package:compres/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Loading("Comprovant credencials..."),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0,
              title: Text("Inicia la sessió"),
              actions: [
                FlatButton.icon(
                  onPressed: () {
                    widget.toggleView();
                  },
                  icon: Icon(Icons.person),
                  label: Text("Registra't"),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 50,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      TextFormField(
                        // Email
                        decoration: InputDecoration(
                          hintText: "Adreça electrònica",
                        ),
                        validator: (val) => val.isEmpty
                            ? "Siusplau, entra un correu electrònic."
                            : null,
                        onChanged: (value) {
                          setState(() => email = value);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        // Password
                        decoration: InputDecoration(
                          hintText: "Contrasenya",
                        ),
                        validator: (val) => val.length < 6
                            ? "Siusplau, entra una contrasenya amb 6+ caràcters."
                            : null,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() => password = value);
                        },
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                        onPressed: () async {
                          setState(() => loading = true);
                          if (_formKey.currentState.validate()) {
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);
                            if (result['response'] == null) {
                              setState(() => error = result['error']);
                            }
                          }
                          if (this.mounted) setState(() => loading = false);
                        },
                        color: Colors.pink[400],
                        child: Text(
                          "Inicia la sessió",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        error,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}