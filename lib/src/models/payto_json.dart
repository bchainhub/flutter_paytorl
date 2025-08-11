/// A class representing the JSON structure of a Payto Resource Locator
class PaytoJson {
  /// Email address for UPI/PIX payments (case-insensitive)
  final String? accountAlias;

  /// Account number (7-14 digits) for ACH payments
  final int? accountNumber;

  /// Payment address
  final String? address;

  /// Payment amount with optional currency prefix
  final String? amount;

  /// Asset type or contract address
  final String? asset;

  /// Barcode format ('qr', 'pdf417', 'aztec', 'code128')
  final String? barcode;

  /// Bank Identifier Code (8 or 11 characters, case-insensitive)
  final String? bic;

  /// Background color in 6-character hex format
  final String? colorBackground;

  /// Foreground color in 6-character hex format
  final String? colorForeground;

  /// Currency codes array [asset, fiat]
  final List<String?> currency;

  /// Payment deadline (Unix timestamp)
  final int? deadline;

  /// Donation flag
  final bool? donate;

  /// Fiat currency code (case-insensitive)
  final String? fiat;

  /// URL fragment
  final String fragment;

  /// Complete host (hostname:port)
  final String host;

  /// Host without port (case-insensitive)
  final String hostname;

  /// Complete URL string
  final String href;

  /// International Bank Account Number (case-insensitive)
  final String? iban;

  /// Item description (max 40 chars)
  final String? item;

  /// Language/locale code (2-letter or locale format)
  final String? language;

  /// Location data (format depends on void type)
  final String? location;

  /// Payment message
  final String? message;

  /// Preferred mode of Pass
  final String? mode;

  /// Network identifier (case-insensitive)
  final String network;

  /// Organization name (max 25 chars)
  final String? organization;

  /// URL origin
  final String origin;

  /// URL path
  final String path;

  /// URL port
  final String? port;

  /// URL protocol (always 'payto:')
  final String protocol;

  /// Receiver's name
  final String? receiverName;

  /// Recurring payment details
  final String? recurring;

  /// Bank routing number (9 digits)
  final int? routingNumber;

  /// Right-to-left layout
  final bool? rtl;

  /// URL search string
  final String search;

  /// Payment split information [receiver, amount, isPercentage]
  final List<dynamic>? split;

  /// Swap transaction details
  final String? swap;

  /// Numeric amount value
  final double? value;

  /// Void path type (e.g., 'geo', 'plus')
  final String? void_;

  /// Creates a new PaytoJson instance
  PaytoJson({
    required this.accountAlias,
    required this.accountNumber,
    required this.address,
    required this.amount,
    required this.asset,
    required this.barcode,
    required this.bic,
    required this.colorBackground,
    required this.colorForeground,
    required this.currency,
    required this.deadline,
    required this.donate,
    required this.fiat,
    required this.fragment,
    required this.host,
    required this.hostname,
    required this.href,
    required this.iban,
    required this.item,
    required this.language,
    required this.location,
    required this.message,
    required this.mode,
    required this.network,
    required this.organization,
    required this.origin,
    required this.path,
    required this.port,
    required this.protocol,
    required this.receiverName,
    required this.recurring,
    required this.routingNumber,
    required this.rtl,
    required this.search,
    required this.split,
    required this.swap,
    required this.value,
    required this.void_,
  });

  /// Creates a PaytoJson instance from a JSON map
  factory PaytoJson.fromJson(Map<String, dynamic> json) => PaytoJson(
        accountAlias: json['accountAlias'] as String?,
        accountNumber: json['accountNumber'] as int?,
        address: json['address'] as String?,
        amount: json['amount'] as String?,
        asset: json['asset'] as String?,
        barcode: json['barcode'] as String?,
        bic: json['bic'] as String?,
        colorBackground: json['colorBackground'] as String?,
        colorForeground: json['colorForeground'] as String?,
        currency: (json['currency'] as List<dynamic>?)?.cast<String?>() ?? [],
        deadline: json['deadline'] as int?,
        donate: json['donate'] as bool?,
        fiat: json['fiat'] as String?,
        fragment: json['fragment'] as String? ?? '',
        host: json['host'] as String? ?? '',
        hostname: json['hostname'] as String? ?? '',
        href: json['href'] as String? ?? '',
        iban: json['iban'] as String?,
        item: json['item'] as String?,
        language: json['language'] as String?,
        location: json['location'] as String?,
        message: json['message'] as String?,
        mode: json['mode'] as String?,
        network: json['network'] as String? ?? '',
        organization: json['organization'] as String?,
        origin: json['origin'] as String? ?? '',
        path: json['path'] as String? ?? '',
        port: json['port'] as String?,
        protocol: json['protocol'] as String? ?? '',
        receiverName: json['receiverName'] as String?,
        recurring: json['recurring'] as String?,
        routingNumber: json['routingNumber'] as int?,
        rtl: json['rtl'] as bool?,
        search: json['search'] as String? ?? '',
        split: json['split'] as List<dynamic>?,
        swap: json['swap'] as String?,
        value: json['value'] as double?,
        void_: json['void'] as String?,
      );

  /// Converts the PaytoJson instance to a JSON map
  Map<String, dynamic> toJson() => {
        if (accountAlias != null) 'accountAlias': accountAlias,
        if (accountNumber != null) 'accountNumber': accountNumber,
        if (address != null) 'address': address,
        if (amount != null) 'amount': amount,
        if (asset != null) 'asset': asset,
        if (barcode != null) 'barcode': barcode,
        if (bic != null) 'bic': bic,
        if (colorBackground != null) 'colorBackground': colorBackground,
        if (colorForeground != null) 'colorForeground': colorForeground,
        if (currency.isNotEmpty) 'currency': currency,
        if (deadline != null) 'deadline': deadline,
        if (donate != null) 'donate': donate,
        if (fiat != null) 'fiat': fiat,
        if (fragment.isNotEmpty) 'fragment': fragment,
        if (host.isNotEmpty) 'host': host,
        if (hostname.isNotEmpty) 'hostname': hostname,
        if (href.isNotEmpty) 'href': href,
        if (iban != null) 'iban': iban,
        if (item != null) 'item': item,
        if (language != null) 'language': language,
        if (location != null) 'location': location,
        if (message != null) 'message': message,
        if (mode != null) 'mode': mode,
        if (network.isNotEmpty) 'network': network,
        if (organization != null) 'organization': organization,
        if (origin.isNotEmpty) 'origin': origin,
        if (path.isNotEmpty) 'path': path,
        if (port != null) 'port': port,
        if (protocol.isNotEmpty) 'protocol': protocol,
        if (receiverName != null) 'receiverName': receiverName,
        if (recurring != null) 'recurring': recurring,
        if (routingNumber != null) 'routingNumber': routingNumber,
        if (rtl != null) 'rtl': rtl,
        if (search.isNotEmpty) 'search': search,
        if (split != null) 'split': split,
        if (swap != null) 'swap': swap,
        if (value != null) 'value': value,
        if (void_ != null) 'void': void_,
      };
}
