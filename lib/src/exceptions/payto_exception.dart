/// Exception thrown when there are errors related to Payto URL handling
class PaytoException implements Exception {
  /// The error message describing what went wrong
  final String message;

  /// Creates a new PaytoException with the specified error message
  PaytoException(this.message);

  @override
  String toString() => 'PaytoException: $message';
}
