class Income {
  final double amount;
  final String category;
  final DateTime timestamp;
  final String date;

  Income({
    required this.amount,
    required this.category,
    required this.timestamp,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'timestamp': timestamp,
      'date': date,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      date: map['date'] ?? '',
    );
  }
}