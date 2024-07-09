import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class noticegenerator extends StatefulWidget {
  @override
  _noticeGeneratorState createState() => _noticeGeneratorState();
}

class _noticeGeneratorState extends State<noticegenerator> {
  bool _isDownloading = false;
  late DateTime _selectedDate = DateTime.now(); // Initialize _selectedDate
  TextEditingController _DeptCodeController = TextEditingController();
  String _DeptCode = '';
  TextEditingController _SubjectController = TextEditingController();
  String _Subject = '';
  TextEditingController _MessageController = TextEditingController();
  String _Message = '';
  String _Responsibility = 'Choose responsibility';

  // Upload the PDF to Firebase Storage
  Future<String> uploadPdfToFirebase(File pdfFile) async {
    try {
      final String fileName =
          'Notice_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child('Notice')
          .child(fileName);
      await storageRef.putFile(pdfFile);
      print('PDF uploaded to Firebase Storage');

      // Get the download URL of the uploaded PDF
      final downloadURL = await storageRef.getDownloadURL();
      print('Download URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Error uploading PDF to Firebase Storage: $e');
      return '';
    }
  }

  // Show the download dialog box
  void _showDownloadDialog(String downloadURL) {
    setState(() {
      _isDownloading = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF26296B),
          title: const Text(
            'Notice Download',
            style: TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Notice has been generated successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await launch(downloadURL);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A9F4),
              ),
              child: const Text(
                'Download',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF26296B),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null && pickedDate != _selectedDate) {
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            'Date: ${_selectedDate.toString().substring(0, 10)}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _DeptCodeController,
                        onChanged: (value) {
                          _DeptCode = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Dept code',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _SubjectController,
                        onChanged: (value) {
                          _Subject = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _MessageController,
                        onChanged: (value) {
                          setState(() {
                            _Message = value;
                          });
                        },
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButton<String>(
                          value: _Responsibility,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _Responsibility = newValue;
                              });
                            }
                          },
                          style: const TextStyle(color: Colors.blue),
                          items: <String>[
                            'Choose responsibility',
                            'Project Co-ordinator',
                            'Supervisor',
                            'Incharge'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: !_isDownloading
                    ? () async {
                  if (_DeptCode.isEmpty || _Subject.isEmpty || _Responsibility == 'Choose responsibility') {
                    // Show popup if any of the required fields are empty
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF26296B),
                          title: const Text('Error',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text('Enter all of the following information.',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      _isDownloading = true;
                    });

                    final pdf = pdfLib.Document();
                    final ByteData imageData =
                    await rootBundle.load('assets/Strip.png');
                    final Uint8List bytes =
                    imageData.buffer.asUint8List();
                    final pdfLib.MemoryImage image =
                    pdfLib.MemoryImage(bytes);

                    pdf.addPage(
                      pdfLib.Page(
                        build: (context) {
                          const double pageWidth = 595.0;
                          const double pageHeight = 842.0;
                          const double margin = 20.0;
                          const double imageHeight = 55.0;

                          return pdfLib.Container(
                            width: pageWidth,
                            height: pageHeight,
                            alignment: pdfLib.Alignment.center,
                            child: pdfLib.Container(
                              width: pageWidth - (2 * margin),
                              height: pageHeight - (2 * margin),
                              decoration: pdfLib.BoxDecoration(
                                border: pdfLib.Border.all(
                                  width: 1,
                                ),
                              ),
                              padding:
                              const pdfLib.EdgeInsets.all(margin),
                              child: pdfLib.Column(
                                crossAxisAlignment:
                                pdfLib.CrossAxisAlignment.start,
                                children: [
                                  pdfLib.Container(
                                    width: double.infinity,
                                    height: imageHeight,
                                    child: pdfLib.Image(
                                        image,
                                        fit: pdfLib.BoxFit.cover),
                                  ),
                                  pdfLib.SizedBox(height: 10),
                                  pdfLib.Row(
                                    mainAxisAlignment:
                                    pdfLib.MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      pdfLib.Text(
                                        _DeptCode,
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      pdfLib.Text(
                                        'Date: ${_selectedDate.toString().substring(0, 10)}',
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  pdfLib.SizedBox(height: 10),
                                  pdfLib.Align(
                                    alignment: pdfLib.Alignment.center,
                                    child: pdfLib.Text(
                                      'CIRCULAR',
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 14,
                                        decoration:
                                        pdfLib.TextDecoration
                                            .underline,
                                      ),
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 10),
                                  pdfLib.Row(
                                    crossAxisAlignment:
                                    pdfLib.CrossAxisAlignment.start,
                                    children: [
                                      pdfLib.SizedBox(width: 20),
                                      pdfLib.Expanded(
                                        child: pdfLib.Text(
                                          _Subject ?? '',
                                          style: pdfLib.TextStyle(
                                            fontWeight:
                                            pdfLib.FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  pdfLib.SizedBox(height: 10),
                                  pdfLib.Container(
                                    padding: pdfLib.EdgeInsets.only(left: 20), // Add padding to move the message away from the margin
                                    child: pdfLib.Text(
                                      _Message ?? '',
                                      style: pdfLib.TextStyle(
                                        fontWeight: pdfLib.FontWeight.normal, // Use the same styling as the subject
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 50),
                                  pdfLib.Row(
                                    // Row to display "Course Teacher" and "HOD" headings
                                    mainAxisAlignment: pdfLib
                                        .MainAxisAlignment.spaceBetween,
                                    children: [
                                      pdfLib.Text(
                                        // Left-aligned heading
                                        '      $_Responsibility',
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      pdfLib.Text(
                                        // Right-aligned heading
                                        '     HOD          ',
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );

                    final String dir =
                        (await getApplicationDocumentsDirectory()).path;
                    final String path = '$dir/Notice.pdf';
                    final File file = File(path);
                    await file.writeAsBytes(await pdf.save());
                    print('PDF saved to $path');

                    // Upload the PDF to Firebase Storage
                    String downloadURL =
                    await uploadPdfToFirebase(file);

                    // Show dialog with download link
                    _showDownloadDialog(downloadURL);
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF57B8EE),
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 18,
                  ),
                  textStyle: const TextStyle(color: Colors.white),
                ),
                child: const Text(
                  'Generate Notice',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
