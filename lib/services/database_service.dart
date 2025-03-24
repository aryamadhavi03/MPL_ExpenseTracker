import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    if (uid.isEmpty) throw Exception('User not authenticated. Please log in again.');
    
    // Validate required fields
    if (expenseData['amount'] == null || expenseData['category'] == null) {
      throw Exception('Invalid expense data: amount and category are required');
    }

    // Validate data types
    if (expenseData['amount'] is! num) {
      throw Exception('Invalid expense data: amount must be a number');
    }
    if (expenseData['category'] is! String) {
      throw Exception('Invalid expense data: category must be a string');
    }
    if (expenseData['amount'] <= 0) {
      throw Exception('Invalid expense data: amount must be greater than 0');
    }

    try {
      final DateTime now = DateTime.now();
      final String dateId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .doc(dateId)
          .collection('transactions')
          .add({
        ...expenseData,
        'type': 'expense',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': now.toIso8601String(),
        'date': dateId,
      });
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      }
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<void> addIncome(Map<String, dynamic> incomeData) async {
    if (uid.isEmpty) throw Exception('User not authenticated. Please log in again.');
    
    // Validate required fields
    if (incomeData['amount'] == null || incomeData['category'] == null) {
      throw Exception('Invalid income data: amount and category are required');
    }

    // Validate data types
    if (incomeData['amount'] is! num) {
      throw Exception('Invalid income data: amount must be a number');
    }
    if (incomeData['category'] is! String) {
      throw Exception('Invalid income data: category must be a string');
    }
    if (incomeData['amount'] <= 0) {
      throw Exception('Invalid income data: amount must be greater than 0');
    }

    try {
      final DateTime now = DateTime.now();
      final String dateId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      // Get user document reference
      final userDocRef = _firestore.collection('users').doc(uid);
      
      // Start a transaction to update both total income and add new income entry
      await _firestore.runTransaction((transaction) async {
        // Get the current user document
        final userDoc = await transaction.get(userDocRef);
        
        // Calculate new total income
        final currentTotal = userDoc.data()?['totalIncome'] ?? 0.0;
        final newTotal = currentTotal + incomeData['amount'];
        
        // Update total income in user document
        transaction.set(userDocRef, {'totalIncome': newTotal}, SetOptions(merge: true));
        
        // Add new income transaction
        final incomeRef = userDocRef
            .collection('incomes')
            .doc(dateId)
            .collection('transactions')
            .doc();
            
        transaction.set(incomeRef, {
          ...incomeData,
          'type': 'income',
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': now.toIso8601String(),
          'date': dateId,
        });
      });
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      }
      throw Exception('Failed to add income: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getExpensesByDate(String date) async {
    if (uid.isEmpty) throw Exception('User not authenticated');
    
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .doc(date)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs;
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getIncomesByDate(String date) async {
    if (uid.isEmpty) throw Exception('User not authenticated');
    
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('incomes')
          .doc(date)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs;
    } catch (e) {
      throw Exception('Failed to get incomes: $e');
    }
  }

  String _formatDateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<QueryDocumentSnapshot>> getExpenses() async {
    if (uid.isEmpty) throw Exception('User not authenticated');
    
    try {
      final String dateId = _formatDateId(DateTime.now());
      return await getExpensesByDate(dateId);
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getIncomes() async {
    if (uid.isEmpty) throw Exception('User not authenticated');
    
    try {
      final String dateId = _formatDateId(DateTime.now());
      return await getIncomesByDate(dateId);
    } catch (e) {
      throw Exception('Failed to get incomes: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    if (uid.isEmpty) throw Exception('User not authenticated');
    
    try {
      List<QueryDocumentSnapshot> allExpenses = [];
      
      for (DateTime date = startDate; date.isBefore(endDate.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
        String dateId = _formatDateId(date);
        List<QueryDocumentSnapshot> dayExpenses = await getExpensesByDate(dateId);
        allExpenses.addAll(dayExpenses);
      }
      
      return allExpenses;
    } catch (e) {
      throw Exception('Failed to get expenses by date range: $e');
    }
  }

  Future<void> updateLastSpinTime(String timestamp) async {
    if (uid.isEmpty) throw Exception('User not authenticated. Please log in again.');
    try {
      await _firestore.collection('users').doc(uid).update({'lastSpinTime': timestamp});
    } catch (e) {
      throw Exception('Failed to update last spin time: $e');
    }
  }

  Future<String?> getLastSpinTime() async {
    if (uid.isEmpty) throw Exception('User not authenticated');
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists && snapshot.data()!.containsKey('lastSpinTime')) {
        return snapshot.data()!['lastSpinTime'] as String;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get last spin time: $e');
    }
  }

  Future<void> addSavings(Map<String, dynamic> savingsData) async {
    if (uid.isEmpty) throw Exception('User not authenticated. Please log in again.');
    
    // Validate required fields
    if (savingsData['amount'] == null) {
      throw Exception('Invalid savings data: amount is required');
    }

    // Validate data types
    if (savingsData['amount'] is! num) {
      throw Exception('Invalid savings data: amount must be a number');
    }
    if (savingsData['amount'] <= 0) {
      throw Exception('Invalid savings data: amount must be greater than 0');
    }

    try {
      final DateTime now = DateTime.now();
      final String dateId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      // Get user document reference
      final userDocRef = _firestore.collection('users').doc(uid);
      
      // Start a transaction to update both total savings and add new savings entry
      await _firestore.runTransaction((transaction) async {
        // Get the current user document
        final userDoc = await transaction.get(userDocRef);
        
        // Calculate new total savings
        final currentTotal = userDoc.data()?['totalSavings'] ?? 0.0;
        final newTotal = currentTotal + savingsData['amount'];
        
        // Update total savings in user document
        transaction.set(userDocRef, {'totalSavings': newTotal}, SetOptions(merge: true));
        
        // Add new savings transaction
        final savingsRef = userDocRef
            .collection('savings')
            .doc(dateId)
            .collection('transactions')
            .doc();
            
        transaction.set(savingsRef, {
          ...savingsData,
          'type': 'savings',
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': now.toIso8601String(),
          'date': dateId,
        });
      });
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      }
      throw Exception('Failed to add savings: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getIncomesByDateRange(DateTime startDate, DateTime endDate) async {
    if (uid.isEmpty) throw Exception('User not authenticated');
    
    try {
      List<QueryDocumentSnapshot> allIncomes = [];
      
      for (DateTime date = startDate; date.isBefore(endDate.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
        String dateId = _formatDateId(date);
        List<QueryDocumentSnapshot> dayIncomes = await getIncomesByDate(dateId);
        allIncomes.addAll(dayIncomes);
      }
      
      return allIncomes;
    } catch (e) {
      throw Exception('Failed to get incomes by date range: $e');
    }
  }
}