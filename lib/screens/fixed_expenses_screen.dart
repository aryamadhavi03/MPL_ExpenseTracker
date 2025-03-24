import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FixedExpensesScreen extends StatefulWidget {
  @override
  _FixedExpensesScreenState createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  Map<String, Map<String, bool>> expenses = {};
  double rent = 0.0, mess = 0.0, electricity = 0.0, totalBudget = 0.0, totalExpenses = 0.0;
  final DatabaseService _databaseService = DatabaseService();

  final List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  final List<String> categories = ["Rent", "Mess", "Electricity"];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Map<String, bool>> loadedExpenses = {};
    for (String month in months) {
      Map<String, bool> categoryStatus = {};
      for (String category in categories) {
        categoryStatus[category] = prefs.getBool('$month-$category') ?? false;
      }
      loadedExpenses[month] = categoryStatus;
    }

    // Get current budget from Firestore
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      
      setState(() {
        expenses = loadedExpenses;
        rent = prefs.getDouble('rent') ?? 0.0;
        mess = prefs.getDouble('mess') ?? 0.0;
        electricity = prefs.getDouble('electricity') ?? 0.0;
        totalBudget = (userDoc.data()?['totalIncome'] ?? 0.0);
        totalExpenses = (userDoc.data()?['totalExpenses'] ?? 0.0);
      });
    } catch (e) {
      print('Error loading budget: $e');
      setState(() {
        expenses = loadedExpenses;
        rent = prefs.getDouble('rent') ?? 0.0;
        mess = prefs.getDouble('mess') ?? 0.0;
        electricity = prefs.getDouble('electricity') ?? 0.0;
        totalBudget = 0.0;
      });
    }
  }

  Future<void> _updateExpense(String month, String category, bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('$month-$category', status);
    setState(() {
      expenses[month]![category] = status;
    });
  }

  Future<bool> _canAddExpense(String category) async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    final expenses = await _databaseService.getExpenses();
    final lastExpense = expenses.where((e) => 
      e['category'] == category && 
      e['isRecurring'] == true
    ).lastOrNull;

    if (lastExpense != null) {
      final lastExpenseDate = DateTime.parse(lastExpense['date'].toDate().toString());
      if (lastExpenseDate.isAfter(firstDayOfMonth)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$category has already been added this month'))
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _saveBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('rent', rent);
    prefs.setDouble('mess', mess);
    prefs.setDouble('electricity', electricity);

    // Get current month and update checkboxes
    String currentMonth = months[DateTime.now().month - 1];
    if (rent > 0) {
      if (await _canAddExpense('Rent')) {
        await _updateExpense(currentMonth, 'Rent', true);
        await _databaseService.addExpense({
          'amount': rent,
          'category': 'Rent',
          'description': 'Monthly Rent Payment',
          'isRecurring': true,
          'date': DateTime.now()
        });
      }
    }
    if (mess > 0) {
      if (await _canAddExpense('Mess')) {
        await _updateExpense(currentMonth, 'Mess', true);
        await _databaseService.addExpense({
          'amount': mess,
          'category': 'Mess',
          'description': 'Monthly Mess Payment',
          'isRecurring': true,
          'date': DateTime.now()
        });
      }
    }
    if (electricity > 0) {
      if (await _canAddExpense('Electricity')) {
        await _updateExpense(currentMonth, 'Electricity', true);
        await _databaseService.addExpense({
          'amount': electricity,
          'category': 'Electricity',
          'description': 'Monthly Electricity Bill',
          'isRecurring': true,
          'date': DateTime.now()
        });
      }
    }
    setState(() {});
  }

  double get remainingBudget => totalBudget - totalExpenses - (rent + mess + electricity);

  Widget _buildExpenseTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text("Month", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
          DataColumn(label: Text("Rent", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
          DataColumn(label: Text("Mess", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
          DataColumn(label: Text("Electricity", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
        ],
        rows: months.map((month) {
          return DataRow(cells: [
            DataCell(Text(month, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
            ...categories.map((category) => DataCell(
              Checkbox(
                value: expenses[month]?[category] ?? false,
                onChanged: (bool? value) {
                  _updateExpense(month, category, value ?? false);
                },
              ),
            )).toList(),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetInput(String label, double value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        keyboardType: TextInputType.number,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        onChanged: (val) => onChanged(val),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fixed Expenses Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter Fixed Expenses", 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color
              )
            ),
            _buildBudgetInput("Rent", rent, (val) {
              rent = double.tryParse(val) ?? 0.0;
            }),
            _buildBudgetInput("Mess", mess, (val) {
              mess = double.tryParse(val) ?? 0.0;
            }),
            _buildBudgetInput("Electricity", electricity, (val) {
              electricity = double.tryParse(val) ?? 0.0;
            }),
            ElevatedButton(
              onPressed: _saveBudget,
              child: Text("Save"),
            ),
            SizedBox(height: 10),
            // Text(
            //   "Remaining Budget: ₹${budget.toStringAsFixed(2)}",
            //   "Remaining Budget: ₹${remainingBudget.toStringAsFixed(2)}",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            // ),
            SizedBox(height: 10),
            Expanded(child: _buildExpenseTable()),
          ],
        ),
      ),
    );
  }
}
