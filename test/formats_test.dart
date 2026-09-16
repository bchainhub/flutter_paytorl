import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_paytorl/flutter_paytorl.dart';

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/payqr.json').readAsStringSync(),
  );
  for (final sample in fixture['valid']) {
    test('formats for ${sample['uri']}', () {
      final p = Payto(sample['uri']);
      final formats = ['bn', 'ph', 'id'].contains(sample['country'])
          ? null
          : ['payto', sample['scheme']];
      expect(p.formats, formats);
      final json = p.toJsonObject().toJson();
      expect(json['formats'], formats);
      expect(json.containsKey('formats'), formats != null);
      expect(PaytoJson.fromJson(json).toJson(), json);
      expect(p.toString(), sample['uri']);
      expect(p.toJson(), sample['uri']);
    });
  }
  test('IBAN extensions roundtrip as PayTo data only', () {
    final p = Payto('payto://iban/FR1420041010050500013M02606');
    expect(p.formats, ['payto', 'epc']);
    expect(() => p.formats!.add('khqr'), throwsUnsupportedError);
    p.reference = 'RF18539007547034';
    p.purpose = 'GDDS';
    p.information = 'Invoice / café & 1';
    final parsed = Payto(p.toString());
    expect(parsed.reference, p.reference);
    expect(parsed.purpose, 'GDDS');
    expect(parsed.information, p.information);
    final json = parsed.toJsonObject().toJson();
    expect(json['formats'], ['payto', 'epc']);
    expect(json['purpose'], 'GDDS');
    expect(json['information'], p.information);
    expect(PaytoJson.fromJson(json).toJson(), json);
    expect(p.toString(), startsWith('payto://iban/'));
    expect(
      Uri.parse(p.toString()).queryParameters.containsKey('formats'),
      false,
    );
    parsed.purpose = null;
    parsed.information = null;
    expect(
      Uri.parse(parsed.toString()).queryParameters.containsKey('purpose'),
      false,
    );
    expect(parsed.toJsonObject().toJson().containsKey('information'), false);
  });
  test('PayTo-only methods omit formats', () {
    final p = Payto('payto://xcb/CB123');
    expect(p.formats, isNull);
    expect(p.toJsonObject().toJson().containsKey('formats'), false);
    expect(
      PaytoJson.fromJson({
        'formats': ['payto'],
      }).toJson().containsKey('formats'),
      false,
    );
  });
}
