import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class SavingsChallengesScreen extends StatefulWidget {
  @override
  _SavingsChallengesScreenState createState() =>
      _SavingsChallengesScreenState();
}

class _SavingsChallengesScreenState extends State<SavingsChallengesScreen> {
  double totalSavings = 0.0;
  int streak = 0;
  double dailyGoal = 50.0; // Default daily savings goal
  String lastSavedDate = "";
  String badge = "No Badge";

  TextEditingController savingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavingsData();
  }

  Future<void> _loadSavingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalSavings = prefs.getDouble('totalSavings') ?? 0.0;
      streak = prefs.getInt('streak') ?? 0;
      dailyGoal = prefs.getDouble('dailyGoal') ?? 50.0;
      lastSavedDate = prefs.getString('lastSavedDate') ?? "";
      badge = prefs.getString('badge') ?? "No Badge";
    });
  }

  Future<void> _saveSavingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('totalSavings', totalSavings);
    prefs.setInt('streak', streak);
    prefs.setDouble('dailyGoal', dailyGoal);
    prefs.setString('lastSavedDate', lastSavedDate);
    prefs.setString('badge', badge);
  }

  void _saveAmount() async {
    double amount = double.tryParse(savingsController.text) ?? 0.0;
    if (amount <= 0) return;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastSaved = prefs.getString('lastSavedDate') ?? "";
    
    if (lastSaved == today) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You've already saved today! Come back tomorrow to continue your streak!")),
      );
      return;
    }

    try {
      final DatabaseService dbService = DatabaseService();
      
      // First deduct from income
      await dbService.addExpense({
        'amount': amount,
        'category': 'Savings Deduction',
        'description': 'Amount moved to savings',
        'date': today
      });

      // Then add to savings
      await dbService.addSavings({
        'amount': amount,
        'category': 'Savings Challenge',
        'description': 'Daily Savings Challenge',
        'date': today
      });

      setState(() {
        totalSavings += amount;

        if (lastSavedDate ==
            DateFormat('yyyy-MM-dd')
                .format(DateTime.now().subtract(Duration(days: 1)))) {
          streak += 1;
        } else {
          streak = 1; // Reset streak if skipped a day
        }

        lastSavedDate = today;
        _updateBadgesAndRewards();
        _saveSavingsData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Savings added and deducted from income successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}')),
      );
    }

    savingsController.clear();
  }

  void _updateBadgesAndRewards() {
    if (streak >= 30) {
      badge = "🔥 Master Saver (30 Days)";
    } else if (streak >= 14) {
      badge = "🌟 Super Saver (14 Days)";
    } else if (streak >= 7) {
      badge = "🏆 Weekly Saver (7 Days)";
      totalSavings += 10; // Bonus ₹10 for 7-day streak
    } else if (streak >= 3) {
      badge = "🎖 Beginner Saver (3 Days)";
    } else {
      badge = "No Badge";
    }

    _saveSavingsData();
  }



  void _updateDailyGoal() async {
    double newGoal = double.tryParse(savingsController.text) ?? dailyGoal;
    if (newGoal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    setState(() {
      dailyGoal = newGoal;
    });
    await _saveSavingsData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Daily savings goal updated to ₹$newGoal')),
    );
    savingsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Savings Challenge")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Daily Savings Goal: ₹$dailyGoal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Total Savings: ₹$totalSavings",
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 10),
            Text(
              "Streak: $streak days",
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              "🏅 Badge: $badge",
              style: TextStyle(fontSize: 18, color: Colors.orange),
            ),
            SizedBox(height: 20),
            TextField(
              controller: savingsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter amount to save",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveAmount,
              child: Text("Save Money"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateDailyGoal,
              child: Text("Set New Daily Goal"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),

          ],
        ),
      ),
    );
  }
}
