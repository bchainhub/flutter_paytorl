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
  flutter_paytorl: ^0.1.9
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
  payto.language = 'en-US';  // Set language to US English (case preserved)
  print(payto.language);     // 'en-US'

  // Parse existing language parameter
  final localizedPayto = Payto('payto://example/address?lang=en-US&amount=50');
  print(localizedPayto.language); // 'en-US' (case preserved)
  print(localizedPayto.amount);   // '50'

  // ACH payment examples
  final achPayto1 = Payto('payto://ach/123456789/1234567'); // With routing number
  print(achPayto1.routingNumber); // 123456789
  print(achPayto1.accountNumber); // 1234567

  // INTRA payment examples (European inter-bank transfers)
  final intraPayto = Payto('payto://intra/pingchb2/cb1958b39698a44bdae37f881e68dce073823a48a631?amount=usd:20');
  print(intraPayto.bic); // 'PINGCHB2'
  print(intraPayto.accountNumber); // 'cb1958b39698a44bdae37f881e68dce073823a48a631'
  print(intraPayto.amount); // 'usd:20'
  print(intraPayto.value); // 20

  // BIC payment with optional beneficiary account / CORE ID
  final bankPayto = Payto('payto://bic/deutdeff500');
  bankPayto.accountId = 'cb1958b39698a44bdae37f881e68dce073823a48a631';
  print(bankPayto.bic); // 'DEUTDEFF500'
  print(bankPayto.accountId); // 'cb1958b39698a44bdae37f881e68dce073823a48a631'
  print(bankPayto.toString()); // 'payto://bic/deutdeff500/cb1958b39698a44bdae37f881e68dce073823a48a631'

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
| `accountId` | `String?` | Account identifier for `bic` and `intra` payments |
| `accountNumber` | `dynamic` | Account number for ACH payments (int) or INTRA payments (String) |
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
| `language` | `String?` | Language/locale code (2 lowercase letters, optionally followed by `-` and 2 letters in lowercase or uppercase) |
| `location` | `String?` | Location data (format depends on void type) |
| `message` | `String?` | Payment message |
| `mode` | `String?` | Preferred payment mode (e.g., 'qr', 'nfc', 'card') |
| `network` | `String?` | Network identifier (case-insensitive) |
| `contact` | `String?` | Destination for payment receipts, such as an email address or phone number; spaces are removed automatically |
| `routingNumber` | `int?` | Bank routing number (9 digits) |
| `value` | `double?` | Numeric amount value |
| `void_` | `String?` | Void path type (e.g., 'geo', 'plus') |

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `toString()` | `String` | Returns the complete payto URL string |
| `toJson()` | `String` | Returns a JSON string representation |
| `toJsonObject()` | `PaytoJson` | Returns a typed object with all properties |

### BIC Payments

Supports two formats (case-insensitive BIC):

- `payto://bic/bic`
- `payto://bic/bic/account-id`

Example:

```dart
final payto = Payto('payto://bic/deutdeff500/cb1958b39698a44bdae37f881e68dce073823a48a631');
print(payto.bic); // 'DEUTDEFF500'
print(payto.accountId); // 'cb1958b39698a44bdae37f881e68dce073823a48a631'
```

## Setup

You can set the features by setting values for example for the following functionalities.

### Language/Locale Support

The library supports language and locale specification through the `lang` query parameter. The format is validated using a strict regex pattern, and case is preserved as set:

```dart
// Two-letter language codes (must be lowercase)
payto.language = 'en';  // English
payto.language = 'es';  // Spanish
payto.language = 'fr';  // French

// Locale format (language-region)
// First part must be lowercase, second part can be lowercase or uppercase
payto.language = 'en-us';  // US English (all lowercase)
payto.language = 'en-US';  // US English (uppercase region)
payto.language = 'en-gb';  // British English
payto.language = 'es-MX';  // Mexican Spanish (uppercase region)
payto.language = 'fr-ca';  // Canadian French

// Case is preserved (no normalization)
payto.language = 'en-US';
print(payto.language); // 'en-US' (preserved as set)

// Parse from URL
final payto = Payto('payto://example/address?lang=en-US&amount=100');
print(payto.language); // 'en-US' (case preserved from URL)
```

**Valid formats:**

