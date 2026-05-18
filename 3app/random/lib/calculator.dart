import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _num1Controller = TextEditingController();
  final _num2Controller = TextEditingController();
  String _selectedOperator = '+';
  String _result = '';

  final List<String> _operators = ['+', '-', '*', '/'];

  void _calculate() {
    final double? num1 = double.tryParse(_num1Controller.text);
    final double? num2 = double.tryParse(_num2Controller.text);

    if (num1 == null || num2 == null) {
      setState(() => _result = 'Vui lòng nhập số hợp lệ');
      return;
    }

    if (_selectedOperator == '/' && num2 == 0) {
      setState(() => _result = 'Không thể chia cho 0');
      return;
    }

    double answer;
    switch (_selectedOperator) {
      case '+':
        answer = num1 + num2;
      case '-':
        answer = num1 - num2;
      case '*':
        answer = num1 * num2;
      case '/':
        answer = num1 / num2;
      default:
        return;
    }

    setState(() {
      // Nếu kết quả là số nguyên thì hiện không có .0
      _result = answer % 1 == 0 ? answer.toInt().toString() : answer.toString();
    });
  }

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ô nhập số 1
            TextField(
              controller: _num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số 1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Chọn phép tính
            DropdownButtonFormField<String>(
              value: _selectedOperator,
              decoration: const InputDecoration(
                labelText: 'Phép tính',
                border: OutlineInputBorder(),
              ),
              items: _operators.map((op) {
                return DropdownMenuItem(value: op, child: Text(op));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedOperator = value!);
              },
            ),
            const SizedBox(height: 16),

            // Ô nhập số 2
            TextField(
              controller: _num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số 2',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Nút tính
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                child: const Text('Tính'),
              ),
            ),
            const SizedBox(height: 32),

            // Hiển thị kết quả
            Text(
              _result.isEmpty ? '' : 'Kết quả: $_result',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}