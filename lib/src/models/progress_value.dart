

/// A value with an associated progress.
class ProgressValue<T> {

	/// The total to which the [progress] heads.
	/// 
	/// Defaults to 0.
	final int total;
	/// The current progress.
	/// 
	/// Defaults to 0.
	final int progress;
	/// The value associated with this [ProgressValue].
	/// 
	/// Is null until the progress finishes.
	final T? value;
	
	/// A value with an associated progress.
	ProgressValue({
		this.total=0,
		this.progress=0,
		this.value,
	});

	/// Is the [progress] equal or higher than the [total].
	bool get isDone => progress >= total;
	
	/// Is the [value] defined (!= null).
	bool get hasValue => value != null;

	/// Returns the percentage of the current [progress] out of
	/// the [total].
	num get percentage => 100 * progress / total;

	ProgressValue<T> copyWith({
		int? total,
		int? progress,
		T? value,
	}) => ProgressValue<T>(
		total: total ?? this.total,
		progress: progress ?? this.progress,
		value: value ?? this.value,
	);

	ProgressValue<T> operator +(int number) => copyWith(
		progress: progress + number,
	);

	@override
	String toString() => "Progress<$T>(total: $total, progress: $progress, result: $value)";

	@override
	bool operator ==(Object other) {
		if (identical(this, other)) return true;
		return other is ProgressValue<T> && other.total == total && other.progress == progress && other.value == value;
	}

	@override
	int get hashCode => total.hashCode ^ progress.hashCode ^ value.hashCode;
}
