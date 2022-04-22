

class ProgressValue<T> {

	final int total;
	final int progress;
	final T? value;
	
	ProgressValue({
		required this.total,
		required this.progress,
		this.value,
	});

	bool get isDone => progress >= total;
	
	bool get hasValue => value != null;

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
