
import 'dart:io';

import 'package:binary_updater/src/models/binary_updader_exception.dart';


class BinaryArchitectures {

	final String x86Name;
	final List<String> x86Values;
	final String x64Name;
	final List<String> x64Values;
	final String arm32Name;
	final List<String> arm32Values;
	final String arm64Name;
	final List<String> arm64Values;

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
