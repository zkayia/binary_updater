
import 'dart:io';

import 'package:binary_updater/src/models/binary_updader_exception.dart';


class BinaryPlatforms {

	final String linux;
	final String macos;
	final String windows;

	BinaryPlatforms({
		this.linux="linux",
		this.macos="macos",
		this.windows="windows",
	});

	String get current {
		if (Platform.isLinux) {
			return linux;
		} else if (Platform.isMacOS) {
			return macos;
		} else if (Platform.isWindows) {
			return windows;
		}
		throw BinaryUpdaterException("failed to resolve current platform");
	}
}
