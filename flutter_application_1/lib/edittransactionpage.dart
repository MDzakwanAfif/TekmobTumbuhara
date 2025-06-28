import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'halamanutama.dart';
import '/widgets/kalkulator.dart';

class AddEditTransactionPage extends StatefulWidget {
  final TransactionType transactionType;
  final Transaction? transaction;
  final DateTime initialDate;
  final String appBarTitle;

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
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

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

      Navigator.of(context).pop(newTransaction);
    }
  }

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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmDelete == true) {
      Navigator.of(context).pop(widget.transaction?.id);
    }
  }

  void _openCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CustomCalculator(
              onSubmit: (value) {
                setState(() {
                  _amountController.text = value;
                });
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => setState(() {
                            _currentTransactionType = TransactionType.expense;
                          }),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _currentTransactionType == TransactionType.expense
                                  ? const Color(0xFFFF9800)
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => setState(() {
                            _currentTransactionType = TransactionType.income;
                          }),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _currentTransactionType == TransactionType.income
                                  ? const Color(0xFFFF9800)
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
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
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Transaksi',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Judul tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),

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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: const OutlineInputBorder(),
                  prefixText: 'Rp ',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calculate),
                    onPressed: _openCalculator,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Jumlah tidak boleh kosong';
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0)
                    return 'Jumlah harus angka positif';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Kategori tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

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