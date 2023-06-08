
import 'dart:io';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:you_chat/api/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_chat/auth/login.dart';
import 'package:you_chat/helper/dialogs.dart';
import 'package:you_chat/models/chat_user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import 'package:cached_network_image/cached_network_image.dart';


class Profile extends StatefulWidget {
  final ChatUser user;
  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text("Profile Page"),),
         // log out button
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom:15),
          child: FloatingActionButton.extended(
            onPressed: () async{
              Dialogs.showProgressBar(context);
              // signing out
              await Apis.updateActiveStatus(false);
            await Apis.auth.signOut().then((value) async {
            await GoogleSignIn().signOut().then((value) {
              Navigator.pop(context);
              // moving to home screen
              Navigator.pop(context);
              Apis.auth=FirebaseAuth.instance;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> Login()));
            });
    
            });
            }, 
            icon: Icon(Icons.logout),
            label: Text('Log Out')),
        ),
    
    
        
        body: Padding(
          padding:  EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: Column(
            children: [
              SizedBox(width: mq.width,height: mq.height * .02,),
              Stack(
                children: [
                  _image!=null?
                  ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: Image.file(
                    File(_image!),
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                    // imageUrl: widget.user.image,             
                    //   errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person),),
                   ),
            ):
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
            // profile dp edit button
            Positioned(
              bottom: 2,
              right: 0,
              child: MaterialButton(onPressed: (){
            _showbottomsheet();
              },
              elevation: 1,
              shape: CircleBorder(),
              color: Colors.white,
              child: Icon(Icons.edit,color: Colors.blue,),),
            )
                ],
              ),
            SizedBox(height: mq.height * .01,),
            Text(widget.user.name,style: GoogleFonts.balooBhai2(fontSize: 25)),
            SizedBox(height: mq.height * .03,),
    TextFormField(
      initialValue: widget.user.name,
      decoration: InputDecoration(
      prefixIcon: Icon(Icons.person),
      hintText: 'eg. Neymar Jr.',
      label: Text('Name'),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    ),
    SizedBox(height: mq.height * .02,),
    TextFormField(
      initialValue: widget.user.about,
      decoration: InputDecoration(
      prefixIcon: Icon(Icons.info_outline),
      hintText: 'eg. Feeling bored',
      label: Text('About'),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    ),
    SizedBox(height: mq.height * .03,),
    
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(shape: StadiumBorder(),minimumSize: Size(mq.width * .5, mq.height * .06)),
      onPressed: (){
    
      },
    icon: Icon(Icons.edit,size: 28,), 
    label: Text("Edit Profile",style: GoogleFonts.balooBhai2(fontSize: 20),))
    
            ],
          ),
        ),
    
      ),
    );
  }
  // showing bottom icon for profile pic selection
void _showbottomsheet(){
  showModalBottomSheet(context: context,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
   builder: (_){
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(top: mq.height * .03,bottom: mq.height * .04),
      children: [
        Text("Select Profile Picture",style: GoogleFonts.balooBhai2(fontSize: 25,fontWeight: FontWeight.w400),
        textAlign: TextAlign.center,),
  SizedBox(height: mq.height * .02,),
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    ElevatedButton(      
style:ElevatedButton.styleFrom(
  shape: CircleBorder(),
  backgroundColor: Colors.grey[200],
    fixedSize: Size(mq.width * .3, mq.height * .15)),

    onPressed: () async {
      final ImagePicker picker = ImagePicker();
// Pick an image.
     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
     if(image!=null){
      print("image path: ${image.path}");
      setState(() {
        _image=image.path;
      });
      Apis.updateProfilePic(File(_image!));
      Navigator.pop(context);
     }
},
          child: Image.network('https://firebasestorage.googleapis.com/v0/b/you-chat-155b8.appspot.com/o/images%2Fadd_image.png?alt=media&token=7cba0ae0-3c1f-44f8-bf79-3fb35e01a8f5')),
     

     ElevatedButton(
     onPressed: () async {
      final ImagePicker picker = ImagePicker();
// Pick an image.
     final XFile? image = await picker.pickImage(source: ImageSource.camera);
     if(image!=null){
      print("image path: ${image.path}");
      setState(() {
        _image=image.path;
      });
      Apis.updateProfilePic(File(_image!));
      Navigator.pop(context);
     }
},
  style:ElevatedButton.styleFrom(
  shape: CircleBorder(),
  backgroundColor: Colors.grey[200],
fixedSize: Size(mq.width * .3, mq.height * .15)),

          child: Image.network('https://firebasestorage.googleapis.com/v0/b/you-chat-155b8.appspot.com/o/images%2Fcamera.png?alt=media&token=a1aac035-ff48-402c-ba75-4e0a711130cd')),
     
  ],)
      ],
    
    );
   });
}


}