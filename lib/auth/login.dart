import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:you_chat/api/apis.dart';
import 'package:you_chat/main.dart';
import 'package:you_chat/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:you_chat/helper/dialogs.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isAnimate=false;
  @override
  void initState() {      
    super.initState();
    Future.delayed(Duration(milliseconds: 500),(){
setState(() {
  _isAnimate=true;
});
    });
  }
  _googlesignin(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user!=null){
      // log('\nUser: ${user.user}');
      // log('\nUserAdditionalInfo:${user.additionalUserInfo}');
      if((await Apis.UserExists())){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> Home()));
      }
      
      else{
        await Apis.CreateUser().then((value) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> Home()));
        });
      }
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> Home()));
      }
      
    });
    
}
Future<UserCredential?> _signInWithGoogle() async {
  try{
    await InternetAddress.lookup('google.com');
    // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,    
  );
  // Once signed in, return the UserCredential
  return await Apis.auth.signInWithCredential(credential);
  }
  catch(e){
    // log('\n_signInWithGoogle: $e');    
    Dialogs.showSnack(context, 'Oops Something went wrong!!Check your Internet...');
    return null;
  }
  }
//   _signout() async{
// await Apis.auth.signOut();
// await GoogleSignIn().signOut();
//   }
  @override
  Widget build(BuildContext context) {
    // mq=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to You Chat'),),
      body: Stack(children: [
        AnimatedPositioned(
          top: mq.height * .10,
          right:_isAnimate? mq.width * .25: -mq.width * .5,
          width: mq.width * .5,
          duration: Duration(seconds: 1),
          child: Image.asset('assets/wechat.png')),

          Positioned(
            bottom: mq.height * .25,
          left: mq.height * .07,
          width: mq.width * .7,
          height: mq.height * .065,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 123, 226, 127),
            shape: StadiumBorder(),elevation: 1),
            onPressed: (){
              _googlesignin();
            },
           icon: Image.asset('assets/google.png',height: mq.height * .045,), 
           label:RichText(text: TextSpan(
            style: TextStyle(color: Colors.black,fontSize: 15),
            children: [
              TextSpan(text: 'Login with '),
              TextSpan(text: 'Google',style: TextStyle(fontWeight: FontWeight.bold))
            ]

           ))),
          )
      
      ]),
      
    );
  }
}