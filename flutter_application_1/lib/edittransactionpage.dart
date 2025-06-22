// add_edit_transaction_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Import Uuid
import 'halamanutama.dart'; // Import Transaction dan TransactionType

class AddEditTransactionPage extends StatefulWidget {
  final TransactionType transactionType;
  final Transaction? transaction; // Jika ada, berarti mode edit
  final DateTime initialDate; // Tanggal awal dari HomePage

  const AddEditTransactionPage({
    super.key,
    required this.transactionType,
    this.transaction,
    required this.initialDate, // Tambahkan ini
  });

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController
  _categoryController; // Ganti subtitle jadi category
  late TextEditingController _notesController; // Untuk keterangan
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TransactionType _currentTransactionType; // Untuk tombol toggle

  final Uuid _uuid = const Uuid(); // Inisialisasi Uuid

  @override
  void initState() {
    super.initState();
    _currentTransactionType = widget.transactionType; // Set tipe awal

    _titleController = TextEditingController(
      text: widget.transaction?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.transaction?.subtitle ?? '',
    ); // Subtitle -> Kategori
    _notesController = TextEditingController(
      text: '',
    ); // Keterangan, tidak ada di model Transaction saat ini

    _selectedDate =
        widget.transaction?.date ?? widget.initialDate; // Gunakan initialDate
    _selectedTime =
        widget.transaction?.time ??
        TimeOfDay.now(); // Gunakan waktu transaksi atau waktu saat ini
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
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
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
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
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
      final String id =
          widget.transaction?.id ?? _uuid.v4(); // Gunakan Uuid untuk ID
      final String title = _titleController.text;
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final String category =
          _categoryController.text.isEmpty
              ? (_currentTransactionType == TransactionType.income
                  ? 'Umum'
                  : 'Lain-lain')
              : _categoryController.text;

      final newTransaction = Transaction(
        id: id,
        title: title,
        subtitle: category, // Gunakan kategori sebagai subtitle
        amount: amount,
        type: _currentTransactionType,
        date: _selectedDate,
        time: _selectedTime,
      );

      Navigator.of(context).pop(newTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: const Color(0xFFFF9800), // Warna orange sesuai desain
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Ikon panah ke kiri
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save), // Ikon simpan
            onPressed: _saveTransaction,
          ),
          IconButton(
            icon: const Icon(Icons.restore), // Ikon pulihkan (contoh)
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Pulihkan belum diimplementasi'),
                ),
              );
            },
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

              // Tanggal dan Waktu
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        // Mencegah keyboard muncul saat klik
                        child: TextFormField(
                          readOnly: true, // Hanya bisa dipilih lewat kalender
                          controller: TextEditingController(
                            text: DateFormat(
                              'EEE, dd MMM yyyy',
                              'id_ID',
                            ).format(_selectedDate),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Tanggal',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        // Mencegah keyboard muncul saat klik
                        child: TextFormField(
                          readOnly: true, // Hanya bisa dipilih lewat jam
                          controller: TextEditingController(
                            text: _selectedTime.format(context),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Waktu',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
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
                  suffixIcon: Icon(Icons.calculate), // Ikon kalkulator
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

              // Keterangan
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (tidak wajib diisi)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Boleh banyak baris
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800), // Warna orange
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
        currentIndex: 0, // Default ke 'Transaksi'
        selectedItemColor: const Color(0xFFFF9800),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Ketika BottomNav ditekan di halaman ini, navigasi ke HomePage dengan tab yang sesuai
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => HomePage(
                    initialTabIndex: index,
                  ), // TODO: HomePage perlu menerima initialTabIndex
            ),
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}
