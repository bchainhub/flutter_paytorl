import 'dart:convert';
import 'dart:io';
import '../lib/flutter_paytorl.dart';

void check(bool condition) {
  if (!condition) throw StateError('PayQR contract assertion failed');
}

void rejects(void Function() operation) {
  try {
    operation();
  } catch (_) {
    return;
  }
  throw StateError('Expected invalid PayQR input to be rejected');
}

Map<String, void Function()> payQrContract() {
  final fixture =
      jsonDecode(File('test/fixtures/payqr.json').readAsStringSync())
          as Map<String, dynamic>;
  final tests = <String, void Function()>{};
  for (final sample in fixture['valid'] as List) {
    tests['${sample['uri']}: roundtrips, properties, JSON, queries, setters'] =
        () {
          final p = Payto(sample['uri']);
          check(
            p.network == 'qr' &&
                p.country == sample['country'] &&
                p.scheme == sample['scheme'],
          );
          check(
            p.identifier == sample['identifier'] &&
                p.address == sample['identifier'],
          );
          check(
            p.identifierType == payQrSchemes[p.country]!.identifierTypes.first,
          );
          check(p.toString() == sample['uri'] && p.toJson() == sample['uri']);
          check(p.toJsonObject().country == sample['country']);
          check(
            PaytoJson.fromJson(p.toJsonObject().toJson()).scheme ==
                sample['scheme'],
          );
          p.country = (sample['country'] as String).toUpperCase();
          p.identifier = sample['identifier'];
          p.identifierType = p.identifierType;
          p.reference = 'invoice/1 & 2';
          p.message = 'ຂອບໃຈ + thanks';
          p.receiverName = 'José';
          final roundtrip = Payto(p.toString());
          check(
            roundtrip.reference == p.reference &&
                roundtrip.message == p.message &&
                roundtrip.receiverName == p.receiverName,
          );
          check(
            PayQrTarget.parse(
                  PayQrTarget.parse(p.toString()).toString(),
                ).toString() ==
                p.toString(),
          );
          rejects(() {
            p.identifier = 'https://bad.example';
          });
          check(p.identifier == sample['identifier']);
          rejects(() {
            p.identifier = null;
          });
        };
  }
  var index = 0;
  for (final uri in fixture['invalid'] as List) {
    tests['reject malformed URI ${index++}'] = () {
      rejects(() => PayQrTarget.parse(uri));
      rejects(() => Payto(uri));
    };
  }
  tests['Unicode identifiers, percent encoding and exact query preservation'] =
      () {
        final p = PayQrTarget(
          country: 'la',
          identifier: 'ລາວ_É',
          parameters: {'reference': '#1', 'message': 'A&B /?'},
        );
        check(PayQrTarget.parse(p.toString()).identifier == 'ລາວ_É');
        check(p.toString().contains('message=A%26B%20%2F%3F&reference=%231'));
      };
  tests['Amounts and supported currencies'] = () {
    for (final values in [
      ['kh', 'name@bank', 'USD'],
      ['id', 'ABC', 'IDR'],
      ['my', 'ABC', 'MYR'],
      ['mm', '123456789012345', 'MMK'],
      ['sg', '%2B6581234567', 'SGD'],
      ['th', '0066812345678', 'THB'],
    ]) {
      final p = Payto(
        'payto://qr/${values[0]}/${values[1]}?amount=${values[2]}:12.34',
      );
      check(
        p.amount == '${values[2]}:12.34' &&
            p.currency.first == values[2] &&
            p.value == 12.34,
      );
    }
  };
  tests['Non-PayQR networks retain their existing URI behavior'] = () {
    for (final uri in [
      'payto://ach/110000000/000123456789',
      'payto://upi/name@bank',
      'payto://pix/name@example.com',
      'payto://iban/DE89370400440532013000',
      'payto://bic/DEUTDEFF/ABC',
      'payto://intra/BANK/001',
      'payto://void/geo?loc=1,2',
    ]) {
      final p = Payto(uri);
      check(p.toString() == uri && p.country == null && p.scheme == null);
    }
  };
  tests['Validated parameter setters are atomic'] = () {
    final p = Payto('payto://qr/my/MERCHANT01?amount=MYR:1');
    rejects(() {
      p.amount = 'MYR:-1';
    });
    check(p.amount == 'MYR:1');
    p.amount = 'MYR:2.50';
    check(Payto(p.toString()).amount == 'MYR:2.50');
    rejects(() {
      p.message = 'bad\nmessage';
    });
    check(p.message == null);
    p.address = 'MERCHANT02';
    check(p.identifier == 'MERCHANT02');
  };
  tests['New national profile query fields preserve URI parity'] = () {
    for (final uri in [
      'payto://qr/kh/name%40bank?merchant-city=Phnom%20Penh&qr-currency=USD&receiver-name=Test',
      'payto://qr/sg/%2B6581234567?receiver-name=Test',
      'payto://qr/vn/0011009950446?acquirer-id=970468',
      'payto://qr/mm/123456789012345?local-name=%E1%80%86%E1%80%AD%E1%80%AF%E1%80%84%E1%80%BA&scheme-id=MM.COM.MMQR',
    ]) {
      check(Payto(uri).toString() == uri);
    }
    for (final uri in [
      'payto://qr/vn/123?acquirer-id=12',
      'payto://qr/vn/123?amount=VND:1.50',
      'payto://qr/kh/name%40bank?qr-currency=MYR',
      'payto://qr/kh/name%40bank?qr-currency=USD&amount=KHR:1',
      'payto://qr/mm/123456789012345?scheme-id=https%3A%2F%2Fexample.com',
      'payto://qr/mm/123456789012345?local-name=English',
    ]) {
      rejects(() => Payto(uri));
    }
  };
  tests['LaoQR routing fields and LAK validation'] = () {
    final uri =
        'payto://qr/la/0005555555?application-id=A000000677012111&acquirer-id=621354&receiver-name=Test';
    final target = PayQrTarget.parse(uri);
    check(target.identifier == '0005555555');
    check(
      PayQrTarget.parse(target.toString()).parameters['application-id'] ==
          'A000000677012111',
    );
    check(
      PayQrTarget.parse('$uri&amount=LAK:1').parameters['amount'] == 'LAK:1',
    );
    rejects(() => PayQrTarget.parse(uri.replaceFirst('621354', '123')));
    rejects(
      () => PayQrTarget.parse(uri.replaceFirst('A000000677012111', 'bad')),
    );
  };
  tests['Thai input normalizes into canonical URI'] = () {
    for (final identifier in ['0812345678', '+66812345678', '0066812345678']) {
      check(
        PayQrTarget(country: 'th', identifier: identifier).identifier ==
            '0066812345678',
      );
    }
  };
  tests['QR Ph properties, atomic setters and input limit'] = () {
    final p = Payto(
      'payto://qr/ph/Demo?amount=PHP:15.25&payment-mode=p2p&qr-type=dynamic',
    );
    check(p.paymentMode == 'p2p' && p.qrType == 'dynamic');
    check(p.toJsonObject().paymentMode == 'p2p');
    p.paymentMode = 'p2m';
    check(PaytoJson.fromJson(p.toJsonObject().toJson()).paymentMode == 'p2m');
    final before = p.toString();
    rejects(() {
      p.paymentMode = 'unknown';
    });
    check(p.toString() == before);
    p.qrType = null;
    check(p.qrType == null);
    rejects(() => PayQrTarget.parse('payto://qr/ph/a?' + 'x' * 8192));
  };
  return tests;
}

// Also runnable directly using the bundled Dart VM when Flutter's launcher is unavailable.
void main() {
  final tests = payQrContract();
  for (final test in tests.values) {
    test();
  }
  stdout.writeln('PayQR: ${tests.length} contract tests passed');
}
