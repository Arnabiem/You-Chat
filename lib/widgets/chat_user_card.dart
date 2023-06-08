import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:you_chat/api/apis.dart';
import 'package:you_chat/helper/mydate.dart';
import 'package:you_chat/main.dart';
import 'package:you_chat/models/chat_msg.dart';
import 'package:you_chat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:you_chat/screens/chat_screen.dart';
import 'package:you_chat/widgets/dialogs/profile_dialog.dart';
class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last msg info
  Messages? _messages;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width *.03,vertical: 5),
      color: Colors.tealAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
child: InkWell(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatScreen(user: widget.user,)));
  },
  // profile pic + list of chat users
  child: StreamBuilder(
    stream: Apis.getLastMessage(widget.user),
    builder: (context,snapshot){
      final data=snapshot.data?.docs;
         final list=data?.map((e) => Messages.fromJson(e.data())).toList()?? [];              

      if(list.isNotEmpty){
        _messages=list[0];
      }
      return  ListTile(
   // user profile pic
    leading: InkWell(
      onTap: (){
        showDialog(context: context, builder: (_)=>DialogProfile(user: widget.user));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(mq.height *.3),
        child: CachedNetworkImage(
          width: mq.height * .050,
          height: mq.height *.050,
          imageUrl: widget.user.image,          
            errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person),),
         ),
      ),
    ),
    // user name show
    title: Text(widget.user.name,style: GoogleFonts.balooBhai2(fontWeight: FontWeight.bold,fontSize: 20)),
    // last msg show
    subtitle: Text(_messages!=null?_messages!.type==Type.image?'Photo':
    _messages!.msg:
    widget.user.about,maxLines: 1,), 

    // trailing: Text("10:10 pm",style: TextStyle(color: Colors.black54),),
    // last msg time
    trailing: _messages==null?
    // show green dot for unread msg of sender
    null: _messages!.read.isEmpty && _messages!.fromId!=Apis.user.uid?
    Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: Colors.green,borderRadius: BorderRadius.circular(10)),
    ):
    // show send time for read msg
    Text(MyDate.getLastMsgTime(context: context, time: _messages!.send),style: TextStyle(color: Colors.black54),)
  );
  }
  
),
)
    );
  }
}