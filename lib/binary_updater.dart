
/// A library to auto-update a compiled binary from github releases.
library binary_updater;

export 'src/models/binary_architectures.dart' show
	BinaryArchitectures;
export 'src/models/binary_extensions.dart' show
	BinaryExtensions;
export 'src/models/binary_platforms.dart' show
	BinaryPlatforms;
export 'src/models/progress_value.dart' show
	ProgressValue;

export 'src/binary_updater.dart' show
	BinaryUpdater;
