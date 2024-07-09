import 'package:academical/notice_generator.dart';
import 'package:academical/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'question_paper_generator_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  User? _user;

  @override
  void initState() {
    _initializeUser();
    super.initState();
  }

  Future<void> _initializeUser() async {
    User? currentUser = await _auth.getCurrentUser();
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
      });
    }
  }

  Future<void> _showFacultyLoginDialog(BuildContext context) async {
    String enteredPassword = '';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Faculty Only !'),
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              enteredPassword = value;
            },
            decoration: InputDecoration(hintText: 'Faculty Password'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Check if the entered password is empty
                if (enteredPassword.isEmpty) {
                  _showEmptyPasswordPopup(context);
                } else if (enteredPassword == 'agnifaculty@123') {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuestionPaperGeneratorPage()),
                  );
                } else {
                  // Close the login dialog and show a popup for incorrect password
                  Navigator.of(context).pop();
                  _showIncorrectPasswordPopup(context);
                }
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _showFacultyLoginDialog2(BuildContext context) async {
    String enteredPassword = '';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Faculty Only !'),
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              enteredPassword = value;
            },
            decoration: InputDecoration(hintText: 'Faculty Password'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Check if the entered password is empty
                if (enteredPassword.isEmpty) {
                  _showEmptyPasswordPopup(context);
                } else if (enteredPassword == 'agnifaculty@123') {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => noticegenerator()),
                  );
                } else {
                  // Close the login dialog and show a popup for incorrect password
                  Navigator.of(context).pop();
                  _showIncorrectPasswordPopup(context);
                }
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _showEmptyPasswordPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Empty Password'),
          content: Text('Please enter the password.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showIncorrectPasswordPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Incorrect Password'),
          content: Text('The entered password is incorrect. Please try again.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF26296B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _user?.photoURL != null
                  ? NetworkImage(_user!.photoURL!)
                  : AssetImage('assets/profile.png') as ImageProvider<Object>,
            ),

            SizedBox(height: 20),
            Text(
              _user?.email ?? 'user@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show the faculty login dialog
                _showFacultyLoginDialog(context);
              },
              child: const Text('Question Paper Generator'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showFacultyLoginDialog2(context);
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48
                  )
              ),
              child: const Text('Notice Generator'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            _auth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF57B8EE),
            elevation: 8,
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 18,
            ),
          ),
          child: Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}