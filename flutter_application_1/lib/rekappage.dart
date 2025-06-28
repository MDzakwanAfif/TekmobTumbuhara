import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/halamanutama.dart';
import 'package:flutter_application_1/hutangpage.dart';
import 'package:flutter_application_1/settingpage.dart';

class Transaksi {
  final DateTime tanggal;
  final double nominal;
  final bool isPemasukan;

  Transaksi({
    required this.tanggal,
    required this.nominal,
    required this.isPemasukan,
  });
}

class RekapPage extends StatefulWidget {
  final bool isLoggedIn;
  final int initialTabIndex;

  const RekapPage({
    super.key,
    this.isLoggedIn = false,
    this.initialTabIndex = 1,
  });

  @override
  State<RekapPage> createState() => _RekapPageState();
}

class _RekapPageState extends State<RekapPage> {
  DateTime _startDate = DateTime(2025, 6, 1);
  DateTime _endDate = DateTime(2025, 6, 30);

  double _sisaSaldo = 0;
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;

  final List<Transaksi> _allTransactions = [
    Transaksi(
      tanggal: DateTime(2025, 6, 5),
      nominal: 1000000,
      isPemasukan: true,
    ),
    Transaksi(
      tanggal: DateTime(2025, 6, 10),
      nominal: 500000,
      isPemasukan: false,
    ),
    Transaksi(
      tanggal: DateTime(2025, 6, 15),
      nominal: 1000000,
      isPemasukan: true,
    ),
    Transaksi(
      tanggal: DateTime(2025, 7, 1),
      nominal: 200000,
      isPemasukan: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _hitungRekap();
  }

  void _hitungRekap() {
    final transaksiTerfilter =
        _allTransactions.where((tx) {
          return tx.tanggal.isAfter(
                _startDate.subtract(const Duration(days: 1)),
              ) &&
              tx.tanggal.isBefore(_endDate.add(const Duration(days: 1)));
        }).toList();

    double totalMasuk = 0;
    double totalKeluar = 0;

    for (var tx in transaksiTerfilter) {
      if (tx.isPemasukan) {
        totalMasuk += tx.nominal;
      } else {
        totalKeluar += tx.nominal;
      }
    }

    setState(() {
      _totalPemasukan = totalMasuk;
      _totalPengeluaran = totalKeluar;
      _sisaSaldo = totalMasuk - totalKeluar;
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      barrierColor: Colors.transparent,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _hitungRekap();
    }
  }

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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    double percentage =
        (_totalPemasukan != 0) ? (_sisaSaldo / _totalPemasukan) * 100 : 0;
    percentage = percentage.clamp(0, 100);

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
            ElevatedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Pilih Rentang Tanggal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
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
                    color: Colors.grey.withOpacity(0.1),
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
        items: const [
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
          if (index == widget.initialTabIndex) return;

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
                      isLoggedIn: widget.isLoggedIn,
                      initialTabIndex: 3,
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