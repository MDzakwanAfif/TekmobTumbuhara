import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction; // PENTING: hide Transaction
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/transaction_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  // --- HANYA FUNGSI UNTUK TRANSAKSI ---

  // Mendapatkan stream transaksi untuk tampilan real-time
  Stream<List<Transaction>> getTransactions() {
    if (_user == null) return Stream.value([]);
    var ref = _db.collection('users').doc(_user!.uid).collection('transactions').orderBy('date', descending: true);
    return ref.snapshots().map((snapshot) => snapshot.docs.map((doc) => Transaction.fromMap(doc.data())).toList());
  }

  // Menyimpan (menambah/mengedit) transaksi
  Future<void> saveTransaction(Transaction transaction) {
    if (_user == null) return Future.value();
    var ref = _db.collection('users').doc(_user!.uid).collection('transactions').doc(transaction.id);
    return ref.set(transaction.toMap());
  }

  // Menghapus transaksi
  Future<void> deleteTransaction(String transactionId) {
    if (_user == null) return Future.value();
    var ref = _db.collection('users').doc(_user!.uid).collection('transactions').doc(transactionId);
    return ref.delete();
  }

  
  Future<List<Transaction>> getAllTransactions() async {
    if (_user == null) return [];
    var ref = _db.collection('users').doc(_user!.uid).collection('transactions');
    var snapshot = await ref.get();
    return snapshot.docs.map((doc) => Transaction.fromMap(doc.data())).toList();
  }
}

