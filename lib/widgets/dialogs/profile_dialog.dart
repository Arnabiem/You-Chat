import "package:flutter/material.dart";
import "package:you_chat/main.dart";
import "package:you_chat/models/chat_user.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:you_chat/screens/view_profile.dart';

class DialogProfile extends StatelessWidget {
  const DialogProfile({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: mq.height *.35,
        width: mq.width *.6,
        child: Stack(          
          children: [
             // profile pic             
             Positioned(
               left: mq.width *.1,
              top: mq.height *.06,
               child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .25),
                    child: CachedNetworkImage(
                      width: mq.width * .54,                      
                      fit: BoxFit.fill,
                      imageUrl: user.image,             
                        errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person),),
                      ),
                         ),
             ),
            // profile name
            Positioned(
              left: mq.width *.05,
              top: mq.height *.01,
              width: mq.width *.5,
              child: Text(user.name,
              style:GoogleFonts.balooBhai2(fontWeight: FontWeight.w500,fontSize: 20))),
             
            //  profile info
             Align(
              alignment: Alignment.topRight,
              child: MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfile(user: user)));
                },
                padding: EdgeInsets.all(0),
                minWidth: 0,
                shape: CircleBorder(),
              child: Icon(Icons.info_outline_rounded,color: Colors.blue,size: 30,)
              ),
              )
          ],
        ),
      ),
    );
  }
}