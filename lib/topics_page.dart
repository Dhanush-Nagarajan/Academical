// topics_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class TopicsPage extends StatelessWidget {
  final User? user; // Accept User object as a parameter

  TopicsPage({required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned(
                top: 160,
                child: Container(
                  height: MediaQuery.of(context).size.height - 160,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Topics',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        TopicsExpandableWidget(
                          backgroundColor: Color(0xFF26296B),
                          titles: ['Green computing', 'Green IT Fundamentals', 'IT metrices and measurement', 'Green IT Strategies'],
                          subtitleLinks: {
                            'Study': [
                              'https://drive.google.com/file/d/1r_yTHElv0Gc3KF3QTFZr38GtQtnu7GoD/view?usp=drive_link',
                              'https://drive.google.com/file/d/1NOm_kgNFVkN-m0Yb3RrjCBuWF4fHH6q_/view?usp=drive_link',
                              'https://drive.google.com/file/d/1sLkpjE2ZYyvsLaOyOQzThZhFn_gHJbUU/view?usp=drive_link',
                              'https://drive.google.com/file/d/1WdXTvGjh1lh7dL0SChhaAObN0y0Lf67t/view?usp=drive_link'
                            ],
                            'Learn': [
                              'https://drive.google.com/file/d/17AEJNeWKOXFNS3Es_bPmuj4tj2Q4TAiP/view?usp=drive_link',
                              'https://drive.google.com/file/d/1oQf_gkmwylEcCUWCS3Jc1cpzD7v3Gf5z/view?usp=drive_link',
                              'https://drive.google.com/file/d/1XO0SiuII-DQs9UHKKmC7X4ndhkKu0Mx9/view?usp=drive_link',
                              'https://drive.google.com/file/d/1Lv6Q14NtQ4NwL7q0eEV0DCLlnqz4ho_J/view?usp=drive_link'
                            ],
                          },
                        ),
                      ],
                    ),
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
                      MaterialPageRoute(builder: (context) => ProfilePage()),
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
        ),
      ),
      backgroundColor: Color(0xFF26296B),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
          icon: Icon(
            Icons.arrow_back, // Icon pointing left
            color: Colors.white, // Set the color of the icon
          ),
          label: Text(''), // Empty text to hide the label
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}



class ExpandableTopicWidget extends StatefulWidget {
  final String title;
  final List<String> topicHeadings;
  final Map<String, String> subtitleLinks;

  ExpandableTopicWidget({
    required this.title,
    required this.topicHeadings,
    required this.subtitleLinks,
  });

  @override
  _ExpandableTopicWidgetState createState() => _ExpandableTopicWidgetState();
}

class _ExpandableTopicWidgetState extends State<ExpandableTopicWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            width: 310,
            height: 50,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(35),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...widget.topicHeadings
            .asMap()
            .entries
            .map(
              (entry) => Container(
            width: 310,
            height: 40,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                _launchGoogleDriveLink(widget.subtitleLinks[entry.value]!);
              },
              child: Center(
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Function to launch Google Drive link
  void _launchGoogleDriveLink(String link) async {
    try {
      Uri uri = Uri.parse(link);
      bool launched = await launch(
        uri.toString(),
        forceSafariVC: false,
        forceWebView: false,
      );

      if (!launched) {
        print('Failed to launch URL');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
//widget
class TopicsExpandableWidget extends StatelessWidget {
  final Color backgroundColor;
  final List<String> titles;
  final Map<String, List<String>> subtitleLinks;

  TopicsExpandableWidget({
    required this.backgroundColor,
    required this.titles,
    required this.subtitleLinks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: titles.map((title) {
        return ExpandableTopicWidget(
          title: title,
          topicHeadings: subtitleLinks.keys.toList(),
          subtitleLinks: Map.fromEntries(subtitleLinks.entries.map(
                (entry) => MapEntry(entry.key, entry.value[titles.indexOf(title)]),
          )),
        );
      }).toList(),
    );
  }
}
