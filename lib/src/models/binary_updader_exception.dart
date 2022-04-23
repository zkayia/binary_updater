

/// When something goes wrong in the `binary_updater` package.
class BinaryUpdaterException implements Exception {

	/// The message of this exception.
	final String message;

	BinaryUpdaterException(this.message) : super();

	@override
  String toString() => "BinaryUpdaterException: $message";
}
