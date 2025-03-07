/// Exception thrown when there are errors related to Payto URL handling
class PayToException implements Exception {
  /// The error message describing what went wrong
  final String message;

  /// Creates a new PayToException with the specified error message
  PayToException(this.message);

  @override
  String toString() => 'PayToException: $message';
}
