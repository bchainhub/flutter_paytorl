class PayToException implements Exception {
  final String message;

  PayToException(this.message);

  @override
  String toString() => 'PayToException: $message';
}
