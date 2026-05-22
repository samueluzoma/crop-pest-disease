import 'package:flutter/material.dart';
// import 'package:mentalhealthchatbot/chatbot/chat_home.dart';
import 'package:crop_pest_insect_detection/routes/route_generator.dart';
import 'package:crop_pest_insect_detection/routes/routes.dart';
// // import 'package:mentalhealthchatbot/splash_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // // Set the FirebaseAuth language code here
  // FirebaseAuth.instance.setLanguageCode(
  //     'en');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.splashScreen,
      onGenerateRoute: generateRoute, // Ensure this line is here
      debugShowCheckedModeBanner: false,
    );
  }
}
