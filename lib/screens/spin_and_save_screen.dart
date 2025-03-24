import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:math';
import 'dart:async';
import '../services/database_service.dart';

class SpinAndSaveScreen extends StatefulWidget {
  @override
  _SpinAndSaveScreenState createState() => _SpinAndSaveScreenState();
}

class _SpinAndSaveScreenState extends State<SpinAndSaveScreen> {
  double savings = 0.0;
  double lastSavedAmount = 0.0;
  final List<int> amounts = [50, 0, 20, 0, 10, 0];
  bool isSpinning = false;
  bool canSpinToday = true;
  StreamController<int> controller = StreamController<int>();

  @override
  void initState() {
    super.initState();
    _loadSavings();
    _checkDailySpinAvailability();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  Future<void> _loadSavings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savings = prefs.getDouble('savings') ?? 0.0;
    });
  }

  Future<void> _checkDailySpinAvailability() async {
    final DatabaseService dbService = DatabaseService();
    final now = DateTime.now();
    
    final lastSpinTime = await dbService.getLastSpinTime();
    if (lastSpinTime != null) {
      final lastSpinDate = DateTime.parse(lastSpinTime);
      final bool isSameDay = now.year == lastSpinDate.year &&
          now.month == lastSpinDate.month &&
          now.day == lastSpinDate.day;
      
      setState(() {
        canSpinToday = !isSameDay;
      });
    } else {
      setState(() {
        canSpinToday = true;
      });
    }
  }

  Future<void> _saveAmount(double amount) async {
    final DatabaseService dbService = DatabaseService();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final lastSpinTime = await dbService.getLastSpinTime();
    if (lastSpinTime != null) {
      final lastSpinDate = DateTime.parse(lastSpinTime);
      final lastSpinDay = DateTime(lastSpinDate.year, lastSpinDate.month, lastSpinDate.day);

      if (today.isAtSameMomentAs(lastSpinDay)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already spun the wheel today. Come back tomorrow!')),
        );
        return;
      }
    }

    await dbService.updateLastSpinTime(now.toIso8601String());
    
    // Add to database as income if amount > 0
    if (amount > 0) {
      await dbService.addIncome({
        'amount': amount,
        'category': 'Spin & Save Winnings',
        'description': 'Won from Spin & Save game'
      });
      
      // Store savings in database
      await dbService.addSavings({
        'amount': amount,
        'source': 'Spin & Save',
        'description': 'Savings from Spin & Save game',
        'timestamp': now.toIso8601String()
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savings += amount;
      lastSavedAmount = amount;
      canSpinToday = false;
      prefs.setDouble('savings', savings);
    });
  }

  void _spinWheel() {
    if (!isSpinning && canSpinToday) {
      setState(() {
        isSpinning = true;
      });
      int index = Random().nextInt(amounts.length);
      controller.add(index);
      Future.delayed(Duration(seconds: 3), () {
        _saveAmount(amounts[index].toDouble());
        setState(() {
          isSpinning = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Spin & Save Game")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Savings: ₹${savings.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              child: FortuneWheel(
                selected: controller.stream,
                animateFirst: false,
                items: amounts.map((amount) => FortuneItem(
                  child: Text(
                    '₹$amount',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )).toList(),
                onAnimationEnd: () {
                  if (lastSavedAmount > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Congratulations! You won ₹${lastSavedAmount.toStringAsFixed(2)}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (isSpinning || !canSpinToday) ? null : _spinWheel,
              child: Text(
                isSpinning ? 'Spinning...' : 
                canSpinToday ? 'Spin to Win!' : 'Come back tomorrow!'
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
