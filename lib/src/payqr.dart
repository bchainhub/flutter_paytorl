/// Global PayQR metadata. An empty currency list means not verified, not unrestricted.
const payQrSchemes = <String, PayQrScheme>{
  'bn': PayQrScheme('tarusqr', 'tarusQR', [], ['issuer']),
  'kh': PayQrScheme('khqr', 'KHQR', ['KHR', 'USD'], ['bakong']),
  'id': PayQrScheme('qris', 'QRIS', ['IDR'], ['issuer']),
  'la': PayQrScheme('laoqr', 'LaoQR', ['LAK'], ['issuer']),
  'my': PayQrScheme('duitnow', 'DuitNow QR', ['MYR'], ['merchant']),
  'mm': PayQrScheme('mmqr', 'MMQR / MyanmarPay', ['MMK'], ['merchant']),
  'ph': PayQrScheme('qrph', 'QR Ph', ['PHP'], ['issuer']),
  'sg': PayQrScheme('paynow', 'SGQR / PayNow', ['SGD'], ['mobile', 'uen']),
  'th': PayQrScheme(
    'promptpay',
    'Thai QR / PromptPay QR',
    ['THB'],
    ['mobile', 'national-id', 'ewallet'],
  ),
  'vn': PayQrScheme('vietqr', 'VietQR', ['VND'], ['account']),
};

class PayQrScheme {
  final String id;
  final String name;
  final List<String> currencies;
  final List<String> identifierTypes;
  const PayQrScheme(this.id, this.name, this.currencies, this.identifierTypes);
}

/// Portable destination only. This is not a national QR payload or network connection.
class PayQrTarget {
  final String country;
  final String identifier;
  final String identifierType;
  final Map<String, String> parameters;
  String get scheme => payQrSchemes[country]!.id;

  PayQrTarget._(
    this.country,
    this.identifier,
    this.identifierType,
    Map<String, String> parameters,
  ) : parameters = Map.unmodifiable(parameters);