- ✅ `en` (two lowercase letters)
- ✅ `en-us` (two lowercase + `-` + two lowercase)
- ✅ `en-US` (two lowercase + `-` + two uppercase)

**Invalid formats:**

- ❌ `EN` (uppercase first part)
- ❌ `EN-US` (uppercase first part)
- ❌ `En-Us` (mixed case in first part)
- ❌ `en-Us` (mixed case in second part)
- ❌ `eng` (three letters)
- ❌ `en-us-extra` (invalid format)
- ❌ `en_us` (wrong separator)

**Validation rules:**

- Language code must start with 2 lowercase letters
- Optional region code must be either all lowercase or all uppercase (not mixed)
- Case is preserved exactly as provided (no automatic normalization)

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

## PayQR national/interoperable QR payments

Use `payto://qr/{country}/{identifier}` with lowercase ISO country codes. PayQR is global; **Pay QR** is the website's label. Current mappings are BN tarusQR, KH KHQR, ID QRIS, LA LaoQR, MY DuitNow QR, MM MMQR, PH QR Ph, SG PayNow/SGQR, TH PromptPay/Thai QR and VN VietQR.

See [PayQR URI API, field coverage and validation limits](docs/PAYQR.md). A PayTo URI, national payment payload, QR image and payment-network connection are separate things. Generating a syntactically valid QR does not imply participation in or authorization to acquire transactions from a payment network. Unsupported national profiles fail closed.

PayQR support encodes/decodes URI and structured payment data only. National QR payload generation and rendering are owned by the PayTo website.

### Philippine QR Ph payment data

Canonical destination: `payto://qr/ph/{identifier}`; network `qr`, country `ph`, scheme `qrph`.
The identifier is an opaque issuer-provided value, not a verified bank account, mobile number or merchant ID.
The existing generic target stores optional `payment-mode=p2p|p2m` and `qr-type=static|dynamic` in its parameters.
`Payto.paymentMode` and `Payto.qrType` expose validated getters/setters and JSON object properties.
`payment-mode` is a PayTo extension; `mode` remains the existing pass presentation property.

Example (illustrative URI, not an official payment destination or native test vector):

```text
payto://qr/ph/Demo%40Issuer?amount=PHP%3A15.25&payment-mode=p2m&qr-type=dynamic&reference=Bill%201
```

PHP amounts use positive decimal strings with at most two decimal places and the existing 13-character amount limit. No floating-point conversion is used by the QR URI codec. Dynamic requests require an amount in this supported PayTo profile. Static data does not imply a recurring debit mandate. We preserve generic receiver-name/reference fields without claiming a verified native tag mapping. We do not impose participant-specific transaction limits or infer recipient requirements from another country.

**Native QR Ph payload encoding and decoding are not implemented:** researched public sources did not establish the Philippine account templates, routing identifiers and official conformance vectors. A PayTo URI is not a QR Ph payload accepted by banking apps. No generic EMV payload is classified as QR Ph merely from PH/PHP.

Architecture, when a verified native profile becomes available:

```text
PayTo URI → structured payment data → native encoder → payload string
scanned payload string → native decoder → structured data → PayTo URI
```

The native arrows above are currently unavailable for QR Ph. Libraries stop at data, never render QR images, scan cameras, enroll merchants, connect to InstaPay, transfer funds or check payment status. QR URI input is capped at 8192 characters; duplicate query keys, controls, malformed escaping and invalid amounts are rejected.

