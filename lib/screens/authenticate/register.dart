import 'package:flutter/material.dart';
import 'package:ocrapplication/screens/authenticate/sign_in.dart';
import 'package:ocrapplication/services/auth.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});
  
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      appBar: AppBar(
        backgroundColor: Colors.purple[400],
        elevation: 0.0,
        title: Text('Sign Up to TranslationApp'),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
               widget.toggleView();
              },
              icon: Icon(Icons.person),
              label: Text('Sign In'))
        ],
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  TextFormField(
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                      obscureText: true,
                      validator: (val) => val.length < 6
                          ? 'The password must contain minimum 6 characters'
                          : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      }),
                  SizedBox(height: 20.0),
                  RaisedButton(
                      color: Colors.teal[400],
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        setState(() => error = '');
                        if (_formKey.currentState.validate()) {
                          dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                          if (result == null) {
                            setState(() => error = 'Email Already in use!');
                          } else {
                            setState(() => error = '');
                          }
                        }
                      }),
                  SizedBox(height: 20.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  )
                ],
              ))),
    );
  }

  // String validateEmail(String value) {
  //   Pattern pattern =
  //       r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  //   RegExp regex = new
  //   RegExp(pattern);
  //   if (value.isEmpty)
  //     return "Enter an email";
  //   else if (!regex.hasMatch(value))
  //     return 'Enter Valid Email';
  //   else
  //     return null;
  // }
}

