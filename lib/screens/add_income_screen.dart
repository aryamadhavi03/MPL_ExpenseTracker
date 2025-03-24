import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AddIncomeScreen extends StatefulWidget {
  final Function(double)? onSaveIncome;

  AddIncomeScreen({this.onSaveIncome});

  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  String selectedSource = "Pocket Money";
  bool _isCustomCategory = false;

  final List<String> incomeSources = [
    "Pocket Money",
    "Stipend",
    "Freelancing",
    "Gift",
    "Other",
    "Custom",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Income')),
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
            Text('Source:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedSource,
              isExpanded: true,
              items: incomeSources.map((String source) {
                return DropdownMenuItem<String>(
                  value: source,
                  child: Text(source),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSource = newValue!;
                  _isCustomCategory = newValue == 'Custom';
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
                double amount = double.tryParse(_amountController.text) ?? 0.0;
                if (amount > 0) {
                  try {
                    Map<String, dynamic> income = {
                      'category': _isCustomCategory ? _customCategoryController.text : selectedSource,
                      'amount': amount,
                    };
                    
                    // Save to Firebase
                    await DatabaseService().addIncome(income);
                    
                    // Call local callback if provided
                    if (widget.onSaveIncome != null) {
                      widget.onSaveIncome!(amount);
                    }
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Income added successfully'))
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()))
                    );
                  }
                }
              },
              child: Text('Save Income'),
            ),
          ],
        ),
      ),
    );
  }
}
