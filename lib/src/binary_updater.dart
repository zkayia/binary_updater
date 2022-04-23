
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
import 'package:binary_updater/src/models/update_result.dart';
import 'package:version/version.dart';


/// The entry point to the `binary_updater` package.
class BinaryUpdater {

	/// Slug of the repository to fetch updates from.
	/// 
	/// Must be of form `username/reponame`.
	final String repo;
	/// Name of the executable to update.
	/// 
	/// Don't include file extensions.
	/// 
	/// Defaults to the basename of [Platform.resolvedExecutable].
	final String exec;
	/// Path of the executable to update.
	/// 
	/// Prefer absolute paths. Defaults to [Platform.resolvedExecutable].
	final String execPath;
	/// Format of the executable name used in Github releases.
	/// 
	/// The following variables will be automatically resolved:
	/// - `{exec}` value of [exec].
	/// - `{platform}` value of [platforms] for the current os.
	/// - `{arch}` value of [architectures] for the current cpu architecture.
	/// - `{ext}` value of [extensions] for the current os.
	/// 
	/// To escape the resolving, double the curly braces.
	/// `{{arch}} on {platform}` => `{arch} on linux`
	/// 
	/// Unknown values will not be touched.
	/// `{value}_{exec}` => `{value}_awersomecli`
	final String execScheme;
	/// An object containing the executable extension for each platform.
	/// 
	/// Used to resolve [execScheme].
	/// 
	/// See [BinaryExtensions] for more details.
	final BinaryExtensions extensions;
	/// An object containing the names of each platform.
	/// 
	/// Used to resolve [execScheme].
	/// 
	/// See [BinaryPlatforms] for more details.
	final BinaryPlatforms platforms;
	/// An object containing the names and values of each cpu architecture.
	/// 
	/// The name is used to resolve [execScheme].
	/// 
	/// See [BinaryArchitectures] for more details.
	final BinaryArchitectures architectures;
	/// The HttpClient used to make network requests.
	/// 
	/// If not provided, one will be created.
	/// 
	/// Don't forget to use [dispose] to close it.
	final HttpClient httpClient;
	Version? _latest;

	/// The entry point to the `binary_updater` package.
	/// 
	/// **[repo]\:**
	/// Slug of the repository to fetch updates from.
	/// 
	/// Must be of form `username/reponame`.
	/// 
	/// **[exec]\:**
	/// Name of the executable to update.
	/// 
	/// Don't include file extensions.
	/// 
	/// Defaults to the basename of [Platform.resolvedExecutable].
	/// 
	/// **[execPath]\:**
	/// Path of the executable to update.
	/// 
	/// Prefer absolute paths. Defaults to [Platform.resolvedExecutable].
	/// 
	/// **[execScheme]\:**
	/// Format of the executable name used in Github releases.
	/// 
	/// The following variables will be automatically resolved:
	/// - `{exec}` value of [exec].
	/// - `{platform}` value of [platforms] for the current os.
	/// - `{arch}` value of [architectures] for the current cpu architecture.
	/// - `{ext}` value of [extensions] for the current os.
	/// 
	/// To escape the resolving, double the curly braces.
	/// `{{arch}} on {platform}` => `{arch} on linux`
	/// 
	/// Unknown values will not be touched.
	/// `{value}_{exec}` => `{value}_awersomecli`
	/// 
	/// **[extensions]\:**
	/// An object containing the executable extension for each platform.
	/// 
	/// Used to resolve [execScheme].
	/// 
	/// See [BinaryExtensions] for more details.
	/// 
	/// **[platforms]\:**
	/// An object containing the names of each platform.
	/// 
	/// Used to resolve [execScheme].
	/// 
	/// See [BinaryPlatforms] for more details.
	/// 
	/// **[architectures]\:**
	/// An object containing the names and values of each cpu architecture.
	/// 
	/// The name is used to resolve [execScheme].
	/// 
	/// See [BinaryArchitectures] for more details.
	/// 
	/// **[httpClient]\:**
	/// The HttpClient used to make network requests.
	/// 
	/// If not provided, one will be created.
	/// 
	/// Don't forget to use [dispose] to close it.
	BinaryUpdater({
		required this.repo,
		String? exec,
		String? execPath,
		required this.execScheme,
		BinaryExtensions? extensions,
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

	/// Force closes the [httpClient] associated with this instance.
	void dispose() => httpClient.close(force: true);

	/// Get the latest release version.
	/// 
	/// By default, the result from the last call will be used if possible.
	/// 
	/// Set [force] to `true` to fetch a new result.
	/// 
	/// Returns [Version.parse] with the tag name of the latest release.
	Future<Version?> getLatest({bool force=false}) async {
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

	/// Updates [from] the current version [to] the given version.
	/// 
	/// If [to] is null, it'll upgrade to the latest version.
	/// 
	/// By default, the update will cancel (exit code 1) if:
	/// - [from] and [to] are equivalent
	/// - [from] is newer than [to]
	/// 
	/// Set [force] to `true` to upgrade anyways.
	/// 
	/// Use [allowDowngrade] to make downgrades possible while not
	/// updating if [from] and [to] are equivalent.
	/// 
	/// Returns a Stream of [ProgressValue] containing an [UpdateResult].
	Stream<ProgressValue<UpdateResult>> update(
		Version from,
		Version? to,
		{
			bool force=false,
			bool allowDowngrade=false,
		}
	) async* {
		final target = to ?? await getLatest();
		if ((from == target || (from > target && !allowDowngrade)) && !force) {
			yield ProgressValue<UpdateResult>(value: UpdateResult(exitCode: 1));
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
				yield ProgressValue<UpdateResult>(value: UpdateResult(exitCode: 1));
				return;
			}
			yield ProgressValue<UpdateResult>(total: progress.total, progress: progress.progress);
			if (progress.hasValue) {
				httpClient.close();
				final done = ProgressValue<UpdateResult>(
					total: progress.total,
					progress: progress.progress,
				);
				try {
					await File("$execPath.update").writeAsBytes(progress.value!);
					await Process.start(
						Platform.isWindows
							? (await File("$execPath.install.bat").writeAsString(batchInstallScript)).path
							: "sh",
						[
							if (!Platform.isWindows)
								(await File("$execPath.install.sh").writeAsString(bashInstallScript)).path,
							"$pid",
							"$execPath.update",
							execPath,
						],
						runInShell: true,
						mode: ProcessStartMode.detached,
					);
					yield done.copyWith(value: UpdateResult(exitCode: 0));
				} catch (e) {
					yield done.copyWith(value: UpdateResult(exitCode: 3, error: e.toString()));
				}
				return;
			}
		}
		yield ProgressValue<UpdateResult>(value: UpdateResult(exitCode: 4));
	}
}
