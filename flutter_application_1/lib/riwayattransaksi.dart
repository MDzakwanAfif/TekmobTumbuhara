import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/backend/database_service.dart';
import 'package:flutter_application_1/theme_provider.dart';
import 'edittransactionpage.dart';

class HistoryPage extends StatefulWidget {
  // Constructor tidak lagi memerlukan allTransactions
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToEdit(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTransactionPage(
          transactionType: transaction.type,
          transaction: transaction,
          initialDate: transaction.date,
          appBarTitle: 'Edit Transaksi',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final formatter = NumberFormat.decimalPattern('id_ID');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themeProvider.mainColor, // Gunakan warna dari tema
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Riwayat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan judul atau kategori...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Transaction>>(
              stream: _dbService.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat data.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada riwayat transaksi.', style: TextStyle(color: Colors.grey)));
                }

                final allTransactions = snapshot.data!;
                final filteredTransactions = _searchQuery.isEmpty
                    ? allTransactions
                    : allTransactions.where((t) {
                        final query = _searchQuery.toLowerCase();
                        return t.title.toLowerCase().contains(query) || t.subtitle.toLowerCase().contains(query);
                      }).toList();

                if (filteredTransactions.isEmpty) {
                  return Center(child: Text('Tidak ada hasil untuk "$_searchQuery".', style: const TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    bool showDateHeader = index == 0 || !isSameDay(transaction.date, filteredTransactions[index - 1].date);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
                            child: _buildDateHeader(transaction.date),
                          ),
                        _buildTransactionItem(transaction, formatter),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Text(
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date),
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 16),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, NumberFormat formatter) {
    final amountColor = transaction.type == TransactionType.income ? Colors.green : Colors.red;
    final sign = transaction.type == TransactionType.income ? '+' : '-';

    return InkWell(
      onTap: () => _navigateToEdit(transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(transaction.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Text(
              '$sign${formatter.format(transaction.amount)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: amountColor),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}