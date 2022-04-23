
import 'dart:io';

import 'package:binary_updater/src/models/binary_updader_exception.dart';


/// An object containing the names and values of each cpu architecture.
class BinaryArchitectures {

	/// The name of the x86 cpu architecture.
	/// 
	/// Defaults to `x86`.
	/// 
	/// Used to resolve [BinaryUpdater.execScheme], is the value of `{arch}`
	/// when running on a x86 machine.
	final String x86Name;
	/// The architectures that fall into the x86 category.
	/// 
	/// Defaults to `[x86, x86pc, i386, i686]`.
	/// 
	/// This list is used to resolve the value of `%PROCESSOR_ARCHITECTURE%` on windows
	/// and `uname -m` on unix.
	final List<String> x86Values;
	/// The name of the x64 cpu architecture.
	/// 
	/// Defaults to `x64`.
	/// 
	/// Used to resolve [BinaryUpdater.execScheme], is the value of `{arch}`
	/// when running on a x64 machine.
	final String x64Name;
	/// The architectures that fall into the x64 category.
	/// 
	/// Defaults to `[x64, x86_64, ia32e, ia64, amd64, qemu-x64]`.
	/// 
	/// This list is used to resolve the value of `%PROCESSOR_ARCHITECTURE%` on windows
	/// and `uname -m` on unix.
	final List<String> x64Values;
	/// The name of the arm32 cpu architecture.
	/// 
	/// Defaults to `arm32`.
	/// 
	/// Used to resolve [BinaryUpdater.execScheme], is the value of `{arch}`
	/// when running on a arm32 machine.
	final String arm32Name;
	/// The architectures that fall into the arm32 category.
	/// 
	/// Defaults to `[arm, armv6l, armv7l]`.
	/// 
	/// This list is used to resolve the value of `%PROCESSOR_ARCHITECTURE%` on windows
	/// and `uname -m` on unix.
	final List<String> arm32Values;
	/// The name of the arm64 cpu architecture.
	/// 
	/// Defaults to `arm64`.
	/// 
	/// Used to resolve [BinaryUpdater.execScheme], is the value of `{arch}`
	/// when running on a arm64 machine.
	final String arm64Name;
	/// The architectures that fall into the arm64 category.
	/// 
	/// Defaults to `[arm64, aarch64_be, aarch64, armv8b, armv8l]`.
	/// 
	/// This list is used to resolve the value of `%PROCESSOR_ARCHITECTURE%` on windows
	/// and `uname -m` on unix.
	final List<String> arm64Values;

	/// An object containing the names and values of each cpu architecture.
	BinaryArchitectures({
		this.x86Name="x86",
		this.x86Values=const ["x86", "x86pc", "i386", "i686"],
		this.x64Name="x64",
		this.x64Values=const ["x64", "x86_64", "ia32e", "ia64", "amd64", "qemu-x64"],
		this.arm32Name="arm32",
		this.arm32Values=const ["arm", "armv6l", "armv7l"],
		this.arm64Name="arm64",
		this.arm64Values=const ["arm64", "aarch64_be", "aarch64", "armv8b", "armv8l"],
	});

	/// Get the name of the architecture for the current machine.
	/// 
	/// Throws if:
	/// - `uname -m` errors (on unix).
	/// - the value found is in none of the archValues lists.
	Future<String> get current async {
		if (Platform.isWindows) {
			final winArch = Platform.environment["processor_architecture"]?.toLowerCase();
			if (winArch == null) {
				throw BinaryUpdaterException("failed to resolve current cpu architecture");
			}
			return _resolveArch(winArch);
		}
		final uname = await Process.run("uname", ["--machine"]);
		Process.killPid(uname.pid);
		if (uname.exitCode != 0) {
			throw BinaryUpdaterException(
				"failed to resolve current cpu architecture, uname errored",
			);
		}
		return _resolveArch(
			uname.stdout.toString().toLowerCase().replaceAll(RegExp(r"\s"), ""),
		);
	}

	String _resolveArch(String arch) {
		final archsMap = {
			x86Name: x86Values,
			x64Name: x64Values,
			arm32Name: arm32Values,
			arm64Name: arm64Values,
		};
		for (final entry in archsMap.entries) {
			if (entry.value.contains(arch)) {
				return entry.key;
			}
		}
		throw BinaryUpdaterException("failed to resolve cpu architecture $arch");
	}
}
