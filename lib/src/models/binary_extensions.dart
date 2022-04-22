
import 'dart:io';

import 'package:binary_updater/src/models/binary_updader_exception.dart';


class BinaryExtensions {

	final String linux;
	final String macos;
	final String windows;

	BinaryExtensions({
		this.linux="",
		this.macos="",
		this.windows=".exe",
	});

	String get current {
		if (Platform.isLinux) {
			return linux;
		} else if (Platform.isMacOS) {
			return macos;
		} else if (Platform.isWindows) {
			return windows;
		}
		throw BinaryUpdaterException(
			"failed to resolve the binary extension for the current platform",
		);
	}
}
