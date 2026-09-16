import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_paytorl/flutter_paytorl.dart';

void main() {
  final fixture =
      jsonDecode(File('test/fixtures/qris-emv.json').readAsStringSync())
          as Map<String, dynamic>;
  test(
    'official participant envelope inspection does not claim QRIS validity',
    () {
      final result = inspectEmvMpm(fixture['payload'] as String).toJson();
      expect(result, {
        'fields': fixture['fields'],
        'templates': fixture['templates'],
      });
      expect(result.containsKey('scheme'), false);
      expect(result.containsKey('identifier'), false);
    },
  );
  for (var i = 0; i < (fixture['invalid'] as List).length; i++) {
    test(
      'reject malformed envelope $i',
      () => expect(
        () => inspectEmvMpm(fixture['invalid'][i] as String),
        throwsFormatException,
      ),
    );
  }
  test('bounded ASCII subset', () {
    for (final value in [
      '',
      'x' * 4097,
      (fixture['payload'] as String).replaceFirst('Test', 'Tést'),
      'payto://qr/id/Demo',
    ]) {
      expect(() => inspectEmvMpm(value), throwsFormatException);
    }
  });
}