  factory PayQrTarget.parse(String input) {
    if (input.length > 8192)
      throw FormatException('PayQR URI exceeds 8192 characters');
    if (RegExp(r'[\x00-\x20\x7f]|%(?![0-9a-fA-F]{2})').hasMatch(input)) {
      throw FormatException('Malformed PayQR URI');
    }
    final match = RegExp(
      r'^payto://qr/([A-Za-z]{2})/([^/?#]+)(?:\?([^#]*))?$',
      caseSensitive: false,
    ).firstMatch(input);
    if (match == null)
      throw FormatException('Expected payto://qr/{country}/{identifier}');
    final country = match[1]!.toLowerCase();
    final metadata = payQrSchemes[country];
    if (metadata == null) throw FormatException('Unsupported PayQR country');
    var identifier = Uri.decodeComponent(match[2]!);
    final parameters = <String, String>{};
    final query = match[3];
    if (query != null && query.isNotEmpty) {
      for (final pair in query.split('&')) {
        final index = pair.indexOf('=');
        if (index < 0)
          throw FormatException('PayQR query parameters require values');
        final key = Uri.decodeQueryComponent(pair.substring(0, index));
        final value = Uri.decodeQueryComponent(pair.substring(index + 1));
        if (parameters.containsKey(key))
          throw FormatException('Duplicate PayQR query parameter');
        if (!RegExp(r'^[a-z][a-z0-9-]*$').hasMatch(key) ||
            value.length > 512 ||
            RegExp(r'[\x00-\x1f\x7f]').hasMatch(value))
          throw FormatException('Invalid PayQR query parameter');
        parameters[key] = value;
      }
    }
    if (country == 'id' &&
        parameters['qr-type'] == 'static' &&
        parameters.containsKey('amount'))
      throw FormatException('Static QRIS requests must not include an amount');
    if (parameters.containsKey('payment-mode') &&
        (country != 'ph' ||
            !['p2p', 'p2m'].contains(parameters['payment-mode'])))
      throw FormatException('Invalid payment-mode; use p2p or p2m for QR Ph');
    if (parameters.containsKey('qr-type') &&
        !['static', 'dynamic'].contains(parameters['qr-type']))
      throw FormatException('Invalid QR type');
    if (parameters['qr-type'] == 'dynamic' && !parameters.containsKey('amount'))
      throw FormatException(
        'Dynamic PayQR requests require an amount in this profile',
      );
    if (['kh', 'my', 'mm', 'sg', 'th', 'la'].contains(country)) {
      for (final entry in {'receiver-name': 25, 'merchant-city': 15}.entries) {
        final value = parameters[entry.key];
        if (value != null &&
            (value.isEmpty || value.runes.length > entry.value))
          throw FormatException('Invalid ${entry.key} length');
      }
    }
    if (parameters.containsKey('mcc') &&
        !RegExp(r'^[0-9]{4}$').hasMatch(parameters['mcc']!))
      throw FormatException('Invalid merchant category code');
    if (['my', 'vn', 'la'].contains(country) &&
        parameters.containsKey('acquirer-id') &&
        !RegExp(r'^[0-9]{6}$').hasMatch(parameters['acquirer-id']!))
      throw FormatException('Invalid acquirer ID');
    final applicationId = parameters['application-id'];
    if (applicationId != null &&
        (country != 'la' ||
            !RegExp(r'^[A-Za-z0-9]{16}$').hasMatch(applicationId)))
      throw FormatException('Invalid application-id');
    final qrCurrency = parameters['qr-currency'];
    if (qrCurrency != null &&
        (country != 'kh' ||
            !['KHR', 'USD'].contains(qrCurrency) ||
            (parameters['amount'] != null &&
                !parameters['amount']!.startsWith('$qrCurrency:'))))
      throw FormatException('Invalid qr-currency');
    final schemeId = parameters['scheme-id'];
    if (schemeId != null &&
        (country != 'mm' ||
            schemeId.length > 32 ||
            !RegExp(r'^[A-Za-z0-9]+(?:\.[A-Za-z0-9-]+)+$').hasMatch(schemeId)))
      throw FormatException('Invalid scheme-id');
    final localName = parameters['local-name'];
    if (localName != null &&
        (country != 'mm' ||
            !RegExp(
              r'^[\u1000-\u109f\uAA60-\uAA7F\uA9E0-\uA9FF 0-9]{1,25}$',
              unicode: true,
            ).hasMatch(localName) ||
            !RegExp(r'\p{Script=Myanmar}', unicode: true).hasMatch(localName)))
      throw FormatException('Invalid local-name');
    final asciiLimits = <String, int>{
      'bill-number': 25,
      'store-label': 25,
      'terminal-label': 25,
      'mobile-number': 25,
      'merchant-mobile': 15,
      'merchant-id': 32,
      'acquiring-bank': 32,
      'account-information': 32,
    };
    for (final entry in asciiLimits.entries) {
      if (parameters[entry.key] != null &&
          !RegExp(
            '^[\\x20-\\x7e]{1,${entry.value}}\$',
          ).hasMatch(parameters[entry.key]!))
        throw FormatException('Invalid ${entry.key}');
    }
    if (parameters['postal-code'] != null &&
        (country != 'my' ||
            !RegExp(r'^[0-9]{5}$').hasMatch(parameters['postal-code']!)))
      throw FormatException('Invalid postal-code');
    if (parameters['recipient-type'] != null &&
        (country != 'kh' ||
            !['individual', 'merchant'].contains(parameters['recipient-type'])))
      throw FormatException('Invalid recipient-type');
    if (parameters['amount-editable'] != null &&
        (country != 'sg' ||
            !['0', '1'].contains(parameters['amount-editable'])))
      throw FormatException('Invalid amount-editable');
    if (parameters['expiry-date'] != null) {
      final date = parameters['expiry-date']!;
      if (country != 'sg' || !RegExp(r'^[0-9]{8}$').hasMatch(date))
        throw FormatException('Invalid expiry-date');
      final iso =
          '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}';
      final parsed = DateTime.tryParse('${iso}T00:00:00Z');
      if (parsed == null || parsed.toIso8601String().substring(0, 10) != iso)
        throw FormatException('Invalid expiry-date');
    }
    for (final key in ['creation-timestamp', 'expiration-timestamp']) {
      if (parameters[key] != null &&
          (country != 'kh' ||
              !RegExp(r'^[0-9]{13}$').hasMatch(parameters[key]!)))
        throw FormatException('Invalid $key');
    }
    if (parameters.containsKey('scheme') || parameters.containsKey('currency'))
      throw FormatException('Use country for scheme and amount=CURRENCY:value');
    final type =
        parameters['identifier-type'] ?? metadata.identifierTypes.first;
    identifier = normalizePayQrIdentifier(country, identifier, type);
    if (!metadata.identifierTypes.contains(type))
      throw FormatException('Unsupported PayQR identifier type');
    if (!RegExp(
          r'^[\p{L}\p{N}_.@+\-]{1,128}$',
          unicode: true,
        ).hasMatch(identifier) ||
        identifier == '.' ||
        identifier == '..')
      throw FormatException('Invalid PayQR identifier');
    if (RegExp(r'[\x00-\x20\x7f]').hasMatch(identifier))
      throw FormatException('Invalid PayQR identifier');
    final rules = <String, Map<String, String>>{
      'kh': {'bakong': r'^[A-Za-z0-9_.\-]+@[A-Za-z0-9_\-]+$'},
      'vn': {'account': r'^[A-Za-z0-9]{1,19}$'},
      'my': {'merchant': r'^[A-Za-z0-9]{1,28}$'},
      'mm': {'merchant': r'^[0-9]{15}$'},
      'sg': {'mobile': r'^\+65[89][0-9]{7}$', 'uen': r'^[A-Z0-9]{10}$'},
      'th': {
        'mobile': r'^0066[0-9]{9}$',
        'national-id': r'^[0-9]{13}$',
        'ewallet': r'^[0-9]{15}$',
      },
    };
    final rule = rules[country]?[type];
    if ((country == 'kh' && identifier.length > 32) ||
        (rule != null && !RegExp(rule).hasMatch(identifier)))
      throw FormatException('Invalid ${metadata.name} $type identifier');
    final amount = parameters['amount'];
    if (amount != null) {
      final parts = RegExp(
        r'^([A-Z]{3}):((?:0|[1-9][0-9]*)(?:\.[0-9]{1,2})?)$',
      ).firstMatch(amount);
      if (parts == null ||
          !metadata.currencies.contains(parts[1]) ||
          parts[2]!.length > 13 ||
          !RegExp('[1-9]').hasMatch(parts[2]!) ||
          ((country == 'vn' || (country == 'kh' && parts[1] == 'KHR')) &&
              parts[2]!.contains('.')))
        throw FormatException('Invalid PayQR amount or unsupported currency');
      // Bank Indonesia domestic QRIS transaction limit; decimal-safe comparison.
      if (country == 'id') {
        final decimal = parts[2]!.split('.');
        final minor =
            BigInt.parse(decimal[0]) * BigInt.from(100) +
            BigInt.parse(
              (decimal.length == 2 ? decimal[1] : '').padRight(2, '0'),
            );
        if (minor > BigInt.from(1000000000))
          throw FormatException('QRIS amount exceeds IDR 10000000');
      }
    }
    return PayQrTarget._(country, identifier, type, parameters);
  }

