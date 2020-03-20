import 'package:flutter/material.dart';
import 'package:ocrapplication/services/auth.dart';

class Register extends StatefulWidget {
 
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

   final AuthService _auth = AuthService();
   final _formKey = GlobalKey<FormState>(); 

   String email ='';
   String password = '';
   String error = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.purple[100],
       appBar:AppBar(
         backgroundColor: Colors.purple[400],
         elevation: 0.0,
         title:Text('Sign Up to TranslationApp'),
        ),
        body:Container(
          padding: EdgeInsets.symmetric( vertical:20.0, horizontal: 50.0),
          child: Form(
            key : _formKey,
            child:Column(
              children: <Widget> [
                SizedBox(height:  20.0),
                TextFormField(
                  validator: (val) => val.isEmpty ? 'Enter an email' : null,
                  onChanged: (val){
                    setState(() => email =val);

                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  obscureText: true,
                    validator: (val) => val.length < 6 ? 'The password must contain minimum 6 characters' : null,
                  onChanged:(val){
                     setState(() => password =val);

                  }
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                  color: Colors.teal[400],
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white),

                    ),
                  onPressed:() async{
                    if(_formKey.currentState.validate()){
                      dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                      if(result == null){
                        setState(() => error = 'please enter a valid email');
                     }
                    }


                  }
               ),
               SizedBox(height : 20.0),
               Text(
                 error,
                 style:TextStyle(color: Colors.red, fontSize: 14.0),
               )
              ],
            )
            )
        ),

     );
  }
}