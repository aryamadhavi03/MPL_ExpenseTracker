import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  final List<Map<String, dynamic>> expenses;

  CalendarScreen({required this.expenses});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDate;
  List<QueryDocumentSnapshot> _selectedDateTransactions = [];
  final DatabaseService _databaseService = DatabaseService();

  // Function to fetch transactions for the selected date
  Future<void> _fetchTransactionsForDate(DateTime date) async {
    try {
      setState(() => _selectedDate = date);
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      // Fetch both expenses and incomes for the selected date
      List<QueryDocumentSnapshot> expenses = await _databaseService.getExpensesByDate(formattedDate);
      List<QueryDocumentSnapshot> incomes = await _databaseService.getIncomesByDate(formattedDate);
      
      setState(() {
        _selectedDateTransactions = [...expenses, ...incomes];
        // Sort by timestamp
        _selectedDateTransactions.sort((a, b) {
          var aTimestamp = a['timestamp'] as Timestamp?;
          var bTimestamp = b['timestamp'] as Timestamp?;
          if (aTimestamp == null || bTimestamp == null) return 0;
          return bTimestamp.compareTo(aTimestamp);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching transactions: ${e.toString()}'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Calendar'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
      ),
      body: Column(
        children: [
          CalendarCarousel(
            onDayPressed: (date, events) {
              _fetchTransactionsForDate(date);
            },
            weekendTextStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.red[300] : Colors.red),
            thisMonthDayBorderColor: Theme.of(context).dividerColor,
            weekFormat: false,
            height: 420.0,
            selectedDateTime: _selectedDate,
            daysHaveCircularBorder: false,
            todayButtonColor: Theme.of(context).primaryColor,
            todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            selectedDayButtonColor: Theme.of(context).colorScheme.secondary,
            selectedDayTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            weekdayTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          SizedBox(height: 10),
          // Display expenses for the selected date with Scrollbar
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 8,
              radius: Radius.circular(8),
              child: _selectedDateTransactions.isNotEmpty
                  ? ListView.builder(
                itemCount: _selectedDateTransactions.length,
                itemBuilder: (context, index) {
                  var transaction = _selectedDateTransactions[index].data() as Map<String, dynamic>;
                  bool isExpense = transaction['type'] == 'expense';
                  
                  return Card(
                    color: isExpense 
                      ? Theme.of(context).brightness == Brightness.dark 
                        ? Colors.red.withOpacity(0.2) 
                        : Colors.pink[50]
                      : Theme.of(context).brightness == Brightness.dark 
                        ? Colors.green.withOpacity(0.2) 
                        : Colors.green[50],
                    child: ListTile(
                      leading: Icon(
                        isExpense ? Icons.remove_circle : Icons.add_circle,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                      title: Text(transaction['category']),
                      subtitle: Text(transaction['note'] ?? ''),
                      trailing: Text(
                        "₹${transaction['amount'].toStringAsFixed(2)}",
                        style: TextStyle(
                          color: isExpense ? Colors.redAccent : Colors.green,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  "No transactions for this date",
                  style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
