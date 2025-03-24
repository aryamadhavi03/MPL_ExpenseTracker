import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/fixed_expenses_screen.dart';
import 'screens/spin_and_save_screen.dart';
import 'screens/daily_quiz_screen.dart';
import 'screens/savings_challenges_screen.dart';
import 'package:flutter/material.dart';
import 'services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ExpenseTrackerApp(),
    ),
  );
}


class ExpenseTrackerApp extends StatefulWidget {
  @override
  _ExpenseTrackerAppState createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Expense Tracker',
          theme: themeProvider.themeData,
          initialRoute: '/signup',
          routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        // '/add-expense': (context) => AddExpenseScreen(),
        // '/add-income': (context) => AddIncomeScreen(),
        // '/calendar': (context) => CalendarScreen(),
        // '/statistics': (context) => StatisticsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/fixedExpenses': (context) => FixedExpensesScreen(),
        '/spinAndSave': (context) => SpinAndSaveScreen(),
        '/dailyQuiz': (context) => DailyQuizScreen(),
        '/savingsChallenges': (context) => SavingsChallengesScreen()
          },
        );
      },
    );
  }
}
  

