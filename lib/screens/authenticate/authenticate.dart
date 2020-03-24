import 'package:flutter/material.dart';
import 'package:ocrapplication/screens/authenticate/register.dart';
import 'package:ocrapplication/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;

  void toogleView(){
    setState(() => showSignIn = !showSignIn);
  }
  @override
  Widget build(BuildContext context) {
    if (showSignIn){
      return SignIn(toggleView : toogleView);
    }else{
       return Register(toggleView : toogleView);
    }
  }
}