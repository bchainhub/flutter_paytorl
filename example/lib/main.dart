import 'package:flutter/material.dart';
import 'package:flutter_paytorl/flutter_paytorl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PaytoRL Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const PaytoDemo(),
      );
}

class PaytoDemo extends StatefulWidget {
  const PaytoDemo({super.key});

  @override
  State<PaytoDemo> createState() => _PaytoDemoState();
}

class _PaytoDemoState extends State<PaytoDemo> {
  late final TextEditingController _urlController;
  Payto? _payto;
  String _result = '';

  static const _defaultUrl =
      'payto://xcb/cb7147879011ea207df5b35a24ca6f0859dcfb145999?amount=ctn:10.01&fiat=eur';

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _defaultUrl);
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
      } on PayToException catch (e) {
        _result = 'Error: ${e.message}';
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
${_formatJson(_payto!.toJsonObject().toJson())}''';
    });
  }

  void _updateAmount() {
    if (_payto == null) return;

    setState(() {
      try {
        _payto!.value = 20.02;
        _urlController.text = _payto!.toString();
        _updateResult();
      } on PayToException catch (e) {
        _result = 'Error updating amount: ${e.message}';
      }
    });
  }

  void _updateColors() {
    if (_payto == null) return;

    setState(() {
      try {
        _payto!
          ..colorBackground = 'ff0000'
          ..colorForeground = '000000';
        _urlController.text = _payto!.toString();
        _updateResult();
      } on PayToException catch (e) {
        _result = 'Error updating colors: ${e.message}';
      }
    });
  }

  void _showExample(String url) {
    setState(() {
      try {
        _urlController.text = url;
        _parsePayto();
      } on PayToException catch (e) {
        _result = 'Error showing example: ${e.message}';
      }
    });
  }

  String _formatJson(Map<String, dynamic> json) {
    const indent = '  ';
    final buffer = StringBuffer()..writeln('{');

    json.forEach((key, value) {
      if (value != null) {
        buffer.writeln('$indent$key: $value,');
      }
    });

    return buffer..write('}').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PaytoRL Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                  onPressed: () => _showExample('payto://ach/123456789/1234567'),
                  child: const Text('ACH Example'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showExample('payto://upi/user@example.com'),
                  child: const Text('UPI Example'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final geoPayto = Payto('payto://void/geo')
                      ..location = '51.5074,0.1278';
                    _showExample(geoPayto.toString());
                  },
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
