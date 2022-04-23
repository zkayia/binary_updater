

/// An object representing the result of calling [BinaryUpdater.update()]
class UpdateResult {

	/// The exit code of the update method.
	/// 
	/// - `0` Success.
	/// - `1` No update needed.
	/// - `2` No release binary found.
	/// - `3` Update install failed/File system errors.
	/// - `4` Unknown error.
	final int exitCode;
	final String? _error;
	
	/// An object representing the result of calling [BinaryUpdater.update()]
	/// 
	/// **[exitCode]\:**
	/// The exit code of the update method.
	/// 
	/// - `0` Success.
	/// - `1` No update needed.
	/// - `2` No release binary found.
	/// - `3` Update install failed/File system errors.
	/// - `4` Unknown error.
	/// 
	/// **[error]\:**
	/// The message of the [Exception] object.
	/// 
	/// If no [Exception] message was passsed, returns [message].
	UpdateResult({
		required this.exitCode,
		String? error,
	}) : _error = error;

	/// The message of the [Exception] object.
	/// 
	/// If no [Exception] message was passsed, returns [message].
	String get error => _error ?? message;
	
	/// Is the exit code not 0.
	bool get hasError => exitCode != 0;

	/// The message associated with the current [exitCode].
	/// 
	/// Differs from [error] as this is hard-coded.
	/// 
	/// The values are:
	/// - `0` => `Success`
	/// - `1` => `Update isnt't needed`
	/// - `2` => `Could not find a release binary`
	/// - `3` => `Failed to install the update to the file system`
	/// - `4` => `Unknown error`
	String get message => [
		"Success",
		"Update isnt't needed",
		"Could not find a release binary",
		"Failed to install the update to the file system",
		"Unknown error",
	].elementAt(exitCode);

	UpdateResult copyWith({
		int? exitCode,
		String? error,
	}) => UpdateResult(
		exitCode: exitCode ?? this.exitCode,
		error: error ?? this.error,
	);

	@override
	String toString() => "UpdateResult(exitCode: $exitCode, error: $error, message: $message)";

	@override
	bool operator ==(Object other) {
		if (identical(this, other)) return true;
		return other is UpdateResult && other.exitCode == exitCode && other.error == error && other.message == message;
	}

	@override
	int get hashCode => exitCode.hashCode ^ error.hashCode ^ message.hashCode;
}
