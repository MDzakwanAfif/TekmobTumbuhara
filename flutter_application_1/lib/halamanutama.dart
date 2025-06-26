// lib/halamanutama.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'edittransactionpage.dart';
import 'settingpage.dart';
import 'riwayattransaksi.dart';
import 'models/transaction_model.dart';
import 'rekappage.dart';
import 'hutangpage.dart';

class HomePage extends StatefulWidget {
  final bool isLoggedIn;
  final int initialTabIndex;

  const HomePage({
    super.key,
    this.isLoggedIn = false,
    this.initialTabIndex = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  List<Transaction> _transactions = [];
  final Uuid _uuid = const Uuid();

  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _transactions = [
      Transaction(
        id: _uuid.v4(),
        title: 'Gaji Bulanan',
        subtitle: 'Pekerjaan',
        amount: 1500000,
        type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 2)),
        time: const TimeOfDay(hour: 9, minute: 0),
        notes: 'Gaji dari kantor bulan ini.',
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Beli Kopi',
        subtitle: 'Minuman',
        amount: 35000,
        type: TransactionType.expense,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 14, minute: 30),
        notes: 'Kopi di Starbaks.',
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Makan Siang',
        subtitle: 'Makanan',
        amount: 50000,
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: const TimeOfDay(hour: 12, minute: 0),
        notes: 'Nasi padang.',
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Transfer ke Rekening',
        subtitle: 'Tabungan',
        amount: 200000,
        type: TransactionType.transfer,
        date: DateTime.now().subtract(const Duration(days: 3)),
        time: const TimeOfDay(hour: 10, minute: 0),
        notes: 'Transfer ke rekening BNI pribadi.',
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Penjualan Barang',
        subtitle: 'Bisnis',
        amount: 75000,
        type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: const TimeOfDay(hour: 16, minute: 0),
        notes: 'Penjualan barang bekas di Tokopedia.',
      ),
    ];
    _transactions.sort((a, b) => b.fullDateTime.compareTo(a.fullDateTime));
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          switch (index) {
            case 0:
              return HomePage(
                initialTabIndex: 0,
                isLoggedIn: widget.isLoggedIn,
              );
            case 1:
              return RekapPage(
                initialTabIndex: 1,
                isLoggedIn: widget.isLoggedIn,
              );
            case 2:
              return HutangPage(
                initialTabIndex: 2,
                isLoggedIn: widget.isLoggedIn,
              );
            case 3:
              return SettingsPage(
                initialTabIndex: 3,
                isLoggedIn: widget.isLoggedIn,
              );
            default:
              return HomePage(
                initialTabIndex: 0,
                isLoggedIn: widget.isLoggedIn,
              );
          }
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFFF9800),
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF9800)),
            textButtonTheme: TextButtonThemeData(
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
        _transactions.sort((a, b) => b.fullDateTime.compareTo(a.fullDateTime));
      });
    }
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _transactions.sort((a, b) => b.fullDateTime.compareTo(a.fullDateTime));
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _transactions.sort((a, b) => b.fullDateTime.compareTo(a.fullDateTime));
    });
  }

  Map<String, double> _calculateBalances() {
    double totalIncome = 0;
    double totalExpense = 0;

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

  Future<void> _navigateToAddEditTransaction(
    TransactionType type, {
    Transaction? transactionToEdit,
  }) async {
    final String title =
        transactionToEdit == null ? 'Tambah Transaksi' : 'Edit Transaksi';

    final dynamic result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AddEditTransactionPage(
              transactionType: type,
              transaction: transactionToEdit,
              initialDate: _selectedDate,
              appBarTitle: title,
            ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        if (result is Transaction) {
          if (transactionToEdit == null) {
            _transactions.add(result);
          } else {
            int index = _transactions.indexWhere((t) => t.id == result.id);
            if (index != -1) {
              _transactions[index] = result;
            }
          }
        } else if (result is String) {
          _transactions.removeWhere((t) => t.id == result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil dihapus')),
          );
        }
        _transactions.sort((a, b) => b.fullDateTime.compareTo(a.fullDateTime));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final balances = _calculateBalances();
    final formatter = NumberFormat.decimalPattern('id_ID');

    String formattedDate = DateFormat(
      'EEE, dd MMM yyyy',
      'id_ID',
    ).format(_selectedDate);

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
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: const Color(0xFFFF9800),
          elevation: 0,
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
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
                      onPressed: _goToPreviousDay,
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Text(
                        formattedDate,
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
                      onPressed: _goToNextDay,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder:
                                    (context) => HistoryPage(
                                      allTransactions: _transactions,
                                    ),
                              ),
                            )
                            .then((_) {
                              setState(() {
                                _transactions.sort(
                                  (a, b) =>
                                      b.fullDateTime.compareTo(a.fullDateTime),
                                );
                              });
                            });
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
          Positioned(
            top: 0,
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
                    color: Colors.grey.withAlpha((255 * 0.2).round()),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Pemasukan',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '+${formatter.format(balances['income'])}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Selisih',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${balances['balance']! >= 0 ? '+' : '-'}${formatter.format((balances['balance']!).abs())}',
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
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 80,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: _isFabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
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
                          color: Colors.black.withAlpha((255 * 0.1).round()),
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
                    heroTag: 'incomeFab',
                    onPressed: () {
                      setState(() {
                        _isFabOpen = false;
                      });
                      _navigateToAddEditTransaction(TransactionType.income);
                    },
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.attach_money, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: _isFabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
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
                          color: Colors.black.withAlpha((255 * 0.1).round()),
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
                    heroTag: 'expenseFab',
                    onPressed: () {
                      setState(() {
                        _isFabOpen = false;
                      });
                      _navigateToAddEditTransaction(TransactionType.expense);
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: () {
              setState(() {
                _isFabOpen = !_isFabOpen;
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
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFF9800),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTransactionItem({
    required Transaction transaction,
    required Color amountColor,
    required String sign,
    required VoidCallback onEdit,
  }) {
    final formatter = NumberFormat.decimalPattern('id_ID');

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((255 * 0.1).round()),
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
                    '${transaction.subtitle} - ${transaction.time.format(context)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '${transaction.type == TransactionType.income
                  ? '+'
                  : transaction.type == TransactionType.expense
                  ? '-'
                  : ''}${formatter.format(transaction.amount)}',
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
