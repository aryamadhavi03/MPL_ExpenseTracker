import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> expenses;
  final double budget;

  const StatisticsScreen({Key? key, required this.expenses, required this.budget}) : super(key: key);
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  DateTime selectedMonth = DateTime.now();
  List<QueryDocumentSnapshot> monthlyExpenses = [];
  List<QueryDocumentSnapshot> monthlyIncomes = [];

  @override
  void initState() {
    super.initState();
    _fetchMonthlyData();
  }

  Future<void> _fetchMonthlyData() async {
    try {
      final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
      
      final expenses = await _databaseService.getExpensesByDateRange(startDate, endDate);
      final incomes = await _databaseService.getIncomesByDateRange(startDate, endDate);
      
      setState(() {
        monthlyExpenses = expenses;
        monthlyIncomes = incomes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: ${e.toString()}'))
      );
    }
  }

  List<PieChartSectionData> getExpenseSections() {
    Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (var doc in monthlyExpenses) {
      var expense = doc.data() as Map<String, dynamic>;
      categoryTotals[expense['category']] = 
          (categoryTotals[expense['category']] ?? 0) + expense['amount'];
      totalExpense += expense['amount'];
    }

    return _createSections(categoryTotals, totalExpense);
  }

  List<PieChartSectionData> getIncomeSections() {
    Map<String, double> categoryTotals = {};
    double totalIncome = 0;

    for (var doc in monthlyIncomes) {
      var income = doc.data() as Map<String, dynamic>;
      categoryTotals[income['category']] = 
          (categoryTotals[income['category']] ?? 0) + income['amount'];
      totalIncome += income['amount'];
    }

    return _createSections(categoryTotals, totalIncome);
  }

  List<PieChartSectionData> _createSections(Map<String, double> categoryTotals, double total) {
    List<PieChartSectionData> sections = [];
    categoryTotals.forEach((category, amount) {
      double percentage = total > 0 ? (amount / total) * 100 : 0;
      sections.add(PieChartSectionData(
        value: amount,
        title: "$category\n${percentage.toStringAsFixed(1)}%",
        color: getColor(category),
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    });
    return sections;
  }

  Color getColor(String category) {
    switch (category) {
      // Expense Categories
      case 'Household':
        return Colors.blue;
      case 'Shopping':
        return Colors.red;
      case 'Food':
        return Colors.green;
      case 'Travel':
        return Colors.orange;
      case 'Study':
        return Colors.purple;
      case 'Entertainment':
        return Colors.cyan;
      case 'Other':
        return Colors.grey;
      
      // Income Categories
      case 'Pocket Money':
        return Colors.teal;
      case 'Stipend':
        return Colors.amber;
      case 'Freelancing':
        return Colors.indigo;
      case 'Gift':
        return Colors.pink;
      case 'Custom':
        return Colors.deepOrange;
      default:
        return const Color.fromARGB(255, 83, 36, 36);
    }
  }

  void _changeMonth(bool next) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + (next ? 1 : -1),
        1,
      );
      _fetchMonthlyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
        title: Text('Monthly Statistics'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => _changeMonth(false),
          ),
          Center(
            child: Text(
              DateFormat('MMMM yyyy').format(selectedMonth),
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeMonth(true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Monthly Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: getExpenseSections(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(enabled: true),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Monthly Income',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: getIncomeSections(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(enabled: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
