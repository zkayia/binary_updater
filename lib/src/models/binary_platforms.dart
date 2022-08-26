
import 'dart:io';

import 'package:binary_updater/src/models/binary_updader_exception.dart';


/// An object containing the names of each platform/operating system.
class BinaryPlatforms {

	/// The name of Linux.
	/// 
	/// Defaults to `linux`.
	/// 
	/// Used to resolve BinaryUpdater.execScheme, is the value of `{platform}`
	/// when running on a Linux machine.
	final String linux;
	/// The name of MacOS.
	/// 
	/// Defaults to `macos`.
	/// 
	/// Used to resolve BinaryUpdater.execScheme, is the value of `{platform}`
	/// when running on a MacOS machine.
	final String macos;
	/// The name of Windows.
	/// 
	/// Defaults to `windows`.
	/// 
	/// Used to resolve BinaryUpdater.execScheme, is the value of `{platform}`
	/// when running on a Windows machine.
	final String windows;

	/// An object containing the names of each platform/operating system.
	BinaryPlatforms({
		this.linux="linux",
		this.macos="macos",
		this.windows="windows",
	});

	/// Get the name of the current platform/operating system.
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
		throw BinaryUpdaterException("failed to resolve current platform");
	}
}
