import 'package:flutter_test/flutter_test.dart';
import 'payqr_contract.dart';

void main() {
  for (final entry in payQrContract().entries) {
    test(entry.key, entry.value);
  }
}
