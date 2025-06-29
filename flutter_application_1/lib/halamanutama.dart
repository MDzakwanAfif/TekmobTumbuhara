import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/edittransactionpage.dart';
import 'package:flutter_application_1/settingpage.dart';
import 'package:flutter_application_1/riwayattransaksi.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/rekappage.dart';
import 'package:flutter_application_1/hutangpage.dart';
import 'package:flutter_application_1/backend/database_service.dart';
import 'package:flutter_application_1/theme_provider.dart';

class HomePage extends StatefulWidget {
  final bool isLoggedIn;
  final int initialTabIndex;
  const HomePage({super.key, this.isLoggedIn = false, this.initialTabIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  final DatabaseService _dbService = DatabaseService();
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        switch (index) {
          case 0:
            return HomePage(initialTabIndex: 0, isLoggedIn: widget.isLoggedIn);
          case 1:
            return RekapPage(initialTabIndex: 1, isLoggedIn: widget.isLoggedIn);
          case 2:
            return HutangPage(initialTabIndex: 2, isLoggedIn: widget.isLoggedIn);
          case 3:
            return SettingsPage(initialTabIndex: 3, isLoggedIn: widget.isLoggedIn);
          default:
            return HomePage(initialTabIndex: 0, isLoggedIn: widget.isLoggedIn);
        }
      }),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: themeProvider.mainColor,
            colorScheme: ColorScheme.light(primary: themeProvider.mainColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _goToPreviousDay() => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
  void _goToNextDay() => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));

  Map<String, double> _calculateBalances(List<Transaction> transactions) {
    double totalIncome = 0, totalExpense = 0;
    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else if (t.type == TransactionType.expense) {
        totalExpense += t.amount;
      }
    }
    return {'income': totalIncome, 'expense': totalExpense, 'balance': totalIncome - totalExpense};
  }

  Future<void> _navigateToAddEditTransaction(TransactionType type, {Transaction? transactionToEdit}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTransactionPage(
          transactionType: type,
          transaction: transactionToEdit,
          initialDate: _selectedDate,
          appBarTitle: transactionToEdit == null ? 'Tambah Transaksi' : 'Edit Transaksi',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final formatter = NumberFormat.decimalPattern('id_ID');
    String formattedDate = DateFormat('EEE, dd MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: themeProvider.mainColor,
          elevation: 0,
          shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(50))),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: _goToPreviousDay),
                GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Text(formattedDate, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20), onPressed: _goToNextDay),
                IconButton(
                    icon: const Icon(Icons.history, color: Colors.white, size: 24),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HistoryPage()));
                    }),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _dbService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan memuat data'));
          }

          final allTransactions = snapshot.data ?? [];
          final transactionsForSelectedDate = allTransactions
              .where((t) =>
                  t.date.year == _selectedDate.year &&
                  t.date.month == _selectedDate.month &&
                  t.date.day == _selectedDate.day)
              .toList();

          return _buildContent(context, transactionsForSelectedDate, formatter);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: const Text('Pemasukan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                FloatingActionButton.small(heroTag: 'incomeFab', onPressed: () { setState(() => _isFabOpen = false); _navigateToAddEditTransaction(TransactionType.income); }, backgroundColor: Colors.green, child: const Icon(Icons.attach_money, color: Colors.white)),
              ]),
            ),
          if (_isFabOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: const Text('Pengeluaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                FloatingActionButton.small(heroTag: 'expenseFab', onPressed: () { setState(() => _isFabOpen = false); _navigateToAddEditTransaction(TransactionType.expense); }, backgroundColor: Colors.red, child: const Icon(Icons.shopping_cart, color: Colors.white)),
              ]),
            ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
            backgroundColor: themeProvider.mainColor,
            shape: const CircleBorder(),
            child: Icon(_isFabOpen ? Icons.close : Icons.add, color: Colors.white, size: 30),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.paid), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Rekap'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Hutang'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: themeProvider.mainColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Transaction> dailyTransactions, NumberFormat formatter) {
    final balances = _calculateBalances(dailyTransactions);
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(50), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))]),
            child: Row(
              children: [
                Expanded(child: Column(children: [
                  const Text('Pemasukan', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text('+${formatter.format(balances['income'])}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ])),
                Expanded(child: Column(children: [
                  const Text('Pengeluaran', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(formatter.format(balances['expense']), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ])),
                Expanded(child: Column(children: [
                  const Text('Selisih', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text('${balances['balance']! >= 0 ? '+' : ''}${formatter.format(balances['balance'])}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: balances['balance']! >= 0 ? Colors.black87 : Colors.red)),
                ])),
              ],
            ),
          ),
        ),
        Positioned(
          top: 110,
          left: 0,
          right: 0,
          bottom: 0,
          child: dailyTransactions.isEmpty
              ? const Center(child: Text('Tidak ada transaksi pada tanggal ini.\nTekan + untuk menambahkan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  children: dailyTransactions.map((transaction) {
                    return _buildTransactionItem(transaction: transaction, onEdit: () => _navigateToAddEditTransaction(transaction.type, transactionToEdit: transaction));
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({required Transaction transaction, required VoidCallback onEdit}) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    final amountColor = transaction.type == TransactionType.income ? Colors.green : (transaction.type == TransactionType.expense ? Colors.red : Colors.blue);
    final sign = transaction.type == TransactionType.income ? '+' : (transaction.type == TransactionType.expense ? '-' : '');
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(30), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(transaction.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${transaction.subtitle} - ${transaction.time.format(context)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            Text('$sign${formatter.format(transaction.amount)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: amountColor)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}