import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class LoanTrackerScreen extends StatefulWidget {
  @override
  _LoanTrackerScreenState createState() => _LoanTrackerScreenState();
}

class _LoanTrackerScreenState extends State<LoanTrackerScreen> {
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();

  double loanAmount = 0.0;
  double interestRate = 0.0;
  int tenure = 0;
  double monthlyEMI = 0.0;
  double remainingLoan = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLoanData();
  }

  Future<void> _loadLoanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loanAmount = prefs.getDouble('loanAmount') ?? 0.0;
      interestRate = prefs.getDouble('interestRate') ?? 0.0;
      tenure = prefs.getInt('tenure') ?? 0;
      remainingLoan = prefs.getDouble('remainingLoan') ?? loanAmount;
      _calculateEMI();
    });
  }

  Future<void> _saveLoanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('loanAmount', loanAmount);
    prefs.setDouble('interestRate', interestRate);
    prefs.setInt('tenure', tenure);
    prefs.setDouble('remainingLoan', remainingLoan);
  }

  void _calculateEMI() {
    if (loanAmount > 0 && interestRate > 0 && tenure > 0) {
      double monthlyRate = (interestRate / 12) / 100;
      int months = tenure * 12;
      monthlyEMI = (loanAmount * monthlyRate * pow(1 + monthlyRate, months)) /
          (pow(1 + monthlyRate, months) - 1);
      setState(() {});
    }
  }

  void _makePayment() {
    double payment = double.tryParse(_paymentController.text) ?? 0.0;
    if (payment > 0 && remainingLoan > 0) {
      setState(() {
        remainingLoan -= payment;
        if (remainingLoan < 0) remainingLoan = 0;
        _saveLoanData();
      });
    }
    _paymentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Loan Repayment Tracker")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _loanAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Loan Amount (₹)"),
            ),
            TextField(
              controller: _interestRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Interest Rate (%)"),
            ),
            TextField(
              controller: _tenureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Tenure (years)"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  loanAmount = double.tryParse(_loanAmountController.text) ?? 0.0;
                  interestRate = double.tryParse(_interestRateController.text) ?? 0.0;
                  tenure = int.tryParse(_tenureController.text) ?? 0;
                  remainingLoan = loanAmount;
                  _calculateEMI();
                  _saveLoanData();
                });
              },
              child: Text("Calculate EMI"),
            ),
            SizedBox(height: 20),
            Text(
              "Monthly EMI: ₹${monthlyEMI.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Remaining Loan: ₹${remainingLoan.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter Payment Amount (₹)"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _makePayment,
              child: Text("Make Payment"),
            ),
          ],
        ),
      ),
    );
  }
}
