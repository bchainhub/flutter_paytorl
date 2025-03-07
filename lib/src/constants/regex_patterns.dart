/// Regular expression patterns used throughout the package
class RegexPatterns {
  /// Matches account numbers between 7 and 14 digits
  static final RegExp accountNumberRegex = RegExp(r'^(\d{7,14})$');

  /// Matches BIC/SWIFT codes (8 or 11 characters)
  static final RegExp bicRegex = RegExp(
    r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$',
    caseSensitive: false,
  );

  /// Matches valid email addresses
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Matches geographic coordinates (latitude,longitude)
  static final RegExp geoLocationRegex = RegExp(
    r'^(\+|-)?(?:90(?:\.0{1,6})?|(?:[0-9]|[1-8][0-9])(?:\.[0-9]{1,6})?),(\+|-)'
    r'?(?:180(?:\.0{1,6})?|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:\.[0-9]{1,6})?)$',
  );

  /// Matches IBAN numbers (15-34 characters)
  static final RegExp ibanRegex = RegExp(
    r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{12,30}$',
    caseSensitive: false,
  );

  /// Matches Plus Codes (Open Location Code)
  static final RegExp plusCodeRegex = RegExp(
    r'^[23456789CFGHJMPQRVWX]{2,8}\+[23456789CFGHJMPQRVWX]{2,7}$',
  );

  /// Matches 9-digit routing numbers
  static final RegExp routingNumberRegex = RegExp(r'^(\d{9})$');

  /// Matches Unix timestamps (positive integers)
  static final RegExp unixTimestampRegex = RegExp(r'^\d+$');
}
