import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:you_chat/models/chat_msg.dart';
import 'package:you_chat/models/chat_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
class Apis{
  static FirebaseAuth auth=FirebaseAuth.instance;
  static FirebaseFirestore firestore=FirebaseFirestore.instance;
  static FirebaseStorage storage=FirebaseStorage.instance;
  static User get user => auth.currentUser!;
  static late ChatUser me;
 
  // Push notifications
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  // to get message tokens
    static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print('Push Token: $t');
      }
    });
    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
    }
    // sending push notifications
     static Future<void> sendPushNotification(ChatUser chatuser , String msg) async {
    try {
      final body = {
        "to": chatuser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },        
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAA0SN85Fw:APA91bEPau7CCeJvIPJZf7c9EGdbA3NWEzdUUzy5vNTiT-i27Cea3SGgyTxnVg5wo8bmHnd2Y7-JL5XJ73RRFmhoB0ME96rAfi2WVDTBnQPJL0_4ICKdRN1iMLEY_X3bT9YI7pZJfqRp',
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

   static Future <bool> UserExists() async{
    return (await firestore.collection('users').doc(user.uid).get()).exists; 
  }
  // to get login details for profile screen
  static Future <void> getProfileInfo() async{
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if(user.exists){
        me=ChatUser.fromJson(user.data()!); 
        await getFirebaseMessagingToken();
        // for updating status of user
        Apis.updateActiveStatus(true);
      }else{
        await CreateUser().then((value) => getProfileInfo());
      }
    });
  }
  
// store profile pic in database
  static Future<void> updateProfilePic(File file) async{
  final ext=file.path.split('.').last;
  print('Extension: ${ext}');
 final ref=storage.ref().child('profile_pic/${user.uid}.$ext');
 await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0) {
  print('data transferred: ${p0.bytesTransferred/1000} kb');
 });
 me.image=await ref.getDownloadURL();
 await firestore.collection('users').doc(user.uid).update({'image':me.image});
}


  static Future <void> CreateUser() async{
    final time=DateTime.now().millisecondsSinceEpoch.toString();
    final Chatuser=ChatUser(
     
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hello, I'm using You chat",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: ''
    );
    // return (await firestore.collection('users').doc(auth.currentUser!.uid).get()).exists; 
    return await firestore.collection('users').doc(user.uid).set(Chatuser.toJson()); 
  }
   // for getting id's of known users from firestore database 
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }
 // update user is online/offline
  static Future<void> updateActiveStatus(bool isOnline)async {
    firestore.collection("users").doc(user.uid).update({
      'is_online':isOnline,
      'last_active':DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token':me.pushToken,  
    });
  }
  //                      chat msgs
  // for getting a conversaton id
  static String getConversionId(String id)=>
    user.uid.hashCode <= id.hashCode? '${user.uid}_$id':'${id}_${user.uid}';
  
  // to get all msgs from firestore database for a particular conversionId
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user){
      return firestore.collection('chat/${getConversionId(user.id)}/messages')
      .orderBy('send',descending: true)
      .snapshots();    
  }
// for sending msgs
static Future<void> sendMessage(ChatUser chatuser,String msg,Type type)async {
  final time=DateTime.now().millisecondsSinceEpoch.toString();
  final Messages message=Messages(
    msg: msg, toId: chatuser.id, read: '', 
  type: type, send: time, fromId: user.uid);
  final ref=firestore.collection('chat/${getConversionId(chatuser.id)}/messages');
  await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatuser,type==Type.text?msg:'Image'));
}
// updating status of msg read/unread
static Future<void> updateMessageReadstatus(Messages messages)async {
  firestore.collection('chat/${getConversionId(messages.fromId)}/messages').doc(messages.send)
  .update({'read':DateTime.now().millisecondsSinceEpoch.toString()});

}
// to get the last msg
static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user){
      return firestore.collection('chat/${getConversionId(user.id)}/messages')
      .orderBy('send',descending: true)
      .limit(1).snapshots();    
  }
  // images store in database
  static Future<void> sendChatImage(ChatUser chatUser,File file)async {
final ext=file.path.split('.').last;
   final ref=storage.ref().child
   ('images/${getConversionId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
 await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0) {
  print('data transferred: ${p0.bytesTransferred/1000} kb');
 });
 final imageUrl=await ref.getDownloadURL();
 await sendMessage(chatUser, imageUrl, Type.image);
  }
// for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatuser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatuser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatuser, msg, type));
  }
// getting specific user info
static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser){
      return firestore.collection('users').where('id',isEqualTo: chatUser.id).snapshots();    
  }
 //delete message
  static Future<void> deleteMessage(Messages message) async {
    await firestore
        .collection('chat/${getConversionId(message.toId)}/messages/')
        .doc(message.send)
        .delete();
    if (message.type == Type.image) {
    //   final Reference storageReference = FirebaseStorage.instance
    //     .ref();
    //     .child("products")
    //     .child("product_$productId.png");
    // String downloadURL;
    // UploadTask uploadTask = storageReference.putFile(mFileImage);     
    // downloadURL = await (await uploadTask).ref.getDownloadURL(); 
    
      await storage.refFromURL(message.msg).delete();
    }
  }
  // edit msgs
  static Future<void> updatemessage(Messages message,String updatedMsg) async {
    await firestore
        .collection('chat/${getConversionId(message.toId)}/messages/')
        .doc(message.send)
        .update({'msg':updatedMsg});
    
  }
// for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists
      return false;
    }
  }
}
