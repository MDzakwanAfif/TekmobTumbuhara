// homepage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Pastikan sudah ada di pubspec.yaml
import 'edittransactionpage.dart'; // Import halaman tambah/edit
import 'settingpage.dart'; // Import halaman pengaturan

// --- MODEL DATA TRANSAKSI ---
// Kelas ini harus berada di file yang sama atau di file terpisah yang diimport oleh kedua halaman
// Contoh: bisa di `models/transaction.dart` lalu import di sini dan di add_edit_transaction_page.dart
class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type; // Pemasukan atau Pengeluaran
  final DateTime date; // Tanggal transaksi
  final TimeOfDay time; // Waktu transaksi

  Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    required this.time,
  });

  // Helper untuk menggabungkan tanggal dan waktu menjadi DateTime lengkap
  DateTime get fullDateTime =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  // Fungsi untuk membuat copy dari transaksi (berguna untuk edit)
  Transaction copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? amount,
    TransactionType? type,
    DateTime? date,
    TimeOfDay? time,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}

// Enum untuk tipe transaksi
enum TransactionType { income, expense, transfer }

class HomePage extends StatefulWidget {
  final bool isLoggedIn;
  final int initialTabIndex; // Untuk Bottom Navigation Bar

  const HomePage({
    super.key,
    this.isLoggedIn = false,
    this.initialTabIndex = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index yang aktif di Bottom Navigation Bar
  DateTime _selectedDate = DateTime.now(); // Tanggal yang sedang ditampilkan
  List<Transaction> _transactions = []; // Daftar transaksi (data dummy)
  final Uuid _uuid = const Uuid(); // Untuk menghasilkan ID unik

  // State untuk FAB Speed Dial
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex; // Set indeks awal dari parameter
    // Inisialisasi data transaksi contoh
    _transactions = [
      Transaction(
        id: _uuid.v4(), // ID unik
        title: 'Gaji Bulanan',
        subtitle: 'Income',
        amount: 1500000,
        type: TransactionType.income,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 9, minute: 0),
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Beli Kopi',
        subtitle: 'Minuman',
        amount: 35000,
        type: TransactionType.expense,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 14, minute: 30),
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Makan Siang',
        subtitle: 'Makanan',
        amount: 50000,
        type: TransactionType.expense,
        date: DateTime.now().subtract(
          const Duration(days: 1),
        ), // Transaksi kemarin
        time: const TimeOfDay(hour: 12, minute: 0),
      ),
    ];
    // Pastikan transaksi diurutkan saat inisialisasi
    _transactions.sort((a, b) => b.fullDateTime.compareTo(a.fullDateTime));
  }

  // Metode untuk menangani tap pada Bottom Navigation Bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Logika navigasi ke halaman yang berbeda
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          switch (index) {
            case 0: // Transaksi
              return const HomePage(initialTabIndex: 0);
            case 1: // Rekap (Placeholder)
              // return const RekapPage(initialTabIndex: 1); // Jika Anda membuatnya nanti
              return const HomePage(
                initialTabIndex: 1,
              ); // Tetap di HomePage untuk saat ini
            case 2: // Hutang (Placeholder)
              // return const HutangPage(initialTabIndex: 2); // Jika Anda membuatnya nanti
              return const HomePage(
                initialTabIndex: 2,
              ); // Tetap di HomePage untuk saat ini
            case 3: // Pengaturan
              return const SettingsPage(initialTabIndex: 3);
            default:
              return const HomePage(initialTabIndex: 0);
          }
        },
      ),
    );
  }

  // Fungsi untuk memilih tanggal dari kalender
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // Batas awal
      lastDate: DateTime(2030), // Batas akhir
      locale: const Locale('id', 'ID'), // Untuk bahasa Indonesia
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFFF9800), // Warna header kalender
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF9800),
            ), // Warna pilihan tanggal
            textButtonTheme: TextButtonThemeData(
              // Untuk tombol 'OK', 'CANCEL'
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF9800),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _transactions.sort(
          (a, b) => b.fullDateTime.compareTo(a.fullDateTime),
        ); // Urutkan lagi
      });
    }
  }

  // Fungsi untuk navigasi ke tanggal sebelumnya
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _transactions.sort(
        (a, b) => b.fullDateTime.compareTo(a.fullDateTime),
      ); // Urutkan lagi
    });
  }

  // Fungsi untuk navigasi ke tanggal sesudahnya
  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _transactions.sort(
        (a, b) => b.fullDateTime.compareTo(a.fullDateTime),
      ); // Urutkan lagi
    });
  }

  // Fungsi untuk menghitung total pemasukan, pengeluaran, dan selisih
  Map<String, double> _calculateBalances() {
    double totalIncome = 0;
    double totalExpense = 0;

    // Filter transaksi berdasarkan tanggal yang dipilih
    final dailyTransactions =
        _transactions
            .where(
              (t) =>
                  t.date.year == _selectedDate.year &&
                  t.date.month == _selectedDate.month &&
                  t.date.day == _selectedDate.day,
            )
            .toList();

    for (var t in dailyTransactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else if (t.type == TransactionType.expense) {
        totalExpense += t.amount;
      }
    }
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  // Fungsi untuk navigasi ke halaman Tambah/Edit Transaksi
  Future<void> _navigateToAddEditTransaction(
    TransactionType type, {
    Transaction? transactionToEdit,
  }) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AddEditTransactionPage(
              transactionType: type,
              transaction:
                  transactionToEdit, // Teruskan transaksi jika dalam mode edit
              initialDate:
                  _selectedDate, // Kirim tanggal saat ini sebagai initialDate
            ),
      ),
    );

    // Jika hasil dari halaman AddEditTransactionPage adalah sebuah Transaksi
    if (result != null && result is Transaction) {
      setState(() {
        if (transactionToEdit == null) {
          // Menambahkan transaksi baru
          _transactions.add(result);
        } else {
          // Mengupdate transaksi yang sudah ada
          int index = _transactions.indexWhere((t) => t.id == result.id);
          if (index != -1) {
            _transactions[index] = result;
          }
        }
        // Pastikan transaksi diurutkan ulang setelah penambahan/pengeditan
        _transactions.sort((a, b) => b.fullDateTime.compareTo(a.fullDateTime));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final balances = _calculateBalances();
    // Formatter untuk mata uang Rupiah tanpa desimal
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Format tanggal untuk tampilan AppBar
    String formattedDate = DateFormat(
      'EEE, dd MMM yyyy',
      'id_ID',
    ).format(_selectedDate);

    // Filter transaksi untuk tanggal yang dipilih dan urutkan
    final transactionsForSelectedDate =
        _transactions
            .where(
              (t) =>
                  t.date.year == _selectedDate.year &&
                  t.date.month == _selectedDate.month &&
                  t.date.day == _selectedDate.day,
            )
            .toList();
    transactionsForSelectedDate.sort(
      (a, b) => b.fullDateTime.compareTo(a.fullDateTime),
    ); // Urutkan terbaru di atas

    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna background keseluruhan
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Tinggi AppBar
        child: AppBar(
          backgroundColor: const Color(0xFFFF9800), // Warna oranye
          elevation: 0, // Tanpa shadow
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(50), // Bentuk melengkung di bawah
            ),
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed:
                          _goToPreviousDay, // Panggil fungsi navigasi sebelumnya
                    ),
                    GestureDetector(
                      // Tambahkan GestureDetector agar tanggal bisa diklik
                      onTap:
                          () => _selectDate(
                            context,
                          ), // Panggil fungsi pilih tanggal
                      child: Text(
                        formattedDate, // Gunakan tanggal yang di-format
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed:
                          _goToNextDay, // Panggil fungsi navigasi selanjutnya
                    ),
                    // Ikon Download
                    IconButton(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download data...')),
                        );
                      },
                    ),
                    // Ikon Riwayat
                    IconButton(
                      icon: const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Riwayat Transaksi akan datang!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Panel Putih Pemasukan/Pengeluaran/Selisih
          Positioned(
            top: 0, // Posisi relatif ke body
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Pemasukan',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatter.format(balances['income']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green, // Warna hijau untuk pemasukan
                        ),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1,
                    width: 20,
                    indent: 5,
                    endIndent: 5,
                  ),
                  Column(
                    children: [
                      const Text(
                        'Pengeluaran',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatter.format(balances['expense']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red, // Warna merah untuk pengeluaran
                        ),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1,
                    width: 20,
                    indent: 5,
                    endIndent: 5,
                  ),
                  Column(
                    children: [
                      const Text(
                        'Selisih',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatter.format(balances['balance']),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              balances['balance']! >= 0
                                  ? Colors.black87
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Daftar Transaksi
          Positioned(
            top: 140, // Sesuaikan dengan tinggi panel atas
            left: 0,
            right: 0,
            bottom: 80, // Beri ruang untuk Bottom Navigation Bar
            child:
                transactionsForSelectedDate.isEmpty
                    ? const Center(
                      child: Text(
                        'Tidak ada transaksi pada tanggal ini.\nTekan + untuk menambahkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children:
                            transactionsForSelectedDate.map((transaction) {
                              Color amountColor;
                              String sign;
                              if (transaction.type == TransactionType.income) {
                                amountColor = Colors.green;
                                sign = '+';
                              } else if (transaction.type ==
                                  TransactionType.expense) {
                                amountColor = Colors.red;
                                sign = '-';
                              } else {
                                // TransactionType.transfer
                                amountColor = Colors.blue;
                                sign = '';
                              }

                              return _buildTransactionItem(
                                transaction: transaction,
                                amountColor: amountColor,
                                sign: sign,
                                onEdit: () {
                                  _navigateToAddEditTransaction(
                                    transaction.type,
                                    transactionToEdit: transaction,
                                  );
                                },
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
      // --- FAB Speed Dial ---
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Pemasukan FAB
          AnimatedOpacity(
            opacity: _isFabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              // Mencegah klik saat tidak terlihat
              ignoring: !_isFabOpen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Pemasukan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'incomeFab', // Penting untuk unique heroTag
                    onPressed: () {
                      setState(() {
                        _isFabOpen = false; // Tutup FAB setelah dipilih
                      });
                      _navigateToAddEditTransaction(TransactionType.income);
                    },
                    backgroundColor: Colors.green, // Warna hijau
                    child: const Icon(
                      Icons.attach_money,
                      color: Colors.white,
                    ), // Ikon uang
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Pengeluaran FAB
          AnimatedOpacity(
            opacity: _isFabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              // Mencegah klik saat tidak terlihat
              ignoring: !_isFabOpen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Pengeluaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'expenseFab', // Penting untuk unique heroTag
                    onPressed: () {
                      setState(() {
                        _isFabOpen = false; // Tutup FAB setelah dipilih
                      });
                      _navigateToAddEditTransaction(TransactionType.expense);
                    },
                    backgroundColor: Colors.red, // Warna merah
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ), // Ikon keranjang
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // FAB Utama
          FloatingActionButton(
            heroTag: 'mainFab', // Penting untuk unique heroTag
            onPressed: () {
              setState(() {
                _isFabOpen = !_isFabOpen; // Toggle buka/tutup FAB
              });
            },
            backgroundColor: const Color(0xFFFF9800),
            shape: const CircleBorder(),
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      // --- END FAB Speed Dial ---

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.paid), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Rekap'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Hutang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex, // Indeks yang aktif
        selectedItemColor: const Color(
          0xFFFF9800,
        ), // Warna oranye saat terpilih
        unselectedItemColor: Colors.grey, // Warna abu-abu saat tidak terpilih
        onTap: _onItemTapped, // Panggil metode navigasi
        type: BottomNavigationBarType.fixed, // Penting agar semua item terlihat
        backgroundColor: Colors.white,
      ),
    );
  }

  // Widget pembantu untuk menampilkan setiap item transaksi
  Widget _buildTransactionItem({
    required Transaction transaction,
    required Color amountColor,
    required String sign,
    required VoidCallback onEdit, // Callback untuk aksi edit
  }) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ); // Format tanpa desimal

    return GestureDetector(
      // GestureDetector agar item bisa diklik untuk edit
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    // Menampilkan waktu transaksi di bawah judul
                    '${transaction.subtitle} - ${transaction.time.format(context)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '$sign${formatter.format(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
