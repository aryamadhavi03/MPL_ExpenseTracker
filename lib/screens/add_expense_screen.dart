import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Function(Map<String, dynamic> expense)? onSaveExpense;

  AddExpenseScreen({this.onSaveExpense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  String _selectedCategory = 'Food';
  final List<String> _categories = [
    'Household', 'Shopping', 'Food', 'Travel', 'Study', 'Entertainment', 'Other', 'Custom'
  ];
  bool _isCustomCategory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Enter amount'),
            ),
            SizedBox(height: 16),
            Text('Category:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                  _isCustomCategory = value == 'Custom';
                });
              },
            ),
            if (_isCustomCategory)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    hintText: 'Enter custom category',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                double amount = double.tryParse(_amountController.text) ?? 0;
                if (amount > 0) {
                  try {
                    Map<String, dynamic> expense = {
                      'category': _isCustomCategory ? _customCategoryController.text : _selectedCategory,
                      'amount': amount,
                    };
                    
                    // Save to Firebase
                    await DatabaseService().addExpense(expense);
                    
                    // Call local callback if provided
                    if (widget.onSaveExpense != null) {
                      widget.onSaveExpense!(expense);
                    }
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Expense added successfully'))
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()))
                    );
                  }
                }
              },
              child: Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AddExpenseScreen extends StatefulWidget {
//   final Function(Map<String, dynamic> expense)? onSaveExpense; // Nullable for Firebase integration
//
//   AddExpenseScreen({this.onSaveExpense});
//
//   @override
//   _AddExpenseScreenState createState() => _AddExpenseScreenState();
// }
//
// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   String _selectedCategory = 'Food';
//   final List<String> _categories = [
//     'Household', 'Shopping', 'Food', 'Travel', 'Study', 'Entertainment', 'Other'
//   ];
//
//   // 🔹 Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // 🔹 Function to Save Expense in Firebase Firestore
//   Future<void> _saveExpense() async {
//     double amount = double.tryParse(_amountController.text) ?? 0;
//     if (amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter a valid amount')),
//       );
//       return;
//     }
//
//     // 📌 Get today's date as YYYY-MM-DD format
//     String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//     // 📌 Expense Data
//     Map<String, dynamic> expense = {
//       'category': _selectedCategory,
//       'amount': amount,
//       'date': formattedDate,
//       'timestamp': FieldValue.serverTimestamp(), // 🔹 Auto Timestamp
//     };
//
//     try {
//       // 🔹 Save expense under the date's document
//       await _firestore
//           .collection('expenses')
//           .doc(formattedDate) // Date as document
//           .collection('daily_expenses')
//           .add(expense);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Expense Added Successfully')),
//       );
//
//       // 🔹 If using local state, call callback function
//       if (widget.onSaveExpense != null) {
//         widget.onSaveExpense!(expense);
//       }
//
//       // 🔹 Close the screen
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving expense: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Expense')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Amount:', style: TextStyle(fontSize: 18)),
//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(hintText: 'Enter amount'),
//             ),
//             SizedBox(height: 16),
//             Text('Category:', style: TextStyle(fontSize: 18)),
//             DropdownButton<String>(
//               value: _selectedCategory,
//               isExpanded: true,
//               items: _categories.map((String category) {
//                 return DropdownMenuItem<String>(
//                   value: category,
//                   child: Text(category),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCategory = value!;
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveExpense, // 🔹 Call Firestore Save Function
//               child: Text('Save Expense'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
