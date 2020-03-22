import 'package:flutter/material.dart';
import 'package:ocrapplication/models/user.dart';
import 'package:ocrapplication/screens/authenticate/authenticate.dart';
import 'package:ocrapplication/screens/home/home.dart';
import 'package:provider/provider.dart';

import 'authenticate/sign_in.dart';
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user);
    //HOME OR AUTH WIDGET
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}