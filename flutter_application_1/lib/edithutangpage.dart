import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/models/debt_transaction_model.dart';
import 'package:flutter_application_1/backend/database_service.dart';
import 'package:flutter_application_1/theme_provider.dart';
import '/widgets/kalkulator.dart';

class AddEditHutangPage extends StatefulWidget {
  final DebtTransactionType transactionType;
  final DebtTransaction? transaction;
  final DateTime initialDate;

  const AddEditHutangPage({
    super.key,
    required this.transactionType,
    this.transaction,
    required this.initialDate,
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
  late bool _isPaid;
  late DebtTransactionType _currentType;

  final Uuid _uuid = const Uuid();
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction?.amount.toString() ?? '');
    _nameController = TextEditingController(text: widget.transaction?.personName ?? '');
    _notesController = TextEditingController(text: widget.transaction?.notes ?? '');
    _selectedDate = widget.transaction?.date ?? widget.initialDate;
    _selectedTime = widget.transaction?.time ?? TimeOfDay.now();
    _isPaid = widget.transaction?.isPaid ?? false;
    _currentType = widget.transaction?.type ?? widget.transactionType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: themeProvider.mainColor,
            colorScheme: ColorScheme.light(primary: themeProvider.mainColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: themeProvider.mainColor,
            colorScheme: ColorScheme.light(primary: themeProvider.mainColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // --- BAGIAN YANG DIPERBAIKI ---
  void _showCalculator() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCalculator(
          themeColor: themeProvider.mainColor, // <-- Kirim warna tema
          onSubmit: (value) {
            setState(() {
              _amountController.text = value;
            });
          },
        ),
      ),
    );
  }

  void _saveDebtTransaction() {
    if (_formKey.currentState!.validate()) {
      final newDebtTransaction = DebtTransaction(
        id: widget.transaction?.id ?? _uuid.v4(),
        type: _currentType,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        personName: _nameController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        date: _selectedDate,
        time: _selectedTime,
        isPaid: _isPaid,
      );

      _dbService.saveDebtTransaction(newDebtTransaction).then((_) => Navigator.of(context).pop());
    }
  }

  Future<void> _deleteDebtTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi Hutang?'),
        content: const Text('Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      _dbService.deleteDebtTransaction(widget.transaction!.id).then((_) => Navigator.of(context).pop());
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isEditing = widget.transaction != null;
    String appBarTitle = isEditing ? 'Edit Hutang' : 'Tambah Hutang';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: themeProvider.mainColor,
        foregroundColor: Colors.white,
        actions: [if (isEditing) IconButton(icon: const Icon(Icons.delete), onPressed: _deleteDebtTransaction)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _currentType = DebtTransactionType.giving),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _currentType == DebtTransactionType.giving ? themeProvider.mainColor : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('Memberi Utang', style: TextStyle(color: _currentType == DebtTransactionType.giving ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _currentType = DebtTransactionType.receiving),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _currentType == DebtTransactionType.receiving ? themeProvider.mainColor : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('Menerima Utang', style: TextStyle(color: _currentType == DebtTransactionType.receiving ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
                  ),
                )),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(flex: 3, child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: DateFormat('EEE, dd MMM indeterminate', 'id_ID').format(_selectedDate)),
                    decoration: const InputDecoration(labelText: 'Tanggal', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                  )),
                )),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: _selectedTime.format(context)),
                    decoration: const InputDecoration(labelText: 'Waktu', border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time)),
                  )),
                )),
              ]),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Jumlah', border: const OutlineInputBorder(), prefixText: 'Rp ', suffixIcon: IconButton(icon: const Icon(Icons.calculate), onPressed: _showCalculator)),
                validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Jumlah harus angka positif' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: _currentType == DebtTransactionType.giving ? 'Nama Penerima Utang' : 'Nama Pemberi Utang', border: const OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Keterangan (opsional)', border: OutlineInputBorder())),
              SwitchListTile(
                title: const Text('Tandai Sudah Lunas'),
                value: _isPaid,
                onChanged: (value) => setState(() => _isPaid = value),
                activeColor: themeProvider.mainColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveDebtTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Hutang', style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}