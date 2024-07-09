import 'package:flutter/material.dart';
import 'package:academical/sign_in_page.dart';

class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Color(0xFF26296B), // Set dark blue background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 78, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image Section
                Container(
                  width: 755,
                  height: 429,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/img.png"),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [],
                  ),
                ),
                SizedBox(height: 40), // Add spacing between the image and the text
                // Text Section
                Text(
                  "Want to learn and study more...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Alata',
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 1,
                        color: Color(0xFFA0BEF2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40), // Add spacing between the text and the button
                // Button Section
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the sign-in page
                    Navigator.push(
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Alata',
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 1,
                            color: Color(0xFFA0BEF2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}