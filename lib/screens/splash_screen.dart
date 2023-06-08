import 'dart:math';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:you_chat/api/apis.dart';
import 'package:you_chat/auth/login.dart';
import 'package:you_chat/main.dart';
import 'package:you_chat/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';



class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _isAnimate=false;
  @override
  void initState() {      
    super.initState();
    Future.delayed(Duration(milliseconds: 1500),(){
      if(Apis.auth.currentUser!=null){
        // log('\n User: ${Apis.auth.currentUser}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
      }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(title: Text('Welcome to You Chat'),),
      body: Stack(children: [
        Positioned(
          top: mq.height * .20,
          right:mq.width * .25,
          width: mq.width * .5,
          child: Image.asset('assets/wechat.png')),

          Positioned(
            bottom: mq.height * .15,          
          width: mq.width,         
          child: Text('Made in India with ❤️',textAlign: TextAlign.center,
          style: GoogleFonts.balooBhai2(textStyle: TextStyle(fontSize: 30))),
          )
      
      ]),
      
    );
  }
}