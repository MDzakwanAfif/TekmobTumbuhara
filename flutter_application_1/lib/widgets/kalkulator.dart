import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalculator extends StatefulWidget {
  final Function(String) onSubmit;
  final Color themeColor; // Terima warna tema dari luar

  const CustomCalculator({
    super.key,
    required this.onSubmit,
    required this.themeColor, // Wajibkan untuk diisi
  });

  @override
  State<CustomCalculator> createState() => _CustomCalculatorState();
}

class _CustomCalculatorState extends State<CustomCalculator> {
  String _expression = '';
  String _result = '';

  void _appendValue(String value) => setState(() => _expression += value);

  void _clear() => setState(() {
        _expression = '';
        _result = '';
      });

  void _backspace() {
    if (_expression.isNotEmpty) {
      setState(() => _expression = _expression.substring(0, _expression.length - 1));
    }
  }

  void _calculate() {
    try {
      final exp = _expression.replaceAll('×', '*').replaceAll('÷', '/').replaceAll(',', '.');
      // Simple evaluator logic
      List<String> tokens = exp.split(RegExp(r'([+\-*/])'));
      List<String> operators = exp.replaceAll(RegExp(r'[^+\-*/]'), '').split('');
      
      if (tokens.last.isEmpty) { // Handle trailing operator
        tokens.removeLast();
        operators.removeLast();
      }

      double total = double.parse(tokens[0]);
      for (int i = 0; i < operators.length; i++) {
        if (tokens[i + 1].isEmpty) continue; // Skip if operand is empty
        double next = double.parse(tokens[i + 1]);
        if (operators[i] == '+') total += next;
        if (operators[i] == '-') total -= next;
        if (operators[i] == '*') total *= next;
        if (operators[i] == '/') total /= next;
      }

      setState(() => _result = total.toString());
      widget.onSubmit(total.toString());
      Navigator.pop(context);
    } catch (e) {
      setState(() => _result = 'Error');
    }
  }

  Widget _buildButton(String label, {Color? color, VoidCallback? onTap, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: color ?? Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap ?? () => _appendValue(label),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.themeColor, // Gunakan warna dari widget
        title: const Text('Kalkulator'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _calculate),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _expression.replaceAll('.', ','),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0)
                      .format(double.tryParse(_result) ?? 0),
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Row(children: [
                    _buildButton('C', color: Colors.grey[400], onTap: _clear),
                    _buildButton('←', color: Colors.grey[400], onTap: _backspace),
                    _buildButton('%', color: Colors.grey[400], onTap: () => _appendValue('%')),
                    _buildButton('÷', color: widget.themeColor.withOpacity(0.8), onTap: () => _appendValue('÷')),
                  ]),
                  Row(children: [
                    _buildButton('7'), _buildButton('8'), _buildButton('9'),
                    _buildButton('×', color: widget.themeColor.withOpacity(0.8), onTap: () => _appendValue('×')),
                  ]),
                  Row(children: [
                    _buildButton('4'), _buildButton('5'), _buildButton('6'),
                    _buildButton('-', color: widget.themeColor.withOpacity(0.8), onTap: () => _appendValue('-')),
                  ]),
                  Row(children: [
                    _buildButton('1'), _buildButton('2'), _buildButton('3'),
                    _buildButton('+', color: widget.themeColor.withOpacity(0.8), onTap: () => _appendValue('+')),
                  ]),
                  Row(children: [
                    _buildButton('0', flex: 2),
                    _buildButton(',', onTap: () => _appendValue('.')),
                    _buildButton('=', color: widget.themeColor, onTap: _calculate),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}