// lib/hutangpage.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/halamanutama.dart';
import 'package:flutter_application_1/rekappage.dart';
import 'package:flutter_application_1/settingpage.dart';
import 'package:flutter_application_1/edithutangpage.dart';
import 'package:intl/intl.dart';

// Asumsi DebtTransactionType dan DebtTransaction sudah ada dari add_edit_hutang_page.dart atau model terpisah

class HutangPage extends StatefulWidget {
  final bool isLoggedIn;
  final int initialTabIndex;

  const HutangPage({
    super.key,
    this.isLoggedIn = false,
    this.initialTabIndex = 2, // Default ke tab Hutang
  });

  @override
  State<HutangPage> createState() => _HutangPageState();
}

class _HutangPageState extends State<HutangPage> {
  final List<DebtTransaction> _debtTransactions = [];
  bool _isFabOpen = false;

  void _navigateToAddEditHutang(DebtTransactionType type) async {
    final DateTime initialDate = DateTime.now();

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AddEditHutangPage(
              transactionType: type,
              initialDate: initialDate,
              initialTabIndex: widget.initialTabIndex,
              isLoggedIn: widget.isLoggedIn,
            ),
      ),
    );

    if (!mounted) return;

    if (result != null && result is DebtTransaction) {
      setState(() {
        _debtTransactions.add(result);
        _debtTransactions.sort(
          (a, b) => DateTime(
            b.date.year,
            b.date.month,
            b.date.day,
            b.time.hour,
            b.time.minute,
          ).compareTo(
            DateTime(
              a.date.year,
              a.date.month,
              a.date.day,
              a.time.hour,
              a.time.minute,
            ),
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi ${type == DebtTransactionType.giving ? "Memberi" : "Menerima"} berhasil disimpan!',
          ),
        ),
      );
    }
    setState(() {
      _isFabOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
        automaticallyImplyLeading:
            false, // Penting: mencegah Flutter menambahkan tombol back secara otomatis

        title: const Text(
          'Hutang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body:
          _debtTransactions.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, size: 100, color: Colors.grey[300]),
                    Icon(Icons.search, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      'Tidak ada data',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _debtTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _debtTransactions[index];
                  final String formattedAmount = NumberFormat.decimalPattern(
                    'id_ID',
                  ).format(transaction.amount);
                  final Color amountColor =
                      transaction.type == DebtTransactionType.giving
                          ? Colors.red
                          : Colors.green;
                  final String sign =
                      transaction.type == DebtTransactionType.giving
                          ? '-'
                          : '+';
                  final String typeLabel =
                      transaction.type == DebtTransactionType.giving
                          ? 'Hutang'
                          : 'Piutang';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.personName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$typeLabel - ${DateFormat('dd MMM yyyy', 'id_ID').format(transaction.date)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (transaction.notes != null &&
                                    transaction.notes!.isNotEmpty)
                                  Text(
                                    transaction.notes!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '$sign Rp $formattedAmount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ), // Jarak antar tombol
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((255 * 0.1).round()),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Menerima',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      heroTag: 'receiveDebtFab',
                      onPressed:
                          () => _navigateToAddEditHutang(
                            DebtTransactionType.receiving,
                          ), // <--- Navigasi ke halaman form
                      backgroundColor: Colors.orange[400],
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _isFabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_isFabOpen,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ), // Jarak antar tombol
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((255 * 0.1).round()),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Memberi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      heroTag: 'giveDebtFab',
                      onPressed:
                          () => _navigateToAddEditHutang(
                            DebtTransactionType.giving,
                          ), // <--- Navigasi ke halaman form
                      backgroundColor: Colors.orange,
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        currentIndex: widget.initialTabIndex,
        selectedItemColor: const Color(0xFFFF9800),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == widget.initialTabIndex) {
            return;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                switch (index) {
                  case 0:
                    return HomePage(
                      isLoggedIn: widget.isLoggedIn,
                      initialTabIndex: 0,
                    );
                  case 1:
                    return RekapPage(
                      isLoggedIn: widget.isLoggedIn,
                      initialTabIndex: 1,
                    );
                  case 2:
                    return HutangPage(
                      isLoggedIn: widget.isLoggedIn,
                      initialTabIndex: 2,
                    );
                  case 3:
                    return SettingsPage(
                      initialTabIndex: 3,
                      isLoggedIn: widget.isLoggedIn,
                    );
                  default:
                    return HomePage(
                      isLoggedIn: widget.isLoggedIn,
                      initialTabIndex: 0,
                    );
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
