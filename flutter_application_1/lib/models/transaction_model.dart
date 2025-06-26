// lib/models/transaction_model.dart
import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String title;
  final String subtitle; // Ini akan menjadi 'Kategori'
  final double amount;
  final TransactionType type;
  final DateTime date;
  final TimeOfDay time;
  final String? notes; // <--- PROPERTI BARU UNTUK KETERANGAN

  Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    required this.time,
    this.notes, // Tambahkan ke konstruktor
  });

  DateTime get fullDateTime =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Transaction copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? amount,
    TransactionType? type,
    DateTime? date,
    TimeOfDay? time,
    String? notes, // Tambahkan ke copyWith
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes, // Salin notes juga
    );
  }
}

enum TransactionType { income, expense, transfer }
