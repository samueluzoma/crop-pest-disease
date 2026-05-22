import 'package:flutter/material.dart';
import 'package:crop_pest_insect_detection/authentication/auth_home.dart';
import 'package:crop_pest_insect_detection/authentication/login.dart';
import 'package:crop_pest_insect_detection/authentication/signup.dart';
import 'package:crop_pest_insect_detection/dashboard.dart';
import 'package:crop_pest_insect_detection/editprofile.dart';
import 'package:crop_pest_insect_detection/profile.dart';
import 'package:crop_pest_insect_detection/splash_screen.dart';
import 'routes.dart'; // Import the Routes file

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splashScreen:
      return MaterialPageRoute(builder: (_) => SplashScreen());
    case Routes.autHomePage:
      return MaterialPageRoute(builder: (_) => AuthHome());
    case Routes.login:
      return MaterialPageRoute(builder: (_) => LoginPage());
    case Routes.profile:
      return MaterialPageRoute(builder: (_) => ProfilePage());
    case Routes.dashboard:
      return MaterialPageRoute(builder: (_) => DashboardPage());
    case Routes.signup:
      return MaterialPageRoute(builder: (_) => SignUpPage());
    case Routes.editprofile:
      final args =
          settings.arguments as Map<String, dynamic>?; // Retrieve the arguments
      return MaterialPageRoute(
        builder: (_) => EditProfilePage(
          firstName: args?['firstName'] ?? '',
          lastName: args?['lastName'] ?? '', // Default to empty string if null
          email: args?['email'] ?? '',
        ),
      );

    default:
      return MaterialPageRoute(builder: (_) => SplashScreen()); // Default route
  }
}
