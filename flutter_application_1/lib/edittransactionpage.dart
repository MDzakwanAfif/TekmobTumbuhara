// lib/add_edit_transaction_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'halamanutama.dart'; // Import HomePage untuk navigasi BottomNavBar

class AddEditTransactionPage extends StatefulWidget {
  final TransactionType transactionType;
  final Transaction? transaction; // Jika ada, berarti mode edit
  final DateTime initialDate; // Tanggal awal dari HomePage
  final String appBarTitle; // Properti untuk judul AppBar

  const AddEditTransactionPage({
    super.key,
    required this.transactionType,
    this.transaction,
    required this.initialDate,
    required this.appBarTitle,
  });

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController; // Untuk subtitle
  late TextEditingController _notesController; // Untuk notes tambahan
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TransactionType _currentTransactionType;

  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _currentTransactionType = widget.transactionType;

    _titleController = TextEditingController(
      text: widget.transaction?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.transaction?.subtitle ?? '',
    );
    _notesController = TextEditingController(
      text: widget.transaction?.notes ?? '',
    );

    _selectedDate = widget.transaction?.date ?? widget.initialDate;
    _selectedTime = widget.transaction?.time ?? TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Fungsi Pilih Tanggal ---
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
      });
    }
  }

  // --- Fungsi Pilih Waktu ---
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // --- Fungsi Simpan Transaksi ---
  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final String id = widget.transaction?.id ?? _uuid.v4();
      final String title = _titleController.text;
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final String category =
          _categoryController.text.isEmpty
              ? (_currentTransactionType == TransactionType.income
                  ? 'Umum'
                  : 'Lain-lain')
              : _categoryController.text;
      final String? notes =
          _notesController.text.isEmpty ? null : _notesController.text;

      final newTransaction = Transaction(
        id: id,
        title: title,
        subtitle: category,
        amount: amount,
        type: _currentTransactionType,
        date: _selectedDate,
        time: _selectedTime,
        notes: notes,
      );

      // Kembali ke halaman sebelumnya dengan data transaksi yang disimpan
      Navigator.of(context).pop(newTransaction);
    }
  }

  // --- Fungsi Hapus Transaksi ---
  Future<void> _deleteTransaction() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Transaksi?'),
          content: Text(
            'Anda yakin ingin menghapus transaksi "${widget.transaction?.title}" ini?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed:
                  () => Navigator.of(context).pop(false), // Tidak jadi hapus
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Ya, hapus
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmDelete == true) {
      // Kembali ke halaman sebelumnya dengan ID transaksi yang akan dihapus
      // atau sinyal khusus lainnya (misalnya String 'delete_transaction_ID')
      Navigator.of(
        context,
      ).pop(widget.transaction?.id); // Mengirimkan ID transaksi yang dihapus
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tombol delete hanya muncul jika ini mode edit (yaitu, widget.transaction tidak null)
    final bool isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.of(context).pop(), // Kembali tanpa perubahan
        ),
        actions: [
          // Tombol Delete (hanya tampil jika dalam mode edit)
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction, // Panggil fungsi delete
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Pengeluaran / Pemasukan
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
                            _currentTransactionType = TransactionType.expense;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _currentTransactionType ==
                                        TransactionType.expense
                                    ? const Color(0xFFFF9800)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                              color:
                                  _currentTransactionType ==
                                          TransactionType.expense
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
                            _currentTransactionType = TransactionType.income;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _currentTransactionType ==
                                        TransactionType.income
                                    ? const Color(0xFFFF9800)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                              color:
                                  _currentTransactionType ==
                                          TransactionType.income
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

              // Judul Transaksi (misalnya 'Beli Kopi', 'Gaji Bulanan')
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Transaksi',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                style: const TextStyle(fontFamily: 'Space Mono'),
              ),
              const SizedBox(height: 16),

              // Tanggal dan Waktu
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: DateFormat(
                              'EEE, dd MMM',
                              'id_ID',
                            ).format(_selectedDate),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Tanggal',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          style: const TextStyle(fontFamily: 'Space Mono'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedTime.format(context),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Waktu',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          style: const TextStyle(fontFamily: 'Space Mono'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Jumlah
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                  suffixIcon: Icon(Icons.calculate),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Jumlah harus angka positif';
                  }
                  return null;
                },
                style: const TextStyle(fontFamily: 'Space Mono'),
              ),
              const SizedBox(height: 16),

              // Kategori
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Keterangan (Notes)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.transaction != null
                        ? 'Simpan Perubahan'
                        : 'Tambah Transaksi',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
