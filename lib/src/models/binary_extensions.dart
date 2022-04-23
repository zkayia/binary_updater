
import 'dart:io';

import 'package:binary_updater/src/models/binary_updader_exception.dart';


/// An object containing the executable extension for each platform/operating system.
class BinaryExtensions {

	/// The executable extension under Linux.
	/// 
	/// Defaults to `` (empty string).
	/// 
	/// Used to resolve [BinaryUpdater.execScheme], is the value of `{ext}`
	/// when running on a Linux machine.
	final String linux;
	/// The executable extension under MacOS.
	/// 
	/// Defaults to `` (empty string).
	/// 
	/// Used to resolve [BinaryUpdater.execScheme], is the value of `{ext}`
	/// when running on a MacOS machine.
	final String macos;
	/// The executable extension under Windows.
	/// 
	/// Defaults to `.exe`.
	/// 
	/// Used to resolve [BinaryUpdater.execScheme], is the value of `{ext}`
	/// when running on a Windows machine.
	final String windows;

	/// An object containing the executable extension for each platform/operating system.
	BinaryExtensions({
		this.linux="",
		this.macos="",
		this.windows=".exe",
	});

	/// Get the executable extension for the current platform/operating system.
	/// 
	/// Throws if the current machine running neither Linux, MacOS or Windows.
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
