// lib/rekappage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/halamanutama.dart';
import 'package:flutter_application_1/hutangpage.dart';
import 'package:flutter_application_1/settingpage.dart';

class RekapPage extends StatefulWidget {
  final bool isLoggedIn;
  final int initialTabIndex;

  const RekapPage({
    super.key,
    this.isLoggedIn = false,
    this.initialTabIndex = 1, // Default ke tab Rekap
  });

  @override
  State<RekapPage> createState() => _RekapPageState();
}

class _RekapPageState extends State<RekapPage> {
  bool _isRealtimeSelected = true;

  final double _sisaSaldo = 1500000;
  final double _totalPemasukan = 2000000;
  final double _totalPengeluaran = 500000;

  Widget _buildSaldoRow({
    required String label,
    required double value,
    Color? color,
    bool showPercentage = false,
    double? percentage,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (showPercentage && percentage != null)
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        Text(
          formatter.format(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    final String startDate = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime(2025, 6, 1));
    final String endDate = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime(2025, 6, 30));

    double percentage =
        (_totalPemasukan != 0) ? (_sisaSaldo / _totalPemasukan) * 100 : 0;
    if (percentage > 100) {
      percentage = 100;
    }
    if (percentage < 0) {
      percentage = 0;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,

        title: const Text(
          'Rekap',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRealtimeSelected = true;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _isRealtimeSelected
                                  ? const Color(0xFFFF9800)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Realtime',
                          style: TextStyle(
                            color:
                                _isRealtimeSelected
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRealtimeSelected = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              !_isRealtimeSelected
                                  ? const Color(0xFFFF9800)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Bulanan',
                          style: TextStyle(
                            color:
                                !_isRealtimeSelected
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$startDate - $endDate',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 20,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sisa Saldo',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(_sisaSaldo),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
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
              child: Column(
                children: [
                  _buildSaldoRow(
                    label: 'Sisa Saldo',
                    value: _sisaSaldo,
                    percentage: percentage,
                    color: Colors.green,
                    showPercentage: true,
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildSaldoRow(
                    label: 'Total Pemasukan',
                    value: _totalPemasukan,
                    color: Colors.blue,
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildSaldoRow(
                    label: 'Total Pengeluaran',
                    value: _totalPengeluaran,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
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
