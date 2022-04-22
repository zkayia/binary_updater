

class UpdateResult {

	/// - `0` = Success
	/// - `1` = No update needed
	/// - `2` = No release binary found
	/// - `3` = Failed to install update/File system errors
	/// - `4` = Unknown error
	final int exitCode;
	final String? _error;
	
	UpdateResult({
		required this.exitCode,
		String? error,
	}) : _error = error;

	String get error => _error ?? message;
	
	bool get hasError => exitCode != 0;

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