Sources: [BSP QR Ph](https://www.bsp.gov.ph/SitePages/MediaAndResearch/Multimedia_QRPh.aspx), [BSP P2P FAQ](https://www.bsp.gov.ph/Media_and_Research/Primers%20Faqs/QR_Ph_P2P_FAQs.pdf), [BSP P2M FAQ](https://www.bsp.gov.ph/Media_and_Research/Primers%20Faqs/QR_Ph_P2M_FAQs.pdf), [PayMongo MPM API](https://docs.paymongo.com/reference/generate-mpm-qr), [PayMongo QR Ph acceptance](https://docs.paymongo.com/docs/payment-acceptance-qr-ph). Provider API fields are evidence for supported payment concepts, not the national TLV layout.

### Indonesian QRIS payment data

Canonical URI: `payto://qr/id/{identifier}`. Network `qr`, country `id`, scheme `qris`, domestic currency `IDR`.
The path remains an opaque acquirer-issued identifier (`issuer` type). It is **not** relabeled NMID or Merchant PAN: the reviewed public material does not establish sufficient routing semantics for that mapping. Do not invent these provider-issued values.

```text
payto://qr/id/Demo?qr-type=static
payto://qr/id/Demo?amount=IDR%3A50000&qr-type=dynamic&reference=Bill%201
```

These illustrative links are not native QRIS payloads. Optional `qr-type=static|dynamic` uses the existing `qrType` property. Explicit static requests reject amount; dynamic requests require it. Unspecified type preserves a portable suggested amount without generating a native transaction. Amounts are positive IDR decimal strings, at most two fractional digits, capped at IDR 10,000,000 using integer minor-unit comparison. Decimal precision is the existing portable profile, not a claim that every provider accepts fractional rupiah. Generic `receiver-name` and `reference` remain portable metadata without a verified QRIS tag mapping. No static-to-dynamic payload conversion is implemented.

`inspectEmvMpm(payload)` provides bounded **raw ASCII EMV envelope inspection** in both libraries. It checks TLV boundaries, duplicate fields, nested template boundaries and CRC, then returns `fields` and `templates`. Its JSON shape matches across TypeScript and Dart (Dart uses `.toJson()`). It does not return a national scheme, NMID, Merchant PAN or PayTo target and is not a QRIS compliance validator. It rejects non-ASCII input and payloads over 4096 characters; nested unknown subfields stay raw. The official Midtrans example is a fixture with published CRC `A623`.

**Native QRIS encoding and semantic decoding remain unsupported.** Full authoritative routing/template requirements were not available in the reviewed public material. ASPI documents a specification request process. Neither a correct CRC nor ID/360 proves QRIS validity. No guessed national tags, transaction identifiers or provider credentials are generated. The website uses PayTo for this country and hides the native-format switch.

```text
PayTo URI ↔ structured portable QR data
provider payload → raw EMV inspection (no payment destination inference)
structured QRIS → native encoder → payload → website renderer [not implemented]
```

Libraries render no images, perform no scanning or network calls, register no merchants, issue no identifiers and perform no transfers, status checks or settlement. Static QR does not authorize recurring debits. CPM, QRIS TAP, Tuntas, cross-border routing/FX and provider connectivity are outside this implementation.

Sources: [Bank Indonesia QRIS](https://www.bi.go.id/id/fungsi-utama/sistem-pembayaran/ritel/kanal-layanan/QRIS/default.aspx), [ASPI QRIS modes](https://aspi-indonesia.or.id/standar-dan-layanan/qris/), [ASPI specification-request process, annual report p. 46](https://aspi-indonesia.or.id/files/2024/12/AR%20ASPI%202023-FA_all_rev.pdf), [Midtrans official dynamic example](https://docs.midtrans.com/docs/gopay-qris-pos-integration), [EMVCo QR specifications](https://www.emvco.com/emv-technologies/qr-codes/), [BI cross-border QRIS](https://www.bi.go.id/id/fungsi-utama/sistem-pembayaran/ritel/kanal-layanan/QRIS/QRIS-Antarnegara/default.aspx).


### Presentation formats and URI extensions

`Payto.formats` returns `['payto', 'epc']` for IBAN, or `['payto', '<scheme>']`
for supported Pay QR countries: `khqr`, `laoqr`, `duitnow`, `mmqr`, `paynow`,
`promptpay`, and `vietqr`. PayTo-only methods (including Brunei, QR Ph, and QRIS)
omit `formats` from object JSON; the getter returns `null`.
PayTo is always first and is the default. Capability metadata does not validate
whether the supplied fields are sufficient for a native payment format.

`reference`, `purpose`, and `information` are readable/writable PayTo query
extensions, also exposed in object JSON. Assign `null` to remove them. Unknown
query extensions remain preserved by the URI codec. `formats` is derived metadata,
not a query parameter; reading it never changes the PayTo link.

These libraries encode and decode **PayTo links only**. They do not generate or
parse EPC or national payment payloads, or render barcodes. Applications implement
those formats and validate their requirements separately.


**Validation coverage is partial:** all current Pay QR fields round-trip through
the parameter map, but dedicated field accessors/top-level JSON properties and
country-specific validation are not complete. See [field coverage and known
validation gaps](docs/PAYQR.md#field-coverage-and-validation-boundaries).
