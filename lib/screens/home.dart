import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import "package:flutter/material.dart";
import 'package:you_chat/api/apis.dart';
import 'package:you_chat/helper/dialogs.dart';
import 'package:you_chat/helper/dialogs.dart';
import 'package:you_chat/main.dart';
import 'package:you_chat/models/chat_user.dart';
import 'package:you_chat/screens/profile_screen.dart';
import 'package:you_chat/widgets/chat_user_card.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ChatUser> _list=[];
  final List<ChatUser> _searchList=[];
  bool _isSearch=false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Apis.getProfileInfo(); 
    // Apis.updateActiveStatus(true);
    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {      

      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
    // for hiding keyboard while tapped elsewhere
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
// back button to return to home from search ,and again to get exit from the app
      child: WillPopScope(
        onWillPop: (){
          if (_isSearch) {
            setState(() {
            _isSearch=!_isSearch;              
            });
            return Future.value(false);
            
          }else{
            return Future.value(true);

          }
          
        },
        child: Scaffold(
          appBar: AppBar(title: _isSearch?TextField(
            decoration: InputDecoration(
              border: InputBorder.none,hintStyle:TextStyle(color: Colors.white),
              hintText: "Search Users here..."
            ),
            autofocus: true,
            cursorColor: Colors.white,
            style: TextStyle(fontSize: 18,color: Colors.white),
            // search logic
            onChanged: (val){
              _searchList.clear();
              for(var i in _list){
                if(i.name.contains(val.toLowerCase()) || i.email.contains(val.toLowerCase())){
                  _searchList.add(i);
                  setState(() {
                    _searchList;
                  });
                }
              }
            },
          ):Text('You Chat'),
          leading: Icon(Icons.home),
          actions: [
            // user search button
            IconButton(onPressed: (){
              setState(() {
                _isSearch=!_isSearch;
              });
            },         
            icon: Icon(_isSearch?CupertinoIcons.clear_circled_solid:Icons.search)),
            // 3 dots ->profile screen
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (_)=> Profile(user: Apis.me,)));
            }, icon: Icon(Icons.more_vert))
          ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom:10.0),
            child: FloatingActionButton(onPressed: ()  async {
             _addChatUserDialog();
            },child: Icon(Icons.add_comment_rounded),),
          ),

          // to get only known user ids
        body: StreamBuilder(
            stream: Apis.getMyUsersId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  // return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: Apis.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearch
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearch
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Connections Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }
  // adds new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await Apis.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnack(context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
}
}