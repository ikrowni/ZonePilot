import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String description;
  final double amount;
  final DateTime date;
  final String? receiptImageUrl;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.receiptImageUrl,
  });

  factory Expense.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Expense(
      id: snapshot.id,
      description: data['description'],
      amount: data['amount'],
      date: (data['date'] as Timestamp).toDate(),
      receiptImageUrl: data['receiptImageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'receiptImageUrl': receiptImageUrl,
    };
  }
}