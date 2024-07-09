import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';

class UnitsPage extends StatelessWidget {
  final User? user; // Accept User object as a parameter

  UnitsPage({required this.user});
  // Define a data structure to hold information about subjects, units, and routes
  final Map<String, Map<String, String>> subjects = {
    'Green Computing': {
      'Unit 1': '/topics',
      'Unit 2': '/topics_green_computing_unit2',
      'Unit 3': '/topics_green_computing_unit3',
      'Unit 4': '/topics_green_computing_unit4',
      'Unit 5': '/topics_green_computing_unit5',
    },
    'Professional Ethics': {
      'Unit 1': '/topics_professional_ethics_unit1',
      'Unit 2': '/topics_professional_ethics_unit2',
      'Unit 3': '/topics_professional_ethics_unit3',
      'Unit 4': '/topics_professional_ethics_unit4',
      'Unit 5': '/topics_professional_ethics_unit5',
    },
    'sub1': {
      'Unit 1': '/topics_professional_ethics_unit1',
      'Unit 2': '/topics_professional_ethics_unit2',
      'Unit 3': '/topics_professional_ethics_unit3',
      'Unit 4': '/topics_professional_ethics_unit4',
      'Unit 5': '/topics_professional_ethics_unit5',
    },
    'sub2': {
      'Unit 1': '/topics_professional_ethics_unit1',
      'Unit 2': '/topics_professional_ethics_unit2',
      'Unit 3': '/topics_professional_ethics_unit3',
      'Unit 4': '/topics_professional_ethics_unit4',
      'Unit 5': '/topics_professional_ethics_unit5',
    },
    'sub3': {
      'Unit 1': '/topics_professional_ethics_unit1',
      'Unit 2': '/topics_professional_ethics_unit2',
      'Unit 3': '/topics_professional_ethics_unit3',
      'Unit 4': '/topics_professional_ethics_unit4',
      'Unit 5': '/topics_professional_ethics_unit5',
    },
    // Add more subjects here
  };
  @override
  Widget build(BuildContext context) {
    final String subject = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView( // Place SingleChildScrollView here
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 160),
                  Center(
                    child: Text(
                      'Choose the Unit for $subject',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Generate unit cards dynamically based on subjects data
                  for (String unit in subjects[subject]!.keys)
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                          color: Colors.lightBlue,
                          child: ListTile(
                            title: Center(
                              child: Text(
                                unit,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onTap: () {
                              // Navigate to the dynamically generated route
                              Navigator.pushNamed(
                                context,
                                subjects[subject]![unit]!,
                                arguments: {
                                  'unit': unit,
                                  'subject': subject,
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                ],
              ),
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
                    builder: (context) => ProfilePage(),
                  ),
                );
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
