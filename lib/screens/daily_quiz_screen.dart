import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class DailyQuizScreen extends StatefulWidget {
  @override
  _DailyQuizScreenState createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  List<Map<String, dynamic>> quizQuestions = [
    {
      "question": "What is the 50/30/20 budgeting rule?",
      "options": [
        "50% Needs, 30% Wants, 20% Savings",
        "50% Savings, 30% Needs, 20% Wants",
        "50% Wants, 30% Savings, 20% Needs",
        "50% Needs, 30% Savings, 20% Wants"
      ],
      "answer": 0
    },
    {
      "question": "What does a credit score primarily measure?",
      "options": [
        "Your yearly income",
        "Your ability to repay loans",
        "Your total bank balance",
        "Your number of credit cards"
      ],
      "answer": 1
    },
    {
      "question": "Which investment typically has the lowest risk?",
      "options": [
        "Stocks",
        "Mutual Funds",
        "Real Estate",
        "Fixed Deposit"
      ],
      "answer": 3
    },
    {
      "question": "What is an emergency fund?",
      "options": [
        "A loan from the bank",
        "A fund for unplanned expenses",
        "A government grant",
        "A savings account for vacations"
      ],
      "answer": 1
    },
  ];

  int currentQuestionIndex = 0;
  int selectedOption = -1;
  bool hasAnswered = false;
  int correctAnswers = 0;
  String lastPlayedDate = "";

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().substring(0, 10);

    setState(() {
      lastPlayedDate = prefs.getString('lastPlayedDate') ?? "";
      correctAnswers = prefs.getInt('correctAnswers') ?? 0;

      if (lastPlayedDate != today) {
        // New day = new random question
        currentQuestionIndex = Random().nextInt(quizQuestions.length);
        prefs.setInt('currentQuestionIndex', currentQuestionIndex);
        prefs.setString('lastPlayedDate', today);
        hasAnswered = false;
        selectedOption = -1;
      } else {
        // Load previous question for today
        currentQuestionIndex = prefs.getInt('currentQuestionIndex') ?? 0;
        hasAnswered = prefs.getBool('hasAnswered') ?? false;
      }
    });
  }

  Future<void> _saveQuizData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasAnswered', hasAnswered);
    prefs.setInt('correctAnswers', correctAnswers);
  }

  void _checkAnswer(int index) {
    if (!hasAnswered) {
      setState(() {
        selectedOption = index;
        hasAnswered = true;
        if (index == quizQuestions[currentQuestionIndex]['answer']) {
          correctAnswers++;
        }
        _saveQuizData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> question = quizQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Daily Financial Quiz")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Question:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              question["question"],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Column(
              children: List.generate(
                question["options"].length,
                (index) => GestureDetector(
                  onTap: () => _checkAnswer(index),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hasAnswered
                          ? (index == question["answer"]
                              ? Colors.green[300]
                              : (selectedOption == index ? Colors.red[300] : Colors.grey[200]))
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      question["options"][index],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            hasAnswered
                ? Text(
                    selectedOption == question["answer"]
                        ? "✅ Correct!"
                        : "❌ Wrong! The correct answer is: ${question["options"][question["answer"]]}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : Container(),
            SizedBox(height: 20),
            Text(
              "Total Correct Answers: $correctAnswers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
