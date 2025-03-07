import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_paytorl/flutter_paytorl.dart';

void main() {
  group('Payto URL Parsing', () {
    test('should parse basic payment URL', () {
      final payto = Payto(
          'payto://xcb/cb7147879011ea207df5b35a24ca6f0859dcfb145999?amount=ctn:10.01&fiat=eur');

      expect(payto.address, 'cb7147879011ea207df5b35a24ca6f0859dcfb145999');
      expect(payto.amount, 'ctn:10.01');
      expect(payto.value, 10.01);
      expect(payto.network, 'xcb');
      expect(payto.currency, ['ctn', 'eur']);
      expect(payto.fiat, 'eur');
    });

    test('should throw on invalid protocol', () {
      expect(
        () => Payto('http://example.com'),
        throwsA(isA<PaytoException>()),
      );
    });
  });

  group('Payment Properties', () {
    late Payto payto;

    setUp(() {
      payto = Payto('payto://xcb/address');
    });

    test('should update payment amount', () {
      payto.value = 20.02;
      expect(payto.amount, '20.02');
      expect(payto.value, 20.02);
    });

    test('should handle color customization', () {
      payto.colorBackground = 'ff0000';
      payto.colorForeground = '000000';

      expect(payto.colorBackground, 'ff0000');
      expect(payto.colorForeground, '000000');
      expect(payto.toString(), contains('color-b=ff0000'));
      expect(payto.toString(), contains('color-f=000000'));
    });
  });

  group('ACH Payments', () {
    test('should parse with routing number', () {
      final achPayto = Payto('payto://ach/123456789/1234567');

      expect(achPayto.routingNumber, 123456789);
      expect(achPayto.accountNumber, 1234567);
    });

    test('should parse without routing number', () {
      final achPayto = Payto('payto://ach/1234567');

      expect(achPayto.routingNumber, null);
      expect(achPayto.accountNumber, 1234567);
    });

    test('should validate routing number format', () {
      final achPayto = Payto('payto://ach/address');

      expect(
        () => achPayto.routingNumber = 12345,
        throwsA(isA<PaytoException>()),
      );
    });
  });

  group('UPI/PIX Payments', () {
    test('should handle UPI email alias', () {
      final upiPayto = Payto('payto://upi/USER@example.com');
      expect(upiPayto.accountAlias, 'user@example.com');
    });

    test('should handle PIX email alias', () {
      final pixPayto = Payto('payto://pix/user@EXAMPLE.com');
      expect(pixPayto.accountAlias, 'user@example.com');
    });

    test('should validate email format', () {
      final upiPayto = Payto('payto://upi/address');
      expect(
        () => upiPayto.accountAlias = 'invalid-email',
        throwsA(isA<PaytoException>()),
      );
    });
  });

  group('Location Handling', () {
    test('should handle geo location', () {
      final geoPayto = Payto('payto://void/geo');
      geoPayto.location = '51.5074,0.1278';

      expect(geoPayto.void_, 'geo');
      expect(geoPayto.location, '51.5074,0.1278');
    });

    test('should handle plus code', () {
      final plusPayto = Payto('payto://void/plus');
      plusPayto.location = '8FVC9G8V+R9';

      expect(plusPayto.void_, 'plus');
      expect(plusPayto.location, '8FVC9G8V+R9');
    });

    test('should validate geo coordinates', () {
      final geoPayto = Payto('payto://void/geo');
      expect(
        () => geoPayto.location = 'invalid-coords',
        throwsA(isA<PaytoException>()),
      );
    });
  });

  group('Bank Details', () {
    test('should handle BIC', () {
      final bankPayto = Payto('payto://bic/deutdeff500');
      expect(bankPayto.bic, 'DEUTDEFF500');
    });

    test('should validate BIC format', () {
      final bankPayto = Payto('payto://bic/address');
      expect(
        () => bankPayto.bic = 'invalid-bic',
        throwsA(isA<PaytoException>()),
      );
    });

    test('should handle IBAN', () {
      final ibanPayto = Payto('payto://iban/DE89370400440532013000');
      expect(ibanPayto.iban, 'DE89370400440532013000');
    });
  });

  group('Value Handling', () {
    test('should handle numeric amount', () {
      final numericPayto = Payto('payto://example/address?amount=10.5');
      expect(numericPayto.value, 10.5);
      expect(numericPayto.amount, '10.5');
    });

    test('should handle token amount', () {
      final tokenPayto = Payto('payto://example/address?amount=token:10.5');
      expect(tokenPayto.value, 10.5);
      expect(tokenPayto.amount, 'token:10.5');
      expect(tokenPayto.asset, 'token');
    });
  });

  group('JSON Conversion', () {
    test('should convert to JSON object', () {
      final payto = Payto('payto://xcb/address?amount=10&fiat=eur');
      final json = payto.toJsonObject();

      expect(json.network, 'xcb');
      expect(json.address, 'address');
      expect(json.amount, '10');
      expect(json.fiat, 'eur');
    });

    test('should handle all properties in JSON', () {
      final payto = Payto('payto://xcb/address');
      payto.value = 10;
      payto.colorBackground = 'ff0000';
      payto.message = 'Test payment';

      final json = payto.toJsonObject();
      expect(json.value, 10);
      expect(json.colorBackground, 'ff0000');
      expect(json.message, 'Test payment');
    });
  });

  group('Special Features', () {
    test('should handle donation flag', () {
      final payto = Payto('payto://example/address?donate=1');
      expect(payto.donate, true);
    });

    test('should handle RTL layout', () {
      final payto = Payto('payto://example/address?rtl=1');
      expect(payto.rtl, true);
    });

    test('should handle payment splits', () {
      final payto = Payto('payto://example/address');
      payto.split = ['receiver', '50', true];
      expect(payto.split, equals(['receiver', '50', true]));
    });

    test('should handle deadlines', () {
      final timestamp = 1234567890;
      final payto = Payto('payto://example/address');
      payto.deadline = timestamp;
      expect(payto.deadline, timestamp);
    });
  });
}
