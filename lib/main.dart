import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_auth_services.dart';
import 'notice_generator.dart';
import 'sign_up_page.dart';
import 'DummySubjectsPage.dart';
import 'DummyUnitsPage.dart';
import 'home_page.dart';
import 'sign_in_page.dart';
import 'topics_page.dart';
import 'profile_page.dart';
import 'details_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'question_paper_generator_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Check if the user is already logged in
  FirebaseAuthService authService = FirebaseAuthService();
  User? user = FirebaseAuth.instance.currentUser; // Retrieve current user
  bool isLoggedIn = await authService.isUserLoggedIn();
  runApp(MyApp(initialRoute: isLoggedIn ? '/details' : '/home', user: user));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final User? user;

  const MyApp({Key? key, required this.initialRoute, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => MyHomePage(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/topics': (context) => TopicsPage(user: user),
        '/profile': (context) => ProfilePage(),
        '/units': (context) => UnitsPage(user: user),
        '/subjects': (context) {
          final Map<String, String>? details =
          ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
          if (details == null) {
            // Handle null arguments, you might want to navigate back or show an error message
            Navigator.pop(context);
            return Container();
          }
          return SubjectsPage(
              regulation: details['regulation'] ?? '',
              semester: details['semester'] ?? '',
              department: details['department'] ?? '',
              user: user
          );
        },
        '/details': (context) => DetailsPage(user: user),
        '/question_paper_generator': (context) => QuestionPaperGeneratorPage(),
        '/noticegenerator':(context) => noticegenerator(),
      },
    );
  }
}


