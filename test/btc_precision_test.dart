import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_paytorl/flutter_paytorl.dart';

void main() {
	// Fresh random BIP173 witness program, generated for this regression only.
	const address = 'bc1q2arlmu9m58k22htatp099kznd32pygqm9luxw0';
	for (final amount in ['0.000123', '0.00000001', '0.00012345', '0.00009999', '1.23456789', '21000000.00000000', '0.00012300', '0.12345678', '0.10000000', '1.00000000', '0.00000000']) {
		for (final currency in ['btc', 'BTC']) {
			test('$currency:$amount retains precision through all representations', () {
				final payto = Payto('payto://btc/$address?amount=$currency%3A$amount&org=Precision%20Test&item=Test%20BTC&color-b=8539ef');
				expect(Payto('payto://btc/$address?amount=$currency:$amount').amount, '$currency:$amount');
				expect(payto.address, address);
				expect(payto.amount, '$currency:$amount');
				expect(payto.value, double.parse(amount));
				expect(payto.currency[0], currency);
				expect(payto.toJsonObject().toJson()['amount'], '$currency:$amount');
				expect(Payto(payto.href).amount, '$currency:$amount');
				payto.value = double.parse(amount);
				expect(Payto(payto.href).value, double.parse(amount));
			});
		}
	}
}