  factory PayQrTarget({
    required String country,
    required String identifier,
    String? identifierType,
    Map<String, String> parameters = const {},
  }) {
    identifier = normalizePayQrIdentifier(
      country,
      identifier,
      identifierType ??
          parameters['identifier-type'] ??
          payQrSchemes[country]?.identifierTypes.first ??
          '',
    );
    final params = {...parameters};
    if (identifierType != null) params['identifier-type'] = identifierType;
    final keys = params.keys.toList()..sort();
    final query = keys
        .map(
          (key) =>
              '${Uri.encodeComponent(key)}=${Uri.encodeComponent(params[key]!)}',
        )
        .join('&');
    return PayQrTarget.parse(
      'payto://qr/$country/${Uri.encodeComponent(identifier)}${query.isEmpty ? '' : '?$query'}',
    );
  }

  @override
  String toString() {
    final params = {...parameters};
    if (params['identifier-type'] ==
        payQrSchemes[country]!.identifierTypes.first)
      params.remove('identifier-type');
    final keys = params.keys.toList()..sort();
    final query = keys
        .map(
          (key) =>
              '${Uri.encodeComponent(key)}=${Uri.encodeComponent(params[key]!)}',
        )
        .join('&');
    return 'payto://qr/$country/${Uri.encodeComponent(identifier)}${query.isEmpty ? '' : '?$query'}';
  }

  Map<String, dynamic> toJson() => {
    'country': country,
    'scheme': scheme,
    'identifier': identifier,
    'identifierType': identifierType,
    'parameters': parameters,
  };
}

String normalizePayQrIdentifier(
  String country,
  String identifier,
  String type,
) {
  if (country == 'th' && type == 'mobile') {
    if (RegExp(r'^0[0-9]{9}$').hasMatch(identifier))
      return '0066${identifier.substring(1)}';
    if (RegExp(r'^\+66[0-9]{9}$').hasMatch(identifier))
      return '0066${identifier.substring(3)}';
  }
  return identifier;
}
