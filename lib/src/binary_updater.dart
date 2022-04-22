
import 'dart:io';

import 'package:binary_updater/src/extensions/httpclientresponse_tojson.dart';
import 'package:binary_updater/src/extensions/uri_get.dart';
import 'package:binary_updater/src/helpers/extract_current_exec.dart';
import 'package:binary_updater/src/helpers/get_asset_bytes.dart';
import 'package:binary_updater/src/helpers/resolve_exec_scheme.dart';
import 'package:binary_updater/src/install_scripts.dart';
import 'package:binary_updater/src/models/binary_architectures.dart';
import 'package:binary_updater/src/models/binary_extensions.dart';
import 'package:binary_updater/src/models/binary_platforms.dart';
import 'package:binary_updater/src/models/progress_value.dart';
import 'package:version/version.dart';


class BinaryUpdater {

	final String repo;
	final String exec;
	final String execPath;
	final BinaryExtensions extensions;
	final String execScheme;
	final BinaryPlatforms platforms;
	final BinaryArchitectures architectures;
	final HttpClient httpClient;
	Version? _latest;

	BinaryUpdater({
		required this.repo,
		String? exec,
		String? execPath,
		BinaryExtensions? extensions,
		required this.execScheme,
		BinaryPlatforms? platforms,
		BinaryArchitectures? architectures,
		HttpClient? httpClient,
	}) : 
		exec = exec ?? extractCurrentExec(),
		execPath = execPath ?? Platform.resolvedExecutable,
		extensions = extensions ?? BinaryExtensions(),
		platforms = platforms ?? BinaryPlatforms(),
		architectures = architectures ?? BinaryArchitectures(),
		httpClient = httpClient ?? HttpClient();

	Future<Version?> getLatest([bool force=false]) async {
		if (_latest == null || force) {
			final response = await Uri.https(
				"api.github.com",
				"/repos/$repo/releases/latest",
			).get(httpClient);
			_latest = response == null || response.statusCode >= 400
				? null
				: Version.parse((await response.toJson())["tag_name"]);
		}
		return _latest;
	}

	/// - `0` = Successful
	/// - `1` = No update needed ([from] == [to])
	/// - `2` = No asset found
	/// - `3` = Failed to install update/File system errors
	/// - `4` = Unknown error
	Stream<ProgressValue<int>> update(
		Version from,
		Version? to,
		{
			bool force=false,
			bool allowDowngrade=false,
		}
	) async* {
		final target = to ?? await getLatest();
		if ((from == target || (from > target && !allowDowngrade)) && !force) {
			yield ProgressValue<int>(total: 0, progress: 0, value: 1);
			return;
		}
		final assetBytes = getAssetbytes(
			httpClient,
			repo,
			target.toString(),
			resolveExecScheme(execScheme, {
				"exec": exec,
				"platform": platforms.current,
				"arch": await architectures.current,
				"ext": extensions.current,
			}),
		);
		await for (final progress in assetBytes) {
			if (progress == null) {
				yield ProgressValue<int>(total: 0, progress: 0, value: 1);
				return;
			}
			yield ProgressValue<int>(total: progress.total, progress: progress.progress);
			if (progress.hasValue) {
				httpClient.close();
				final done = ProgressValue<int>(
					total: progress.total,
					progress: progress.progress,
				);
				try {
					await File("$execPath.update").writeAsBytes(progress.value!);
					await Process.start(
						(
							Platform.isWindows
								? await File("$execPath.install.bat").writeAsString(batchInstallScript)
								: await File("$execPath.install.sh").writeAsString(bashInstallScript)
						).path,
						["$pid", "$execPath.update", execPath],
						runInShell: true,
						mode: ProcessStartMode.detached,
					);
					yield done.copyWith(value: 0);
				} catch (e) {
					yield done.copyWith(value: 3);
				}
				return;
			}
		}
		yield ProgressValue(total: 0, progress: 0, value: 4);
	}
}
