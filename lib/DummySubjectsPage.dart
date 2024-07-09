// subjects_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';

class SubjectsPage extends StatelessWidget {
  final String regulation;
  final String semester;
  final String department;
  final User? user; // Accept User object as a parameter


  SubjectsPage({
    required this.regulation,
    required this.semester,
    required this.department,
    required this.user,
  });

  List<String> getSubjects() {

    if (regulation == '2017' && semester == '8' && department == 'CSE') {
      return ['Green Computing', 'Professional Ethics'];
    } else if (regulation == '2017' && semester == '7' && department == 'CSE') {
      return ['sub1', 'sub2', 'sub3'];
    } else {
      return []; // Empty list for the default case
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> subjects = getSubjects();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.only(top: 160),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Choose the Subject',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (subjects.isEmpty)
                  Text(
                    'No existing subjects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  )
                else
                  for (String subject in subjects)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/units', arguments: subject);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: Text(
                            subject,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            top: 26,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                    ),
                  ),
                ); // Remove the background color parameter
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : AssetImage('assets/profile.png') as ImageProvider<Object>,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFF26296B),
    );
  }
}
