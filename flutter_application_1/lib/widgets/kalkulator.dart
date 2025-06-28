import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalculator extends StatefulWidget {
  final Function(String) onSubmit;

  const CustomCalculator({super.key, required this.onSubmit});

  @override
  State<CustomCalculator> createState() => _CustomCalculatorState();
}

class _CustomCalculatorState extends State<CustomCalculator> {
  String _expression = '';
  String _result = '';

  final Color primaryColor = const Color(0xFFFF9800);

  void _appendValue(String value) {
    setState(() {
      _expression += value;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
      _result = '';
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  void _calculate() {
    try {
      final exp = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll(',', '.');
      final parsed = _evaluate(exp);
      setState(() {
        _result = parsed.toString();
      });
      widget.onSubmit(parsed.toString());
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  double _evaluate(String exp) {
    List<String> tokens = exp.split(RegExp(r'([+\-*/])'));
    List<String> operators = exp.replaceAll(RegExp(r'[^+\-*/]'), '').split('');

    double total = double.parse(tokens[0]);
    for (int i = 0; i < operators.length; i++) {
      double next = double.parse(tokens[i + 1]);
      switch (operators[i]) {
        case '+':
          total += next;
          break;
        case '-':
          total -= next;
          break;
        case '*':
          total *= next;
          break;
        case '/':
          total /= next;
          break;
      }
    }
    return total;
  }

  Widget _buildButton(String label, {Color? color, VoidCallback? onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: color ?? Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap ?? () => _appendValue(label),
            borderRadius: BorderRadius.circular(8),
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
        backgroundColor: primaryColor,
        title: const Text('Calculator'),
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
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: '',
                    decimalDigits: 0,
                  ).format(double.tryParse(_result) ?? 0),
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton('C', onTap: _clear),
                    _buildButton('→', onTap: _backspace),
                    _buildButton('%'),
                    _buildButton(
                      '÷',
                      color: primaryColor,
                      onTap: () => _appendValue('÷'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('×', color: primaryColor),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('-', color: primaryColor),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('+', color: primaryColor),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('0'),
                    _buildButton(',', onTap: () => _appendValue('.')),
                    _buildButton('±'), // belum digunakan
                    _buildButton('=', color: primaryColor, onTap: _calculate),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}