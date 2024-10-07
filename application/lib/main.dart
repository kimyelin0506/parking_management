import 'package:flutter/material.dart';
import 'package:parcking_management/firebase_options.dart';
import 'package:parcking_management/screen/choice_Id_screen.dart';
import 'package:parcking_management/screen/home_screen.dart';
import 'package:parcking_management/screen/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  //await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return ChoiceIdScreen();
            }
            return LoginScreen();
          },
        )
        /*
        * StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return ChoiceIdScreen();
            }
            return LoginScreen();
          },
        )
*/
    );
  }
}
