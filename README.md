# Flutter PaytoRL

`flutter_paytorl` is a Flutter library for handling Payto Resource Locators (PRLs). This library is based on the [URL](https://developer.mozilla.org/en-US/docs/Web/API/URL) API and provides additional functionality for managing PRLs.

[![pub package](https://img.shields.io/pub/v/flutter_paytorl.svg)](https://pub.dev/packages/flutter_paytorl)
[![License: CORE](https://img.shields.io/badge/License-CORE-yellow?logo=googledocs)](LICENSE)
[![Publisher](https://img.shields.io/badge/Publisher-blockchainhub.digital-blue)](https://pub.dev/publishers/blockchainhub.digital)
[![Flutter Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Wasm-blue)](https://pub.dev/packages/flutter_paytorl)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/bchainhub?label=Sponsors&logo=githubsponsors&color=EA4AAA)](https://github.com/sponsors/bchainhub)

## Features

- 🐥 **Small**: Minimal footprint, distributed as optimized Dart package
- 📜 **Standardized**: Based on the [URL](https://developer.mozilla.org/en-US/docs/Web/API/URL) Web API
- 🏗️ **Simple**: Easy to implement in Flutter applications
- 🗂 **Typed**: Ships with strong type definitions
- 🧪 **Tested**: Comprehensive test coverage
- 🌲 **Tree Shaking**: Zero dependencies, no side effects
- 📱 **Cross Platform**: Supports Android, iOS, Web, macOS, Windows, Linux, and Wasm
- 🌍 **Internationalization**: Built-in language/locale support

## Installation

Add `flutter_paytorl` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_paytorl: ^0.1.4
```

Or install via command line:

```sh
flutter pub add flutter_paytorl
```

## Usage

Here's an example of how to use the `flutter_paytorl` package:

```dart
import 'package:flutter_paytorl/flutter_paytorl.dart';

void main() {
  // Basic payment URL
  final paytoString = 'payto://xcb/cb7147879011ea207df5b35a24ca6f0859dcfb145999?amount=ctn:10.01&fiat=eur';
  final payto = Payto(paytoString);

  // Standard payment properties
  print(payto.address);  // 'cb7147879011ea207df5b35a24ca6f0859dcfb145999'
  print(payto.amount);   // 'ctn:10.01'
  print(payto.value);    // 10.01
  print(payto.network);  // 'xcb'
  print(payto.currency); // ['ctn', 'eur']

  // Update payment amount
  payto.value = 20.02;
  print(payto.amount);   // 'ctn:20.02'
  print(payto.fiat);     // 'eur'

  // Color customization
  payto.colorBackground = 'ff0000';  // Red background (6-character hex)
  payto.colorForeground = '000000';  // Black foreground
  print(payto.colorBackground); // 'ff0000'

  // Language/locale support
  payto.language = 'en-us';  // Set language to US English
  print(payto.language);     // 'en-us'

  // Parse existing language parameter
  final localizedPayto = Payto('payto://example/address?lang=es-mx&amount=50');
  print(localizedPayto.language); // 'es-mx'
  print(localizedPayto.amount);   // '50'

  // ACH payment examples
  final achPayto1 = Payto('payto://ach/123456789/1234567'); // With routing number
  print(achPayto1.routingNumber); // 123456789
  print(achPayto1.accountNumber); // 1234567

  // UPI/PIX payment examples (case-insensitive email)
  final upiPayto = Payto('payto://upi/USER@example.com');
  print(upiPayto.accountAlias); // 'user@example.com'

  // Geo location example
  final geoPayto = Payto('payto://void/geo');
  geoPayto.location = '51.507400000,0.127800000';  // High-precision coordinates (9 decimal places)
  print(geoPayto.void_);     // 'geo'
  print(geoPayto.location); // '51.507400000,0.127800000'

  // Mode specification
  payto.mode = 'qr';  // Set payment mode to QR code
  print(payto.mode);  // 'qr'
}
```

## API Reference

### Constructor

```dart
Payto(String paytoString)
```

Creates a new Payto instance from a payto URL string.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `accountAlias` | `String?` | Email address for UPI/PIX payments (case-insensitive) |
| `accountNumber` | `int?` | Account number (7-14 digits) for ACH payments |
| `address` | `String?` | Payment address |
| `amount` | `String?` | Payment amount with optional currency prefix |
| `asset` | `String?` | Asset type or contract address |
| `barcode` | `String?` | Barcode format |
| `bic` | `String?` | Bank Identifier Code (8 or 11 characters, case-insensitive) |
| `colorBackground` | `String?` | Background color in 6-character hex format |
| `colorForeground` | `String?` | Foreground color in 6-character hex format |
| `currency` | `List<String?>?` | Currency codes array [asset, fiat] |
| `deadline` | `int?` | Payment deadline (Unix timestamp) |
| `donate` | `bool?` | Donation flag |
| `fiat` | `String?` | Fiat currency code (case-insensitive) |
| `iban` | `String?` | International Bank Account Number (case-insensitive) |
| `language` | `String?` | Language/locale code (2-letter or locale format) |
| `location` | `String?` | Location data (format depends on void type) |
| `message` | `String?` | Payment message |
| `mode` | `String?` | Preferred payment mode (e.g., 'qr', 'nfc', 'card') |
| `network` | `String?` | Network identifier (case-insensitive) |
| `routingNumber` | `int?` | Bank routing number (9 digits) |
| `value` | `double?` | Numeric amount value |
| `void_` | `String?` | Void path type (e.g., 'geo', 'plus') |

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `toString()` | `String` | Returns the complete payto URL string |
| `toJson()` | `String` | Returns a JSON string representation |
| `toJsonObject()` | `PaytoJson` | Returns a typed object with all properties |

## Setup

You can set the features by setting values for example for the following functionalities.

### Language/Locale Support

The library supports language and locale specification through the `lang` query parameter:

```dart
// Two-letter language codes
payto.language = 'en';  // English
payto.language = 'es';  // Spanish
payto.language = 'fr';  // French

// Locale format (language-region)
payto.language = 'en-us';  // US English
payto.language = 'en-gb';  // British English
payto.language = 'es-mx';  // Mexican Spanish
payto.language = 'fr-ca';  // Canadian French

// Mixed case is automatically normalized
payto.language = 'En-Us';  // Normalized to 'en-us'
payto.language = 'ES-MX';  // Normalized to 'es-mx'

// Parse from URL
final payto = Payto('payto://example/address?lang=de-de&amount=100');
print(payto.language); // 'de-de'
```

**Valid formats:**

- ✅ `en` (two-letter language code)
- ✅ `en-us` (locale format, lowercase)
- ✅ `en-US` (locale format, mixed case)
- ✅ `en-Us` (locale format, mixed case)

**Invalid formats:**

- ❌ `EN-US` (all uppercase)
- ❌ `eng` (three letters)
- ❌ `en-us-extra` (invalid format)
- ❌ `en_us` (wrong separator)

### Mode Support

The library supports payment mode specification through the `mode` query parameter:

```dart
// Set payment mode
payto.mode = 'qr';      // QR code payment
payto.mode = 'nfc';     // NFC payment

// Parse existing mode parameter
final payto = Payto('payto://example/address?mode=qr&amount=100');
print(payto.mode); // 'qr'

// Mode is automatically normalized to lowercase
payto.mode = 'NFC';
print(payto.mode); // 'nfc'

// Remove mode
payto.mode = null;
```

The parameter will only affect the display of the payment pass and only if that is supported by the payment provider.

### Geographic Coordinates

The library supports high-precision geographic coordinates with up to 9 decimal places:

```dart
// High-precision coordinates (sub-millimeter accuracy)
final geoPayto = Payto('payto://void/geo');
geoPayto.location = '51.507400000,0.127800000';  // 9 decimal places

// Standard precision coordinates
geoPayto.location = '51.5074,0.1278';            // 4 decimal places

// Parse existing coordinates
final payto = Payto('payto://void/geo?loc=40.7128,-74.0060');
print(payto.location); // '40.7128,-74.0060'
```

**Coordinate formats supported:**

- ✅ **Latitude**: `-90.000000000` to `+90.000000000` (9 decimal places)
- ✅ **Longitude**: `-180.000000000` to `+180.000000000` (9 decimal places)
- ✅ **Optional signs**: `+` or `-` prefix
- ✅ **Mixed precision**: Any number of decimal places from 1 to 9

## Platform Support

| Android | iOS | Web | macOS | Windows | Linux | Wasm |
|---------|-----|-----|-------|---------|-------|------|
| ✅      | ✅  | ✅  | ✅    | ✅     | ✅     | ✅   |

## License

This project is licensed under the CORE License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## Acknowledgments

- Based on the [URL](https://developer.mozilla.org/en-US/docs/Web/API/URL) Web API
- Implements [RFC 8905](https://datatracker.ietf.org/doc/html/rfc8905) - The 'payto' URI Scheme

## Funding

If you find this project useful, please consider supporting it:

- [GitHub Sponsors](https://github.com/sponsors/bchainhub)
- [Core](https://blockindex.net/address/cb7147879011ea207df5b35a24ca6f0859dcfb145999)
- [Bitcoin](https://www.blockchain.com/explorer/addresses/btc/bc1pd8guxjkr2p6n2kl388fdj2trete9w2fr89xlktdezmcctxvtzm8qsymg0d)
- [Litecoin](https://www.blockchain.com/explorer/addresses/ltc/ltc1ql8dvx0wv0nh2vncpt9j3zqefaehsd25cwp7pfx)

List of sponsors: [![GitHub Sponsors](https://img.shields.io/github/sponsors/bchainhub?label=Sponsors&logo=githubsponsors&color=EA4AAA)](https://github.com/sponsors/bchainhub)
