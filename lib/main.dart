import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:you_chat/auth/login.dart';
import 'package:you_chat/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:you_chat/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    androidProvider: AndroidProvider.debug,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'Showing Message Notifications',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',    
);
print(result);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext  context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      title: 'You Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(       
        primarySwatch: Colors.red,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 1,
          titleTextStyle: GoogleFonts.balooBhai2(fontSize: 25),),      
      ),      
      // home: const Home(),
      home: Splash(),
    );
  }
}


