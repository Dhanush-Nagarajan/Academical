// details_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';

class DetailsPage extends StatefulWidget {
  final User? user;
  DetailsPage({required this.user});

  @override
  _DetailsPageState createState() => _DetailsPageState(user: user);
}


class _DetailsPageState extends State<DetailsPage> {
  final User? user;

  _DetailsPageState({required this.user});

  String selectedRegulation = '2017';
  String selectedSemester = '1';
  String selectedDepartment = 'CSE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                const SizedBox(height: 120),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        'Choose Details',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    buildDropdownRow(
                      label: 'Regulation',
                      value: selectedRegulation,
                      items: ['2017', '2021'],
                      onChanged: (value) {
                        setState(() {
                          selectedRegulation = value!;
                        });
                      },
                    ),

                    buildDropdownRow(
                      label: 'Semester',
                      value: selectedSemester,
                      items: [for (int i = 1; i <= 8; i++) i.toString()],
                      onChanged: (value) {
                        setState(() {
                          selectedSemester = value!;
                        });
                      },
                    ),

                    buildDropdownRow(
                      label: 'Department',
                      value: selectedDepartment,
                      items: ['EEE', 'CSE', 'ASE'],
                      onChanged: (value) {
                        setState(() {
                          selectedDepartment = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedRegulation == '2017' &&
                            selectedSemester == '8' &&
                            selectedDepartment == 'CSE') {
                          // Navigate to the subjects page with selected details
                          Navigator.pushNamed(
                            context,
                            '/subjects',
                            arguments: {
                              'regulation': selectedRegulation,
                              'semester': selectedSemester,
                              'department': selectedDepartment,
                            },
                          );
                        }else if (selectedRegulation == '2017' &&
                            selectedSemester == '7' &&
                            selectedDepartment == 'CSE') {

                          Navigator.pushNamed(
                            context,
                            '/subjects',
                            arguments: {
                              'regulation': selectedRegulation,
                              'semester': selectedSemester,
                              'department': selectedDepartment,
                            },
                          );

                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter valid details'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : const AssetImage('assets/profile.png') as ImageProvider<Object>,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFF26296B),
    );
  }
//building the widget for drop down
  Widget buildDropdownRow({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width > 600 ? 200 : 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
              dropdownColor: Colors.lightBlue,
              underline: Container(),
            ),
          ),
        ],
      ),
    );
  }
}
