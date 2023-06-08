
import 'dart:io';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:you_chat/api/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_chat/auth/login.dart';
import 'package:you_chat/helper/dialogs.dart';
import 'package:you_chat/helper/mydate.dart';
import 'package:you_chat/models/chat_user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ViewProfile extends StatefulWidget {
  final ChatUser user;
  const ViewProfile({super.key, required this.user});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.user.name),), 
            //joined on info
               floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Joined on:",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),),
                Text(MyDate.getLastMsgTime(context: context, time: widget.user.createdAt,showyear: true),
                style:TextStyle(fontSize: 15,fontWeight: FontWeight.w300)),
              ],
            ),  
        body: Padding(
          padding:  EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: Column(
            children: [
              SizedBox(width: mq.width,height: mq.height * .02,),
              ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,             
                        errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person),),
                     ),
              ),
            SizedBox(height: mq.height * .01,),
            Text(widget.user.email,style:TextStyle(fontSize: 18,fontWeight: FontWeight.w400)),
            SizedBox(height: mq.height * .02,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("About:",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 22),),
                Text(widget.user.about,
                style:TextStyle(fontSize: 20,fontWeight: FontWeight.w400)),
              ],
            ),  
    
    
            ],
          ),
        ),
    
      ),
    );
  }
  
}