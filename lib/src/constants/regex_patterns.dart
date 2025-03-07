class RegexPatterns {
  static final accountNumberRegex = RegExp(r'^(\d{7,14})$');
  static final bicRegex =
      RegExp(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$', caseSensitive: false);
  static final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final geoLocationRegex = RegExp(
      r'^(\+|-)?(?:90(?:\.0{1,6})?|(?:[0-9]|[1-8][0-9])(?:\.[0-9]{1,6})?),(\+|-)?(?:180(?:\.0{1,6})?|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:\.[0-9]{1,6})?)$');
  static final ibanRegex =
      RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{12,30}$', caseSensitive: false);
  static final plusCodeRegex =
      RegExp(r'^[23456789CFGHJMPQRVWX]{2,8}\+[23456789CFGHJMPQRVWX]{2,7}$');
  static final routingNumberRegex = RegExp(r'^(\d{9})$');
  static final unixTimestampRegex = RegExp(r'^\d+$');
}
