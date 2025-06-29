import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum DebtTransactionType {
  giving, // Anda memberi utang ke orang lain (Piutang)
  receiving, // Anda menerima utang dari orang lain (Utang)
}

class DebtTransaction {
  final String id;
  final DebtTransactionType type;
  final double amount;
  final String personName;
  final String? notes;
  final DateTime date;
  final TimeOfDay time;
  bool isPaid; // Status untuk menandai lunas

  DebtTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.personName,
    this.notes,
    required this.date,
    required this.time,
    this.isPaid = false, // Secara default, setiap utang baru dianggap belum lunas
  });

  DateTime get fullDateTime =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  // Fungsi untuk mengubah objek Dart menjadi Map agar bisa disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'personName': personName,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'time': '${time.hour}:${time.minute}',
      'isPaid': isPaid,
    };
  }

  // Fungsi untuk membuat objek Dart dari data Map yang diambil dari Firestore
  factory DebtTransaction.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String? ?? '0:0').split(':');
    final time = TimeOfDay(
        hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

    return DebtTransaction(
      id: map['id'] ?? '',
      type: DebtTransactionType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => DebtTransactionType.giving),
      amount: (map['amount'] ?? 0).toDouble(),
      personName: map['personName'] ?? '',
      notes: map['notes'],
      date: (map['date'] as Timestamp).toDate(),
      time: time,
      isPaid: map['isPaid'] ?? false,
    );
  }
}