import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final TimeOfDay time;
  final String? notes;

  Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    required this.time,
    this.notes,
  });

  DateTime get fullDateTime => DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'time': '${time.hour}:${time.minute}',
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String? ?? '0:0').split(':');
    final time = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    return Transaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == map['type'], orElse: () => TransactionType.expense),
      date: (map['date'] as Timestamp).toDate(),
      time: time,
      notes: map['notes'],
    );
  }
}

enum TransactionType { income, expense, transfer }