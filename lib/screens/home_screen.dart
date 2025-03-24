import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double budget = 0.0;
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> incomes = [];
  int _currentIndex = 0;
  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription? _expenseSubscription;
  StreamSubscription? _incomeSubscription;
  bool _subscriptionsActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSubscriptions();
    });
  }

  void _setupSubscriptions() {
    if (_subscriptionsActive) return;
    
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      _handleFirebaseError('User not authenticated');
      return;
    }

    final DateTime now = DateTime.now();
    final String dateId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      // Listen to expenses
      _expenseSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .doc(dateId)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          List<Map<String, dynamic>> newExpenses = [];
          
          for (var doc in snapshot.docs) {
            var data = doc.data();
            newExpenses.add({
              ...data,
              'id': doc.id,
              'date': DateFormat('MMM dd, yyyy').format(DateTime.parse(data['createdAt'])),
            });
          }

          setState(() {
            expenses = newExpenses;
            _updateBudget(expenses, incomes);
          });
        },
        onError: (error) => _handleFirebaseError(error),
      );

      // Listen to incomes
      _incomeSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('incomes')
          .doc(dateId)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          List<Map<String, dynamic>> newIncomes = [];
          
          for (var doc in snapshot.docs) {
            var data = doc.data();
            newIncomes.add({
              ...data,
              'id': doc.id,
              'date': DateFormat('MMM dd, yyyy').format(DateTime.parse(data['createdAt'])),
            });
          }

          setState(() {
            incomes = newIncomes;
            _updateBudget(expenses, incomes);
          });
        },
        onError: (error) => _handleFirebaseError(error),
      );

      _subscriptionsActive = true;
    } catch (e) {
      _handleFirebaseError(e);
    }
  }

  void _updateBudget(List<Map<String, dynamic>> currentExpenses, List<Map<String, dynamic>> currentIncomes) {
    try {
      double totalExpenses = currentExpenses.fold(0, (sum, expense) => sum + (expense['amount'] as num).toDouble());
      double totalIncomes = currentIncomes.fold(0, (sum, income) => sum + (income['amount'] as num).toDouble());
      
      setState(() {
        budget = totalIncomes - totalExpenses;
      });
    } catch (e) {
      _handleFirebaseError(e);
    }
  }

  @override
  void dispose() {
    try {
      _expenseSubscription?.cancel();
      _incomeSubscription?.cancel();
      _subscriptionsActive = false;
    } catch (e) {
      print('Error disposing subscriptions: $e');
    }
    super.dispose();
  }

  void _handleFirebaseError(dynamic error) {
    String message = 'An error occurred';
    if (error is FirebaseException) {
      message = error.message ?? 'Firebase error occurred';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Local callback for expense addition
  void addExpense(Map<String, dynamic> expense) {
    // Firebase handling is done in AddExpenseScreen
  }

  // Local callback for income addition
  void addIncome(double amount) {
    // Firebase handling is done in AddIncomeScreen
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _buildHomeContent(),
      CalendarScreen(expenses: expenses), // Pass expenses to Calendar
      StatisticsScreen(expenses: expenses, budget: budget),
      ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: Theme.of(context).colorScheme.surface,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Home Screen Content Widget
  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Budget Display
          Card(
            color: Colors.blue[100],
            child: ListTile(
              title: Text(
                "Budget Left",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "₹${budget.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 24, color: Colors.blueAccent),
              ),
            ),
          ),
          SizedBox(height: 20),
          // Expense List with Category and Date
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                var expense = expenses[index];
                return Card(
                  color: Colors.pink[50],
                  child: ListTile(
                    title: Text(expense['category']),
                    subtitle: Text("Date: ${expense['date']}"),
                    trailing: Text(
                      "₹${expense['amount'].toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          // Add Expense and Income Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpenseScreen(
                        onSaveExpense: addExpense,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.remove),
                label: Text("Add Expense"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddIncomeScreen(
                        onSaveIncome: addIncome,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add),
                label: Text("Add Income"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
