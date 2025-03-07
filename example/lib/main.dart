import 'package:flutter/material.dart';
import 'package:flutter_paytorl/flutter_paytorl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaytoRL Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PaytoDemo(),
    );
  }
}

class PaytoDemo extends StatefulWidget {
  const PaytoDemo({super.key});

  @override
  State<PaytoDemo> createState() => _PaytoDemoState();
}

class _PaytoDemoState extends State<PaytoDemo> {
  late TextEditingController _urlController;
  Payto? _payto;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text:
          'payto://xcb/cb7147879011ea207df5b35a24ca6f0859dcfb145999?amount=ctn:10.01&fiat=eur',
    );
    _parsePayto();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _parsePayto() {
    setState(() {
      try {
        _payto = Payto(_urlController.text);
        _updateResult();
      } catch (e) {
        _result = 'Error: ${e.toString()}';
      }
    });
  }

  void _updateResult() {
    if (_payto == null) return;

    setState(() {
      _result = '''
Payment Details:
---------------
Address: ${_payto!.address}
Amount: ${_payto!.amount}
Value: ${_payto!.value}
Network: ${_payto!.network}
Currency: ${_payto!.currency}
Fiat: ${_payto!.fiat}

JSON Output:
-----------
${_formatJson(_payto!.toJsonObject().toJson())}
''';
    });
  }

  void _updateAmount() {
    if (_payto == null) return;

    setState(() {
      try {
        _payto!.value = 20.02;
        _urlController.text = _payto!.toString();
        _updateResult();
      } catch (e) {
        _result = 'Error updating amount: ${e.toString()}';
      }
    });
  }

  void _updateColors() {
    if (_payto == null) return;

    setState(() {
      try {
        _payto!.colorBackground = 'ff0000'; // Red background
        _payto!.colorForeground = '000000'; // Black foreground
        _urlController.text = _payto!.toString();
        _updateResult();
      } catch (e) {
        _result = 'Error updating colors: ${e.toString()}';
      }
    });
  }

  void _showAchExample() {
    setState(() {
      try {
        _urlController.text = 'payto://ach/123456789/1234567';
        _parsePayto();
      } catch (e) {
        _result = 'Error showing ACH example: ${e.toString()}';
      }
    });
  }

  void _showUpiExample() {
    setState(() {
      try {
        _urlController.text = 'payto://upi/user@example.com';
        _parsePayto();
      } catch (e) {
        _result = 'Error showing UPI example: ${e.toString()}';
      }
    });
  }

  void _showGeoExample() {
    setState(() {
      try {
        final geoPayto = Payto('payto://void/geo');
        geoPayto.location = '51.5074,0.1278';
        _urlController.text = geoPayto.toString();
        _parsePayto();
      } catch (e) {
        _result = 'Error showing geo example: ${e.toString()}';
      }
    });
  }

  String _formatJson(Map<String, dynamic> json) {
    const indent = '  ';
    final buffer = StringBuffer();
    buffer.writeln('{');

    json.forEach((key, value) {
      if (value != null) {
        buffer.writeln('$indent$key: $value,');
      }
    });

    buffer.write('}');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PaytoRL Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Payto URL',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _parsePayto,
                  child: const Text('Parse URL'),
                ),
                ElevatedButton(
                  onPressed: _updateAmount,
                  child: const Text('Update Amount'),
                ),
                ElevatedButton(
                  onPressed: _updateColors,
                  child: const Text('Update Colors'),
                ),
                ElevatedButton(
                  onPressed: _showAchExample,
                  child: const Text('ACH Example'),
                ),
                ElevatedButton(
                  onPressed: _showUpiExample,
                  child: const Text('UPI Example'),
                ),
                ElevatedButton(
                  onPressed: _showGeoExample,
                  child: const Text('Geo Example'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _result,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
