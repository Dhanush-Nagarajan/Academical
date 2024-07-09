import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class QuestionPaperGeneratorPage extends StatefulWidget {
  const QuestionPaperGeneratorPage({super.key});

  @override
  _QuestionPaperGeneratorPageState createState() =>
      _QuestionPaperGeneratorPageState();
}

class _QuestionPaperGeneratorPageState
    extends State<QuestionPaperGeneratorPage> {
  String _selectedSubject = 'Choose Subject';
  final List<String> subjects = [
    'Green computing',
    'Professional Ethics',
    'Hospital Management',
    'Software project management',
    'Cryptographic and network security',
    'Cloud Computing',
    'Physics for Information Science',
    'Programming in C',
    'Basic Electrical & Electronics Engineering',
    'Digital Principles and Computer Organization',
    'Foundations of Data Science',
    'Data Structures',
    'Artificial Intelligence and Machine Learning',
    'Object Oriented Programming',
    'Database Management Systems',
    'Algorithms'
  ];
  String _selectedType = 'Choose Assessment';
  String _selectedSet = 'Choose Set';
  String _selectedDivision = 'Choose Division';
  bool _isDownloading = false;
  late DateTime _selectedDate = DateTime.now();
  late String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);

  List<Map<String, dynamic>> dataset = [];
  String coValue1 = '';
  String coValue2 = '';
  String coValue3 = '';
  String coValue4 = '';
  String coValue5 = '';

  Future<void> loadQuestionsFromCSV() async {
    final String csvString =
    await rootBundle.loadString('assets/questions.csv');
    List<List<dynamic>> csvList = const CsvToListConverter().convert(csvString);

    dataset = csvList
        .skip(1)
        .map((row) => {
      "subject": row[0].toString(),
      "subjectcode": row[1].toString(),
      "Department": row[2].toString(),
      "year": row[3].toString(),
      "co": row[4].toString(),
      "unit": int.parse(row[5].toString()),
      "markType": int.parse(row[6].toString()),
      "question": row[7].toString(),
      "BT":row[8].toString(),
    })
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadQuestionsFromCSV();
  }

  String getSubjectCode() {
    // Find the subject code based on the selected subject
    Map<String, dynamic> subjectData = dataset.firstWhere(
          (data) => data['subject'] == _selectedSubject,
      orElse: () =>
      {'subjectcode': ''}, // Return an empty map with empty subject code
    );

    return subjectData['subjectcode'].toString();
  }

  String getDepartment() {
    // Find the subject code based on the selected subject
    Map<String, dynamic> subjectData = dataset.firstWhere(
          (data) => data['subject'] == _selectedSubject,
      orElse: () =>
      {'Department': ''}, // Return an empty map with empty subject code
    );

    return subjectData['Department'].toString();
  }

  String getYear() {
    // Find the subject code based on the selected subject
    Map<String, dynamic> subjectData = dataset.firstWhere(
          (data) => data['subject'] == _selectedSubject,
      orElse: () => {'year': ''}, // Return an empty map with empty subject code
    );

    return subjectData['year'].toString();
  }

  String getFormattedFileName() {
    String subjectName_ = _selectedSubject.toLowerCase().replaceAll(' ', '');
    String assessmentType = _selectedType.toLowerCase().replaceAll('-', '');
    String setSelected = _selectedSet.toLowerCase();

    return '$subjectName_-$assessmentType-$setSelected.pdf'; // Include set in the file name
  }

  void _showSelectionDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF26296B),
          title: const Text(
            'Selection Error',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Restore the button after the popup is closed
                setState(() {
                  _isDownloading = false;
                });
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  List<String> generateQuestionPaper() {
    // Filter dataset based on selected subject
    List<Map<String, dynamic>> filteredDataset =
    dataset.where((data) => data['subject'] == _selectedSubject).toList();
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(formattedDate);

    // Extract CO values from the first five rows
    if (filteredDataset.isNotEmpty) {
      coValue1 = filteredDataset[0]['co'];
    }
    if (filteredDataset.length > 1) {
      coValue2 = filteredDataset[1]['co'];
    }
    if (filteredDataset.length > 2) {
      coValue3 = filteredDataset[2]['co'];
    }
    if (filteredDataset.length > 3) {
      coValue4 = filteredDataset[3]['co'];
    }
    if (filteredDataset.length > 4) {
      coValue5 = filteredDataset[4]['co'];
    }

    if (_selectedSubject == 'Choose Subject' &&
        _selectedType == 'Choose Assessment' &&
        _selectedSet == 'Choose Set' &&
        parsedDate.isAtSameMomentAs(DateTime.now()) && _selectedDivision=='Choose Division') {
      _showSelectionDialog(
          'Please select a subject type, assessment type, set and an Examination date.');
    } else if (_selectedSubject == 'Choose Subject' ||
        _selectedType == 'Choose Assessment' ||
        _selectedSet == 'Choose Set' ||
        parsedDate.isAtSameMomentAs(DateTime.now()) || _selectedDivision=='Choose Division') {
      _showSelectionDialog('Please select all of the specifications.');
      return [];
    }

    if (_selectedType == "MODEL") {
      // Only execute the generation logic for 'MODEL'
      List<Map<String, dynamic>> filteredData = dataset
          .where((entry) => entry["subject"] == _selectedSubject)
          .toList();

      // Separate 2 mark, 13 mark, and 15 mark questions
      List<Map<String, dynamic>> twoMarkQuestions = [];
      List<Map<String, dynamic>> thirteenMarkQuestions = [];
      List<Map<String, dynamic>> fifteenMarkQuestions = [];

      for (var entry in filteredData) {
        if (entry['markType'] == 2) {
          twoMarkQuestions.add(entry);
        } else if (entry['markType'] == 13) {
          thirteenMarkQuestions.add(entry);
        } else if (entry['markType'] == 15) {
          fifteenMarkQuestions.add(entry);
        }
      }
      // Group 2 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedTwoMarkData = {};
      for (var entry in twoMarkQuestions) {
        int unit = entry["unit"];
        groupedTwoMarkData.putIfAbsent(unit, () => []);
        groupedTwoMarkData[unit]!.add(entry);
      }

      // Shuffle 2 mark questions within each unit
      groupedTwoMarkData.forEach((unit, questions) {
        questions.shuffle();
      });

      // Track the number of selected 2 mark questions for each unit
      Map<int, int> selectedTwoMarkCounts = {};
      List<String> questionsList = [];

      // Select two random 2 mark questions from each unit in order from 1 to 5
      int questionNumber = 1;
      for (int unit = 1; unit <= 5; unit++) {
        if (groupedTwoMarkData.containsKey(unit) &&
            groupedTwoMarkData[unit]!.isNotEmpty) {
          questionsList.add(
            "$questionNumber) ${groupedTwoMarkData[unit]!.removeLast()["question"]}",
          );
          selectedTwoMarkCounts[unit] = (selectedTwoMarkCounts[unit] ?? 0) + 1;
          questionNumber++;
        }

        if (selectedTwoMarkCounts[unit]! < 2 &&
            groupedTwoMarkData.containsKey(unit) &&
            groupedTwoMarkData[unit]!.isNotEmpty) {
          questionsList.add(
            "$questionNumber) ${groupedTwoMarkData[unit]!.removeLast()["question"]}",
          );
          selectedTwoMarkCounts[unit] = (selectedTwoMarkCounts[unit] ?? 0) + 1;
          questionNumber++;
        }
      }

      // Format the 2 mark questions
      String twoMarkQuestionPaper = questionsList.join("\n\n");

      // Group 13 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedThirteenMarkData = {};
      for (var entry in thirteenMarkQuestions) {
        int unit = entry["unit"];
        groupedThirteenMarkData.putIfAbsent(unit, () => []);
        groupedThirteenMarkData[unit]!.add(entry);
      }

// Shuffle 13 mark questions within each unit
      groupedThirteenMarkData.forEach((unit, questions) {
        questions.shuffle();
      });

// Track the number of selected 13 mark questions for each unit

// Select two random 13 mark questions from each unit in order from 1 to 5
      for (int unit = 1; unit <= 5; unit++) {
        List<String> unitQuestionsList = [];

        if (groupedThirteenMarkData.containsKey(unit) &&
            groupedThirteenMarkData[unit]!.isNotEmpty) {
          unitQuestionsList.add(
            "${questionNumber}) a) ${groupedThirteenMarkData[unit]!.removeLast()["question"]}",
          );
          unitQuestionsList.add(
              "${"".padLeft(75, " ")}(OR)"); // Padding for center alignment
          questionNumber++;
        }

        if (groupedThirteenMarkData.containsKey(unit) &&
            groupedThirteenMarkData[unit]!.isNotEmpty) {
          unitQuestionsList.add(
            "b) ${groupedThirteenMarkData[unit]!.removeLast()["question"]}",
          );
        }

        questionsList.addAll(unitQuestionsList);
      }

// Format the 13 mark questions without an extra line space after the heading
      String thirteenMarkQuestionPaper = questionsList.sublist(10).join('\n\n');

      // Group 15 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedFifteenMarkData = {};
      for (var entry in fifteenMarkQuestions) {
        int unit = entry["unit"];
        groupedFifteenMarkData.putIfAbsent(unit, () => []);
        groupedFifteenMarkData[unit]!.add(entry);
      }

      // Shuffle 15 mark questions within each unit
      groupedFifteenMarkData.forEach((unit, questions) {
        questions.shuffle();
      });

      // Track the number of selected 15 mark questions for each unit
      List<Map<String, dynamic>> selectedFifteenMarkQuestions = [];

      // Select the first 15 mark question from unit 1, 2, or 3
      for (int unit = 1; unit <= 3; unit++) {
        if (groupedFifteenMarkData.containsKey(unit) &&
            groupedFifteenMarkData[unit]!.isNotEmpty) {
          selectedFifteenMarkQuestions.add(
            groupedFifteenMarkData[unit]!.removeLast(),
          );
          break;
        }
      }

      // Select the second 15 mark question from unit 3, 4, or 5
      for (int unit = 3; unit <= 5; unit++) {
        if (groupedFifteenMarkData.containsKey(unit) &&
            groupedFifteenMarkData[unit]!.isNotEmpty) {
          selectedFifteenMarkQuestions.add(
            groupedFifteenMarkData[unit]!.removeLast(),
          );
          break;
        }
      }

      // Shuffle the selected 15 mark questions
      selectedFifteenMarkQuestions.shuffle();

      // Format the 15 mark questions
      String fifteenMarkQuestionPaper =
          "$questionNumber) a) ${selectedFifteenMarkQuestions[0]["question"]}\n\n"
          "${"".padLeft(75, " ")}(OR)\n\n"
          "b) ${selectedFifteenMarkQuestions[1]["question"]}";

      // Return a list containing all sets of questions
      return [
        twoMarkQuestionPaper,
        thirteenMarkQuestionPaper,
        fifteenMarkQuestionPaper
      ];
    } else if (_selectedType == 'IAT-1') {
      // Use the new logic for 'IAT-1'
      List<Map<String, dynamic>> filteredData = dataset
          .where((entry) => entry['subject'] == _selectedSubject)
          .toList();

      // Separate 2 mark, 13 mark, and 15 mark questions
      List<Map<String, dynamic>> twoMarkQuestions = [];
      List<Map<String, dynamic>> thirteenMarkQuestions = [];
      List<Map<String, dynamic>> fifteenMarkQuestions = [];

      for (var entry in filteredData) {
        if (entry['markType'] == 2) {
          twoMarkQuestions.add(entry);
        } else if (entry['markType'] == 13) {
          thirteenMarkQuestions.add(entry);
        } else if (entry['markType'] == 15) {
          fifteenMarkQuestions.add(entry);
        }
      }

      // Group 2 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedTwoMarkData = {};
      for (var entry in twoMarkQuestions) {
        int unit = entry['unit'];
        groupedTwoMarkData.putIfAbsent(unit, () => []);
        groupedTwoMarkData[unit]!.add(entry);
      }

      // Shuffle 2 mark questions within each unit
      groupedTwoMarkData.forEach((unit, questions) {
        questions.shuffle();
      });

      // Track the number of selected 2 mark questions for each unit
      List<String> questionsList = [];

      // Select five random 2 mark questions from unit 1
      for (int i = 0; i < 5; i++) {
        if (groupedTwoMarkData.containsKey(1) &&
            groupedTwoMarkData[1]!.isNotEmpty) {
          questionsList.add(
            '${i + 1}) ${groupedTwoMarkData[1]!.removeLast()['question']}',
          );
        }
      }

      // Select five random 2 mark questions from unit 2
      for (int i = 0; i < 5; i++) {
        if (groupedTwoMarkData.containsKey(2) &&
            groupedTwoMarkData[2]!.isNotEmpty) {
          questionsList.add(
            '${i + 6}) ${groupedTwoMarkData[2]!.removeLast()['question']}',
          );
        }
      }

      // Format the 2 mark questions
      String twoMarkQuestionPaper = questionsList.join('\n\n');

      // Group 13 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedThirteenMarkData = {};
      for (var entry in thirteenMarkQuestions) {
        int unit = entry['unit'];
        groupedThirteenMarkData.putIfAbsent(unit, () => []);
        groupedThirteenMarkData[unit]!.add(entry);
      }

      // Track the number of selected 13 mark questions for each unit
      List<String> thirteenMarkQuestionsList = [];

      // Select the first and second pairs from unit 1
      List<Map<String, dynamic>> unit1Questions =
          groupedThirteenMarkData[1] ?? [];
      unit1Questions.shuffle();
      for (int i = 0; i < 2; i++) {
        if (unit1Questions.isNotEmpty) {
          thirteenMarkQuestionsList.add(
            '${10 + i + 1}) a) ${unit1Questions.removeLast()['question']}',
          );
          thirteenMarkQuestionsList.add("${"".padLeft(75, " ")}(OR)");
          thirteenMarkQuestionsList.add(
            '   b) ${unit1Questions.removeLast()['question']}',
          );
        }
      }

// Select the third pair from units 1 and 2
      List<Map<String, dynamic>> unit2Questions =
          groupedThirteenMarkData[2] ?? [];
      unit2Questions.shuffle();
      if (unit1Questions.isNotEmpty) {
        thirteenMarkQuestionsList.add(
          '13) a) ${unit1Questions.removeLast()['question']}',
        );
        thirteenMarkQuestionsList.add("${"".padLeft(75, " ")}(OR)");
      }
      if (unit2Questions.isNotEmpty) {
        thirteenMarkQuestionsList.add(
          '    b) ${unit2Questions.removeLast()['question']}',
        );
      }

// Select the fourth and fifth pairs from unit 2
      for (int i = 0; i < 2; i++) {
        if (unit2Questions.isNotEmpty) {
          thirteenMarkQuestionsList.add(
            '${13 + i + 1}) a) ${unit2Questions.removeLast()['question']}',
          );
          thirteenMarkQuestionsList.add("${"".padLeft(75, " ")}(OR)");
          thirteenMarkQuestionsList.add(
            '    b) ${unit2Questions.removeLast()['question']}',
          );
        }
      }

// Format the 13 mark questions
      String thirteenMarkQuestionPaper = thirteenMarkQuestionsList.join('\n\n');

      // Group 15 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedFifteenMarkData = {};
      for (var entry in fifteenMarkQuestions) {
        int unit = entry['unit'];
        groupedFifteenMarkData.putIfAbsent(unit, () => []);
        groupedFifteenMarkData[unit]!.add(entry);
      }

// Track the number of selected 15 mark questions for each unit
      List<Map<String, dynamic>> selectedFifteenMarkQuestions = [];
      int questionNumber = 16;

// Select the 15 mark question from unit 1
      if (groupedFifteenMarkData.containsKey(1) &&
          groupedFifteenMarkData[1]!.isNotEmpty) {
        selectedFifteenMarkQuestions.add(
          groupedFifteenMarkData[1]!.removeLast(),
        );
      }

// Select the 15 mark question from unit 2
      if (groupedFifteenMarkData.containsKey(2) &&
          groupedFifteenMarkData[2]!.isNotEmpty) {
        selectedFifteenMarkQuestions.add(
          groupedFifteenMarkData[2]!.removeLast(),
        );
      }

// Shuffle the selected 15 mark questions
      selectedFifteenMarkQuestions.shuffle();

// Format the 15 mark questions
      String fifteenMarkQuestionPaper =
          '${questionNumber++}) a) ${selectedFifteenMarkQuestions[0]['question']}\n\n'
          "${"".padLeft(75, " ")}(OR)\n\n"
          'b) ${selectedFifteenMarkQuestions[1]['question']}';
      // Return a list containing the 2 mark, 13 mark, and 15 mark question paper
      return [
        twoMarkQuestionPaper,
        thirteenMarkQuestionPaper,
        fifteenMarkQuestionPaper
      ];
    } else if (_selectedType == 'IAT-2') {
      List<Map<String, dynamic>> filteredData = dataset
          .where((entry) => entry['subject'] == _selectedSubject)
          .toList();

// Separate 2 mark, 13 mark, and 15 mark questions
      List<Map<String, dynamic>> twoMarkQuestions = [];
      List<Map<String, dynamic>> thirteenMarkQuestions = [];
      List<Map<String, dynamic>> fifteenMarkQuestions = [];

      for (var entry in filteredData) {
        if (entry['markType'] == 2) {
          twoMarkQuestions.add(entry);
        } else if (entry['markType'] == 13) {
          thirteenMarkQuestions.add(entry);
        } else if (entry['markType'] == 15) {
          fifteenMarkQuestions.add(entry);
        }
      }

// Group 2 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedTwoMarkData = {};
      for (var entry in twoMarkQuestions) {
        int unit = entry['unit'];
        groupedTwoMarkData.putIfAbsent(unit, () => []);
        groupedTwoMarkData[unit]!.add(entry);
      }

// Shuffle 2 mark questions within each unit
      groupedTwoMarkData.forEach((unit, questions) {
        questions.shuffle();
      });

// Track the number of selected 2 mark questions for each unit
      List<String> questionsList = [];

// Select five random 2 mark questions from unit 3
      for (int i = 0; i < 5; i++) {
        if (groupedTwoMarkData.containsKey(3) &&
            groupedTwoMarkData[3]!.isNotEmpty) {
          questionsList.add(
            '${i + 1}) ${groupedTwoMarkData[3]!.removeLast()['question']}',
          );
        }
      }

// Select five random 2 mark questions from unit 4
      for (int i = 0; i < 5; i++) {
        if (groupedTwoMarkData.containsKey(4) &&
            groupedTwoMarkData[4]!.isNotEmpty) {
          questionsList.add(
            '${i + 6}) ${groupedTwoMarkData[4]!.removeLast()['question']}',
          );
        }
      }

// Format the 2 mark questions
      String twoMarkQuestionPaper = questionsList.join('\n\n');

// Group 13 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedThirteenMarkData = {};
      for (var entry in thirteenMarkQuestions) {
        int unit = entry['unit'];
        groupedThirteenMarkData.putIfAbsent(unit, () => []);
        groupedThirteenMarkData[unit]!.add(entry);
      }

// Track the number of selected 13 mark questions for each unit
      List<String> thirteenMarkQuestionsList = [];

// Select the first and second pairs from unit 3
      List<Map<String, dynamic>> unit3Questions =
          groupedThirteenMarkData[3] ?? [];
      unit3Questions.shuffle();
      for (int i = 0; i < 2; i++) {
        if (unit3Questions.isNotEmpty) {
          thirteenMarkQuestionsList.add(
            '${10 + i + 1}) a) ${unit3Questions.removeLast()['question']}',
          );
          thirteenMarkQuestionsList.add("${"".padLeft(75, " ")}(OR)");
          thirteenMarkQuestionsList.add(
            '   b) ${unit3Questions.removeLast()['question']}',
          );
        }
      }

// Select the third pair from units 3 and 4
      List<Map<String, dynamic>> unit4Questions =
          groupedThirteenMarkData[4] ?? [];
      unit4Questions.shuffle();
      if (unit3Questions.isNotEmpty) {
        thirteenMarkQuestionsList.add(
          '13) a) ${unit3Questions.removeLast()['question']}',
        );
        thirteenMarkQuestionsList.add("${"".padLeft(75, " ")}(OR)");
      }
      if (unit4Questions.isNotEmpty) {
        thirteenMarkQuestionsList.add(
          '    b) ${unit4Questions.removeLast()['question']}',
        );
      }

// Select the fourth and fifth pairs from unit 4
      for (int i = 0; i < 2; i++) {
        if (unit4Questions.isNotEmpty) {
          thirteenMarkQuestionsList.add(
            '${13 + i + 1}) a) ${unit4Questions.removeLast()['question']}',
          );
          thirteenMarkQuestionsList.add("${"".padLeft(75, " ")}(OR)");
          thirteenMarkQuestionsList.add(
            '    b) ${unit4Questions.removeLast()['question']}',
          );
        }
      }

// Format the 13 mark questions
      String thirteenMarkQuestionPaper = thirteenMarkQuestionsList.join('\n\n');

// Group 15 mark questions by unit
      Map<int, List<Map<String, dynamic>>> groupedFifteenMarkData = {};
      for (var entry in fifteenMarkQuestions) {
        int unit = entry['unit'];
        groupedFifteenMarkData.putIfAbsent(unit, () => []);
        groupedFifteenMarkData[unit]!.add(entry);
      }

// Track the number of selected 15 mark questions for each unit
      List<Map<String, dynamic>> selectedFifteenMarkQuestions = [];
      int questionNumber = 16;

// Select the 15 mark question from unit 3
      if (groupedFifteenMarkData.containsKey(3) &&
          groupedFifteenMarkData[3]!.isNotEmpty) {
        selectedFifteenMarkQuestions.add(
          groupedFifteenMarkData[3]!.removeLast(),
        );
      }

// Select the 15 mark question from unit 4
      if (groupedFifteenMarkData.containsKey(4) &&
          groupedFifteenMarkData[4]!.isNotEmpty) {
        selectedFifteenMarkQuestions.add(
          groupedFifteenMarkData[4]!.removeLast(),
        );
      }

// Shuffle the selected 15 mark questions
      selectedFifteenMarkQuestions.shuffle();

// Format the 15 mark questions
      String fifteenMarkQuestionPaper =
          '${questionNumber++}) a) ${selectedFifteenMarkQuestions[0]['question']}\n\n'
          "${"".padLeft(75, " ")}(OR)\n\n"
          'b) ${selectedFifteenMarkQuestions[1]['question']}';

// Return a list containing the 2 mark, 13 mark, and 15 mark question paper
      return [
        twoMarkQuestionPaper,
        thirteenMarkQuestionPaper,
        fifteenMarkQuestionPaper
      ];
    } else {
      // If the selected type is not 'MODEL', 'IAT-1', or 'IAT-2', return an empty list or handle it as needed
      return [];
    }
  }

  Future<String> uploadPdfToFirebase(File pdfFile) async {
    try {
      final String fileName = getFormattedFileName();
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('question_papers')
          .child(fileName);
      await storageRef.putFile(pdfFile);
      print('PDF uploaded to Firebase Storage');

      final downloadURL = await storageRef.getDownloadURL();
      print('Download URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Error uploading PDF to Firebase Storage: $e');
      return '';
    }
  }

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
            'Question Paper Download',
            style: TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Question paper generated successfully!',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Your question paper is ready for download.',
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
      backgroundColor: Color(0xFF26296B),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return subjects.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selectedSubject) {
                  setState(() {
                    _selectedSubject = selectedSubject;
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    style: TextStyle(color: Colors.blue),
                    decoration: InputDecoration(
                      hintText: 'Choose Subject',
                      hintStyle: TextStyle(color: Colors.blue), // Set hint text color
                    ),
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  final List<String> optionList = options.toList();
                  final double itemHeight =50.0; // Height of each ListTile
                  final double listViewHeight =
                  (optionList.length * itemHeight).toDouble();
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: Colors.white,
                      elevation: 4.0,
                      child: SizedBox(
                        height: listViewHeight,
                        width: 353, // Make the width adjustable
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: optionList
                              .map((String option) => ListTile(
                            onTap: () {
                              onSelected(option);
                            },
                            title: Text(option),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedType,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
                style: const TextStyle(color: Colors.blue),
                items: <String>['Choose Assessment', 'IAT-1', 'IAT-2', 'MODEL']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedSet,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSet = newValue;
                    });
                  }
                },
                style: const TextStyle(color: Colors.blue),
                items: <String>['Choose Set', 'A', 'B', 'C']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedDivision,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDivision = newValue;
                    });
                  }
                },
                style: const TextStyle(color: Colors.blue),
                items: <String>['Choose Division','A and B','A, B and C']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
                      formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
                    });
                  }
                },
                child: Text(
                  'Date: ${formattedDate.toString().substring(0, 10)}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: !_isDownloading
                    ? () async {
                  setState(() {
                    _isDownloading = true;
                  });

                  List<String> generatedQuestions =
                  generateQuestionPaper();

                  if (generatedQuestions.isEmpty) {
                    return; // Exit if there's an error
                  }

                  final pdf = pdfLib.Document();
                  final ByteData imageData =
                  await rootBundle.load('assets/Strip.png');
                  final Uint8List bytes = imageData.buffer.asUint8List();
                  final pdfLib.MemoryImage image =
                  pdfLib.MemoryImage(bytes);

                  // Define box size and spacing
                  final double boxSize = 15.0;
                  final double boxSpacing = 0;
                  // Find subject code based on selected subject
                  String getSubjectCode(String selectedSubject) {
                    // Iterate through the dataset to find the matching subject
                    for (var data in dataset) {
                      if (data['subject'] == selectedSubject) {
                        return data['subjectcode'];
                      }
                    }
                    return ''; // Return empty string if subject code is not found
                  }

                  String getDepartment(String selectedSubject) {
                    // Iterate through the dataset to find the matching subject
                    for (var data in dataset) {
                      if (data['subject'] == selectedSubject) {
                        return data['Department'];
                      }
                    }
                    return ''; // Return empty string if subject code is not found
                  }

                  String getYear(String selectedSubject) {
                    // Iterate through the dataset to find the matching subject
                    for (var data in dataset) {
                      if (data['subject'] == selectedSubject) {
                        return data['year'];
                      }
                    }
                    return ''; // Return empty string if subject code is not found
                  }

                  //Page 1
                  pdf.addPage(
                    pdfLib.Page(
                      build: (context) {
                        final double pageWidth =
                        595.0; // Assuming standard A4 page dimensions (8.27 x 11.69 inches)
                        final double pageHeight = 842.0;
                        final double margin =
                        20.0; // Adjust margin size as needed
                        final double imageHeight =
                        55.0; // Height of the image

                        String headingText = '';
                        if (_selectedType == 'IAT-1') {
                          headingText = 'Internal assessment - 1';
                        } else if (_selectedType == 'IAT-2') {
                          headingText = 'Internal assessment - 2';
                        } else if (_selectedType == 'MODEL') {
                          headingText = 'MODEL EXAM';
                        }

                        return pdfLib.Container(
                          width: pageWidth,
                          height: pageHeight,
                          alignment: pdfLib.Alignment.center,
                          child: pdfLib.Container(
                            width: pageWidth - (2 * margin),
                            height: pageHeight - (2 * margin),
                            decoration: pdfLib.BoxDecoration(
                              border: pdfLib.Border.all(
                                width: 1, // Border width
                              ),
                            ),
                            padding: pdfLib.EdgeInsets.all(
                                margin), // Padding to create margin around content
                            child: pdfLib.Column(
                              crossAxisAlignment:
                              pdfLib.CrossAxisAlignment.start,
                              children: [
                                pdfLib.Row(
                                  mainAxisAlignment: pdfLib
                                      .MainAxisAlignment.spaceBetween,
                                  children: [
                                    pdfLib.Expanded(
                                      child: pdfLib.Text(
                                        'Reg No. ', // Add your desired text here
                                        textAlign: pdfLib.TextAlign
                                            .right, // Align text to the right
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    pdfLib.Container(
                                      width: boxSize * 12 +
                                          boxSpacing *
                                              11, // Adjust the width of the grid as needed
                                      height:
                                      boxSize, // Adjust the height of each box as needed
                                      child: pdfLib.Row(
                                        mainAxisAlignment: pdfLib
                                            .MainAxisAlignment
                                            .spaceBetween,
                                        children: List.generate(
                                          12,
                                              (index) => pdfLib.Container(
                                            width:
                                            boxSize, // Adjust the width of each box as needed
                                            height:
                                            boxSize, // Adjust the height of each box as needed
                                            decoration:
                                            pdfLib.BoxDecoration(
                                              border: pdfLib.Border.all(
                                                width: 1, // Border width
                                              ),
                                            ),
                                            // No text inside the boxes
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                pdfLib.SizedBox(height: 10),

                                // Image covering full width
                                pdfLib.Container(
                                  width:
                                  double.infinity, // Take full width
                                  height: imageHeight, // Set height to 50
                                  child: pdfLib.Image(image,
                                      fit: pdfLib.BoxFit.cover),
                                ),
                                pdfLib.SizedBox(height: 10),
                                pdfLib.Align(
                                  alignment: pdfLib.Alignment.center,
                                  child: pdfLib.Text(
                                    headingText,
                                    style: pdfLib.TextStyle(
                                      fontWeight: pdfLib.FontWeight.bold,
                                      fontSize: 14,
                                      decoration: pdfLib.TextDecoration
                                          .underline, // Underline the text
                                    ),
                                  ),
                                ),
                                pdfLib.SizedBox(height: 10, width: 10),
                            pdfLib.Center(
                              child:pdfLib.Row(
                                mainAxisAlignment: pdfLib.MainAxisAlignment.center,
                                children: [
                                  pdfLib.Column(
                                    crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
                                    children: [
                                      pdfLib.SizedBox(height: 10),
                                      pdfLib.Row(
                                        children: [
                                          pdfLib.Text(
                                            'Sub name: ', // Subheading text
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pdfLib.Text(
                                            _selectedSubject ?? '', // Display the selected subject next to the subheading
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.normal,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pdfLib.SizedBox(height: 10),
                                      pdfLib.Row(
                                        children: [
                                          pdfLib.Text(
                                            'Subject code: ', // Subheading text
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pdfLib.Text(
                                            getSubjectCode(_selectedSubject), // Display the subject code
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.normal,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pdfLib.SizedBox(height: 10),
                                      pdfLib.Text(
                                        'Date: ${formattedDate.toString().substring(0, 10)}',
                                        style: pdfLib.TextStyle(
                                          fontWeight: pdfLib.FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                      pdfLib.SizedBox(height: 10),
                                      pdfLib.Row(
                                        children: [
                                          pdfLib.Text(
                                            'Time: ', // Subheading text
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pdfLib.Text(
                                            '3 Hours', // Subheading text
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  pdfLib.SizedBox(width: 50), // Adjust the spacing between the columns
                                  pdfLib.Column(
                                    crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
                                    children: [
                                      pdfLib.SizedBox(height: 10),
                                      pdfLib.Row(
                                        children: [
                                          pdfLib.Text(
                                            'Set: ', // Subheading text for Set
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pdfLib.Text(
                                            _selectedSet ?? '', // Display the selected subject next to the subheading
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.normal,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pdfLib.SizedBox(height: 10),
                                      pdfLib.Row(
                                        children: [
                                          pdfLib.Text(
                                            'Department: ', // Subheading text for Set
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pdfLib.Text(
                                            getDepartment(_selectedSubject), // Display the subject code
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.normal,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pdfLib.SizedBox(height: 10),
                                      pdfLib.Row(
                                        children: [
                                          pdfLib.Text(
                                            'Year & Sec: ', // Subheading text for Set
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pdfLib.Text(
                                            getYear(_selectedSubject), // Display the subject code
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pdfLib.SizedBox(height: 10),
                                      pdfLib.Row(
                                        children: [
                                          pdfLib.Text(
                                            'Max Mark: ', // Subheading text for Set
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pdfLib.Text(
                                            '100 Marks', // Subheading text for Set
                                            style: pdfLib.TextStyle(
                                              fontWeight: pdfLib.FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                              pdfLib.SizedBox(height: 30),
                                pdfLib.Row(
                                  children: [
                                    pdfLib.Text(
                                      'Course Outcome:', // Subheading text
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                pdfLib.SizedBox(height: 10),
                                pdfLib.Row(
                                  crossAxisAlignment: pdfLib
                                      .CrossAxisAlignment
                                      .start, // Align text to the start of the row
                                  children: [
                                    pdfLib.Text(
                                      'CO1 ', // Subheading text
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Expanded(
                                      child: pdfLib.Text(
                                        coValue1 ?? '',
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.normal,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                pdfLib.SizedBox(height: 10),
                                pdfLib.Row(
                                  crossAxisAlignment: pdfLib
                                      .CrossAxisAlignment
                                      .start, // Align text to the start of the row
                                  children: [
                                    pdfLib.Text(
                                      'CO2 ', // Subheading text
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Expanded(
                                      child: pdfLib.Text(
                                        coValue2 ?? '',
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.normal,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                pdfLib.SizedBox(height: 10),
                                pdfLib.Row(
                                  crossAxisAlignment: pdfLib
                                      .CrossAxisAlignment
                                      .start, // Align text to the start of the row
                                  children: [
                                    pdfLib.Text(
                                      'CO3 ', // Subheading text
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Expanded(
                                      child: pdfLib.Text(
                                        coValue3 ?? '',
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.normal,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                pdfLib.SizedBox(height: 10),
                                pdfLib.Row(
                                  crossAxisAlignment: pdfLib
                                      .CrossAxisAlignment
                                      .start, // Align text to the start of the row
                                  children: [
                                    pdfLib.Text(
                                      'CO4 ', // Subheading text
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Expanded(
                                      child: pdfLib.Text(
                                        coValue4 ?? '',
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.normal,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                pdfLib.SizedBox(height: 10),
                                pdfLib.Row(
                                  crossAxisAlignment: pdfLib
                                      .CrossAxisAlignment
                                      .start, // Align text to the start of the row
                                  children: [
                                    pdfLib.Text(
                                      'CO5 ', // Subheading text
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Expanded(
                                      child: pdfLib.Text(
                                        coValue5 ?? '',
                                        style: pdfLib.TextStyle(
                                          fontWeight:
                                          pdfLib.FontWeight.normal,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                pdfLib.SizedBox(height: 10),
                                pdfLib.Row(
                                  children: [
                                    pdfLib.Text(
                                      "Bloom's Taxonomy: ", // Subheading text
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "C",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "-Create, ",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "E",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "-Evaluate, ",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "AN",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "-Analyze, ",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "AP",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "-Apply, ",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "U",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "-Understand, ",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "R",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      "-Reminder.",
                                      style: pdfLib.TextStyle(
                                        fontWeight:
                                        pdfLib.FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                pdfLib.SizedBox(height: 10),
                                pdfLib.Row(
                                  mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pdfLib.Text(
                                      'I) PART A: (10x2=20Marks)',
                                      style: pdfLib.TextStyle(
                                        fontWeight: pdfLib.FontWeight.bold,
                                        fontStyle: pdfLib.FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                    pdfLib.Text(
                                      'BT',
                                      style: pdfLib.TextStyle(
                                        fontWeight: pdfLib.FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                pdfLib.SizedBox(height: 10),
                                pdfLib.Text(
                                  generatedQuestions[0],
                                  style: const pdfLib.TextStyle(
                                      fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                  // Page 2
                  pdf.addPage(
                    pdfLib.Page(
                      build: (context) {
                        const double pageWidth = 595.0;
                        const double pageHeight = 842.0;
                        const double margin = 20.0;

                        // Check if selectedDivision is '3'
                        if (_selectedDivision == 'A, B and C') {
                          // Logic for Division 3
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
                              padding: pdfLib.EdgeInsets.all(margin),
                              child: pdfLib.Column(
                                crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
                                children: [
                                  pdfLib.Text(
                                    'II) PART B: (5x13=65Marks)',
                                    style: pdfLib.TextStyle(
                                      fontWeight: pdfLib.FontWeight.bold,
                                      fontStyle: pdfLib.FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 10),
                                  pdfLib.Flexible(
                                    child: pdfLib.Container(
                                      child: pdfLib.Text(
                                        generatedQuestions[1],
                                        style: const pdfLib.TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 20),
                                  pdfLib.Text(
                                    'III) PART C: (1x15=15Marks)',
                                    style: pdfLib.TextStyle(
                                      fontWeight: pdfLib.FontWeight.bold,
                                      fontStyle: pdfLib.FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 10),
                                  pdfLib.Text(
                                    generatedQuestions[2],
                                    style: const pdfLib.TextStyle(fontSize: 10),
                                  ),
                                  pdfLib.SizedBox(height: 20),
                                  pdfLib.Center(
                                    child: pdfLib.Text(
                                      '************',
                                      style: pdfLib.TextStyle(
                                        fontWeight: pdfLib.FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 50),
                                  pdfLib.Row(
                                    mainAxisAlignment:
                                    pdfLib.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pdfLib.Text(
                                        '          Course Teacher',
                                        style: pdfLib.TextStyle(
                                          fontWeight: pdfLib.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      pdfLib.Text(
                                        '     HOD          ',
                                        style: pdfLib.TextStyle(
                                          fontWeight: pdfLib.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Logic for Division other than 3
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
                              padding: pdfLib.EdgeInsets.all(margin),
                              child: pdfLib.Column(
                                crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
                                children: [
                                  pdfLib.Text(
                                    'II) PART B: (5x16=80Marks)',
                                    style: pdfLib.TextStyle(
                                      fontWeight: pdfLib.FontWeight.bold,
                                      fontStyle: pdfLib.FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 10),
                                  pdfLib.Flexible(
                                    child: pdfLib.Container(
                                      child: pdfLib.Text(
                                        generatedQuestions[1],
                                        style: const pdfLib.TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 20),
                                  pdfLib.Center(
                                    child: pdfLib.Text(
                                      '************',
                                      style: pdfLib.TextStyle(
                                        fontWeight: pdfLib.FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  pdfLib.SizedBox(height: 20),
                                  pdfLib.Row(
                                    mainAxisAlignment:
                                    pdfLib.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pdfLib.Text(
                                        '          Course Teacher',
                                        style: pdfLib.TextStyle(
                                          fontWeight: pdfLib.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      pdfLib.Text(
                                        '     HOD          ',
                                        style: pdfLib.TextStyle(
                                          fontWeight: pdfLib.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );

                  final String dir =
                      (await getApplicationDocumentsDirectory()).path;
                  final String path = '$dir/question_paper.pdf';
                  final File file = File(path);
                  await file.writeAsBytes(await pdf.save());
                  print('PDF saved to $path');

                  String downloadURL = await uploadPdfToFirebase(file);

                  _showDownloadDialog(downloadURL);
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
                  'Generate Question Paper',
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
