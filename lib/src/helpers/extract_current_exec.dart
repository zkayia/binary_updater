
import 'dart:io';


String extractCurrentExec() {
	final execName =
		Uri.file(Platform.executable, windows: Platform.isWindows).pathSegments.last;
	return Platform.isWindows && execName.endsWith(".exe")
		? execName.substring(0, execName.length - 4)
		: execName;
}
