import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction; // PENTING: hide Transaction
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/models/debt_transaction_model.dart';

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
// --- FUNGSI BARU UNTUK HUTANG ---

  // Mendapatkan stream data hutang untuk tampilan real-time
  Stream<List<DebtTransaction>> getDebtTransactions() {
    if (_user == null) return Stream.value([]);
    var ref = _db
        .collection('users')
        .doc(_user!.uid)
        .collection('debts') // Koleksi baru untuk hutang
        .orderBy('date', descending: true);
    return ref.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => DebtTransaction.fromMap(doc.data())).toList());
  }

  // Menyimpan (menambah/mengedit) data hutang
  Future<void> saveDebtTransaction(DebtTransaction debt) {
    if (_user == null) return Future.value();
    var ref =
        _db.collection('users').doc(_user!.uid).collection('debts').doc(debt.id);
    return ref.set(debt.toMap());
  }

  // Menghapus data hutang
  Future<void> deleteDebtTransaction(String debtId) {
    if (_user == null) return Future.value();
    var ref =
        _db.collection('users').doc(_user!.uid).collection('debts').doc(debtId);
    return ref.delete();
  }

  Future<void> deleteAllUserData() async {
    if (_user == null) return;

    final userRef = _db.collection('users').doc(_user!.uid);

    // Ambil referensi koleksi transaksi dan hutang
    final transactionsCollection = userRef.collection('transactions');
    final debtsCollection = userRef.collection('debts');

    // Buat batch write untuk operasi yang efisien
    final batch = _db.batch();

    // Hapus semua dokumen di koleksi 'transactions'
    final transactionsSnapshot = await transactionsCollection.get();
    for (final doc in transactionsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Hapus semua dokumen di koleksi 'debts'
    final debtsSnapshot = await debtsCollection.get();
    for (final doc in debtsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Jalankan semua operasi hapus dalam satu batch
    await batch.commit();
  }
}

