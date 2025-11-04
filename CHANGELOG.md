# Changelog

## 0.1.8

> Added

- **INTRA Payment Support**: Full support for European inter-bank transfers
  - BIC/SWIFT code support for INTRA hostname
  - Dynamic account number type (int for ACH, String for INTRA)
  - Support for alphanumeric account numbers (e.g., hexadecimal addresses)
  - Comprehensive test coverage for INTRA payments

> Changed

- Updated `accountNumber` property to support both ACH (int) and INTRA (String) payments
- Updated `BIC` property to support `intra` hostname alongside `bic` and `iban`
- Updated `PaytoJson` model to support dynamic account numbers

## 0.1.7

> Added

- **Language/Locale Support**: Strict validation and case preservation
  - Regex-based validation: `/^[a-z]{2}(-[a-z]{2}|-[A-Z]{2})?$/`
  - Case preservation (no automatic normalization)
  - Valid formats: `en`, `en-us`, `en-US`
  - Invalid formats: `EN`, `En-Us`, `en-Us`, `EN-US` (validates strict format)
- **Mode Parameter**: Payment mode specification
  - Support for `mode` query parameter (e.g., 'qr', 'nfc', 'card')
  - Automatic lowercase normalization on getter
  - JSON serialization support
- **Enhanced Geographic Coordinates**: High-precision support
  - Increased precision from 6 to 9 decimal places
  - Sub-millimeter accuracy for geographic applications
  - Support for coordinates with 1-9 decimal places

> Changed

- Language validation now uses strict regex pattern
- Language values preserve original case (no lowercasing)
- Geographic coordinate regex updated to support 9 decimal places

> Fixed

- Improved validation error messages for language codes
- Fixed color property getters/setters
- Updated JSON object conversion to include all new properties

## 0.1.1

- Updated pubspec.yaml
- Upgraded dependencies

## 0.1.0

Initial release of Flutter PaytoRL 🎉

> Features

- 🎯 Full Dart/Flutter implementation of PaytoRL
- 🔄 Conversion from TypeScript to Flutter
- 📱 Cross-platform support (Android, iOS, Web, macOS, Windows, Linux, Wasm)
- 🧪 Comprehensive test coverage
- 📚 Complete API documentation

> Added

- Core `Payto` class implementation
- Payment URL parsing and manipulation
- Support for various payment types:
  - ACH payments
  - UPI/PIX payments
  - Bank transfers (BIC/IBAN)
  - Cryptocurrency payments
  - Geo-location based payments
- JSON serialization support
- Strong type definitions
- Comprehensive error handling
- Platform-specific implementations
- Example Flutter application

> Developer Experience

- Zero external dependencies
- Tree-shaking support
- Null safety
- Comprehensive test suite
- Detailed API documentation
- Example usage in README

> Documentation

- Full API reference
- Usage examples
- Platform support details
- Contributing guidelines
