// lib/hutangpage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/halamanutama.dart';
import 'package:flutter_application_1/rekappage.dart';
import 'package:flutter_application_1/settingpage.dart';
import 'package:flutter_application_1/edithutangpage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/debt_transaction_model.dart';
import 'package:flutter_application_1/backend/database_service.dart';
import 'package:flutter_application_1/theme_provider.dart';

class HutangPage extends StatefulWidget {
  final bool isLoggedIn;
  final int initialTabIndex;

  const HutangPage({super.key, this.isLoggedIn = false, this.initialTabIndex = 2});

  @override
  State<HutangPage> createState() => _HutangPageState();
}

class _HutangPageState extends State<HutangPage> {
  final DatabaseService _dbService = DatabaseService();
  bool _isFabOpen = false;

  void _navigateToAddEditHutang(DebtTransactionType type, {DebtTransaction? transaction}) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditHutangPage(
          transactionType: type,
          transaction: transaction,
          initialDate: DateTime.now(),
        ),
      ),
    );
    if (mounted) setState(() => _isFabOpen = false);
  }

  Future<void> _toggleIsPaid(DebtTransaction transaction) async {
    final updatedTransaction = DebtTransaction(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      personName: transaction.personName,
      notes: transaction.notes,
      date: transaction.date,
      time: transaction.time,
      isPaid: !transaction.isPaid,
    );
    await _dbService.saveDebtTransaction(updatedTransaction);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themeProvider.mainColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Hutang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      ),
      body: StreamBuilder<List<DebtTransaction>>(
        stream: _dbService.getDebtTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat data hutang.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text('Tidak ada data hutang.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const Text('Tekan tombol + untuk menambah data baru.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final debtTransactions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: debtTransactions.length,
            itemBuilder: (context, index) {
              final transaction = debtTransactions[index];
              final String formattedAmount = NumberFormat.decimalPattern('id_ID').format(transaction.amount);
              final Color amountColor = transaction.type == DebtTransactionType.giving ? Colors.green : Colors.red;
              final String sign = transaction.type == DebtTransactionType.giving ? '+' : '-';
              final String typeLabel = transaction.type == DebtTransactionType.giving ? 'Piutang' : 'Utang';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () => _navigateToAddEditHutang(transaction.type, transaction: transaction),
                  borderRadius: BorderRadius.circular(15),
                  child: Opacity(
                    opacity: transaction.isPaid ? 0.5 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Checkbox(value: transaction.isPaid, onChanged: (_) => _toggleIsPaid(transaction), activeColor: Colors.green),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.personName,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: transaction.isPaid ? TextDecoration.lineThrough : null),
                                ),
                                Text('$typeLabel - ${DateFormat('dd MMM yyyy', 'id_ID').format(transaction.date)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                if (transaction.notes?.isNotEmpty ?? false)
                                  Text(transaction.notes!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Text(
                            '$sign Rp $formattedAmount',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: amountColor, decoration: transaction.isPaid ? TextDecoration.lineThrough : null),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: const Text('Menerima Utang', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                FloatingActionButton.small(heroTag: 'receiveDebtFab', onPressed: () => _navigateToAddEditHutang(DebtTransactionType.receiving), backgroundColor: Colors.red[400], child: const Icon(Icons.arrow_downward, color: Colors.white)),
              ]),
            ),
          if (_isFabOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: const Text('Memberi Utang', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                FloatingActionButton.small(heroTag: 'giveDebtFab', onPressed: () => _navigateToAddEditHutang(DebtTransactionType.giving), backgroundColor: Colors.green[400], child: const Icon(Icons.arrow_upward, color: Colors.white)),
              ]),
            ),
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
        currentIndex: widget.initialTabIndex,
        selectedItemColor: themeProvider.mainColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == widget.initialTabIndex) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                switch (index) {
                  case 0:
                    return HomePage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 0);
                  case 1:
                    return RekapPage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 1);
                  case 2:
                    return HutangPage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 2);
                  case 3:
                    return SettingsPage(initialTabIndex: 3, isLoggedIn: widget.isLoggedIn);
                  default:
                    return HomePage(isLoggedIn: widget.isLoggedIn, initialTabIndex: 0);
                }
              },
            ),
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}