// lib/riwayattransaksi.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'edittransactionpage.dart';

class HistoryPage extends StatefulWidget {
  final List<Transaction>
  allTransactions; // Menerima semua transaksi dari HomePage

  const HistoryPage({super.key, required this.allTransactions});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<Transaction>
  _filteredTransactions; // Daftar transaksi yang akan ditampilkan
  String _searchQuery = ''; // Query pencarian

  @override
  void initState() {
    super.initState();
    _filteredTransactions = List.from(widget.allTransactions);
    _sortTransactions();
  }

  void _sortTransactions() {
    _filteredTransactions.sort(
      (a, b) => b.fullDateTime.compareTo(a.fullDateTime),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredTransactions = List.from(widget.allTransactions);
    } else {
      final queryLower = _searchQuery.toLowerCase();
      _filteredTransactions =
          widget.allTransactions.where((transaction) {
            return transaction.title.toLowerCase().contains(queryLower) ||
                transaction.subtitle.toLowerCase().contains(queryLower) ||
                DateFormat.yMMMd(
                  'id_ID',
                ).format(transaction.date).toLowerCase().contains(queryLower);
          }).toList();
    }
    _sortTransactions(); // Urutkan lagi setelah filtering
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('id_ID');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Riwayat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Column(
        children: [
          // Bagian Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Pencarian',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          // Daftar Transaksi
          Expanded(
            child:
                _filteredTransactions.isEmpty
                    ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Tidak ada riwayat transaksi.'
                            : 'Tidak ada hasil untuk "$_searchQuery".',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
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

                        bool showDateHeader = false;
                        if (index == 0) {
                          showDateHeader = true;
                        } else {
                          final previousTransaction =
                              _filteredTransactions[index - 1];
                          if (!isSameDay(
                            transaction.date,
                            previousTransaction.date,
                          )) {
                            showDateHeader = true;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 15.0,
                                  bottom: 8.0,
                                ),
                                child: _buildDateHeader(
                                  transaction.date,
                                  context, // Meneruskan context untuk MediaQuery
                                ),
                              ),
                            _buildTransactionItem(
                              transaction: transaction,
                              amountColor: amountColor,
                              sign: sign,
                              formatter: formatter,
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // === WIDGET: _buildDateHeader (Disesuaikan dengan responsif ukuran) ===
  Widget _buildDateHeader(DateTime date, BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Base font sizes for a "standard" device (e.g., iPhone SE-ish width ~320-375)
    // Then scale them based on the current device width relative to a reference width.
    const double referenceWidth =
        375.0; // iPhone SE / iPhone 8 width as a reference

    // Calculate scaling factors for font sizes and padding
    final double scaleFactor = size.width / referenceWidth;

    // Ukuran font yang responsif berdasarkan skala
    final double dayOfMonthFontSize = 12 * scaleFactor;
    final double monthYearFontSize = 10 * scaleFactor;
    final double dayOfWeekFontSize =
        12 *
        scaleFactor; // Menggunakan 12 untuk 'size 6' yang lebih masuk akal dan responsif

    // Padding yang responsif
    final double dayOfWeekHorizontalPadding = 10.0 * scaleFactor;
    final double dayOfWeekVerticalPadding = 2.0 * scaleFactor;

    // Pastikan tidak terlalu kecil atau terlalu besar
    const double minDayOfMonthFontSize = 12.0;
    const double maxDayOfMonthFontSize = 24.0;
    const double minMonthYearFontSize = 8.0;
    const double maxMonthYearFontSize = 16.0;
    const double minDayOfWeekFontSize = 10.0;
    const double maxDayOfWeekFontSize = 18.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Angka tanggal (21)
        Text(
          DateFormat('dd').format(date),
          style: TextStyle(
            fontSize: dayOfMonthFontSize.clamp(
              minDayOfMonthFontSize,
              maxDayOfMonthFontSize,
            ),
            fontWeight: FontWeight.w400, // Regular
            color: Colors.black,
          ),
        ),
        SizedBox(width: 4 * scaleFactor), // Jarak antara angka dan kotak hari
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bulan dan Tahun (06 2025)
            Text(
              DateFormat(
                'MM yyyy',
                'id_ID',
              ).format(date), // Format yyyy agar tahun selalu ada
              style: TextStyle(
                fontSize: monthYearFontSize.clamp(
                  minMonthYearFontSize,
                  maxMonthYearFontSize,
                ),
                fontWeight: FontWeight.w400, // Regular
                color: Colors.black,
              ),
            ),
            // Kotak Hari (Sabtu)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: dayOfWeekHorizontalPadding,
                vertical: dayOfWeekVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(
                  4 * scaleFactor,
                ), // Radius juga responsif
              ),
              child: Text(
                DateFormat('EEEE', 'id_ID').format(date),
                style: TextStyle(
                  fontSize: dayOfWeekFontSize.clamp(
                    minDayOfWeekFontSize,
                    maxDayOfWeekFontSize,
                  ),
                  fontWeight: FontWeight.w500, // Medium
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  // === END WIDGET ===

  // Widget pembantu untuk menampilkan setiap item transaksi (tidak berubah)
  Widget _buildTransactionItem({
    required Transaction transaction,
    required Color amountColor,
    required String sign,
    required NumberFormat formatter,
  }) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => AddEditTransactionPage(
                  transactionType: transaction.type,
                  transaction: transaction,
                  initialDate: transaction.date,
                  appBarTitle: 'Edit Transaksi',
                ),
          ),
        );

        if (result != null && result is Transaction) {
          setState(() {
            final index = widget.allTransactions.indexWhere(
              (t) => t.id == result.id,
            );
            if (index != -1) {
              widget.allTransactions[index] = result;
              _applyFilter();
            }
          });
        }
      },
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
                    transaction.subtitle,
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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}