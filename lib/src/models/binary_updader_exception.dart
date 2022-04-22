

class BinaryUpdaterException implements Exception {

	final String message;

	BinaryUpdaterException(this.message) : super();

	@override
  String toString() => "BinaryUpdaterException: $message";
}
