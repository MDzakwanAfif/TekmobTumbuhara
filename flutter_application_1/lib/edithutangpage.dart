// lib/add_edit_hutang_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/halamanutama.dart';
import 'package:flutter_application_1/rekappage.dart';
import 'package:flutter_application_1/hutangpage.dart';
import 'package:flutter_application_1/settingpage.dart';

// Enum dan Model DebtTransaction (pastikan ini ada di satu lokasi yang diimpor)
enum DebtTransactionType { giving, receiving }

class DebtTransaction {
  final String id;
  final DebtTransactionType type;
  final double amount;
  final String personName;
  final String? notes;
  final DateTime date;
  final TimeOfDay time;

  DebtTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.personName,
    this.notes,
    required this.date,
    required this.time,
  });

  DateTime get fullDateTime =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  DebtTransaction copyWith({
    String? id,
    DebtTransactionType? type,
    double? amount,
    String? personName,
    String? notes,
    DateTime? date,
    TimeOfDay? time,
  }) {
    return DebtTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      personName: personName ?? this.personName,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}

class AddEditHutangPage extends StatefulWidget {
  final DebtTransactionType transactionType;
  final DebtTransaction? transaction;
  final DateTime initialDate;
  final int initialTabIndex;
  final bool isLoggedIn; // ✅ Tambahkan ini

  const AddEditHutangPage({
    super.key,
    required this.transactionType,
    this.transaction,
    required this.initialDate,
    this.initialTabIndex = 2,
    required this.isLoggedIn, // ✅ Tambahkan ini
  });

  @override
  State<AddEditHutangPage> createState() => _AddEditHutangPageState();
}

class _AddEditHutangPageState extends State<AddEditHutangPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _nameController = TextEditingController(
      text: widget.transaction?.personName ?? '',
    );
    _notesController = TextEditingController(
      text: widget.transaction?.notes ?? '',
    );

    _selectedDate = widget.transaction?.date ?? widget.initialDate;
    _selectedTime = widget.transaction?.time ?? TimeOfDay.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
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

  void _saveDebtTransaction() {
    if (_formKey.currentState!.validate()) {
      final String id = widget.transaction?.id ?? _uuid.v4();
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final String personName = _nameController.text;
      final String? notes =
          _notesController.text.isEmpty ? null : _notesController.text;

      final newDebtTransaction = DebtTransaction(
        id: id,
        type: widget.transactionType,
        amount: amount,
        personName: personName,
        notes: notes,
        date: _selectedDate,
        time: _selectedTime,
      );

      Navigator.of(context).pop(newDebtTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle =
        widget.transactionType == DebtTransactionType.giving
            ? 'Memberi'
            : 'Menerima';

    if (widget.transaction != null) {
      appBarTitle = 'Edit $appBarTitle';
    }

    final String formattedDate = DateFormat(
      'EEE, dd MMM yyyy',
      'id_ID',
    ).format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(appBarTitle),
        centerTitle: true,
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
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: formattedDate,
                          ),
                          decoration: const InputDecoration(
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
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                  suffixIcon: Icon(Icons.calculate),
                ),
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (tidak wajib diisi)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saveDebtTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
