import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocrapplication/models/user.dart';

class AuthService{

final FirebaseAuth _auth = FirebaseAuth.instance;
// create user obj based on FirebaseUser
User _userFromFirebaseUser(FirebaseUser user){
  return user != null ? User(uid: user.uid) : null;
}
//sign_in anon

//auth change user stream
Stream <User> get user {
  return _auth.onAuthStateChanged
    .map((FirebaseUser user) => _userFromFirebaseUser(user));
}
Future signInAnon() async{
  try{
    AuthResult result = await  _auth.signInAnonymously();
    FirebaseUser user = result.user;
    return _userFromFirebaseUser(user) ;
  }catch(e){
    print(e.toString());
    return null;

  }
}
// sign in with email and pass

//register with email and password
Future registerWithEmailAndPassword(String email, String password) async {
  try{
    AuthResult result = await _auth.createUserWithEmailAndPassword(email : email, password : password);
    FirebaseUser user = result.user;
    return _userFromFirebaseUser(user);
  }catch(e){
    print(e.toString());
    return null;

  }
}

//sign out

}