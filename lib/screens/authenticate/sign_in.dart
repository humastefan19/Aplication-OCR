import 'package:flutter/material.dart';
import 'package:ocrapplication/services/auth.dart';

 class SignIn extends StatefulWidget {
   @override
   _SignInState createState() => _SignInState();
 }
 
 class _SignInState extends State<SignIn> {

   final AuthService _auth = AuthService();

   String email ='';
   String password = '';


   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.purple[100],
       appBar:AppBar(
         backgroundColor: Colors.purple[400],
         elevation: 0.0,
         title:Text('Sign In to TranslationApp'),
        ),
        body:Container(
          padding: EdgeInsets.symmetric( vertical:20.0, horizontal: 50.0),
          child: Form(
            child:Column(
              children: <Widget> [
                SizedBox(height:  20.0),
                TextFormField(
                  onChanged: (val){
                    setState(() => email =val);

                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  obscureText: true,
                  onChanged:(val){
                     setState(() => password =val);

                  }
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                  color: Colors.teal[400],
                  child: Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),

                    ),
                  onPressed:() async{
                    

                  }
               ),
              ],
            )
            )
        ),

     );
   }
 }