
import 'dart:io';

import 'package:binary_updater/src/extensions/uri_get.dart';
import 'package:binary_updater/src/extensions/httpclientresponse_tojson.dart';
import 'package:binary_updater/src/models/binary_updader_exception.dart';
import 'package:binary_updater/src/models/progress_value.dart';


Stream<ProgressValue<List<int>>?> getAssetbytes(
	HttpClient httpClient,
	String repo,
	String version,
	String asset,
) async* {
	final response = await Uri.https(
		"api.github.com",
		"/repos/zkayia/egsfree/releases/tags/$version",
	).get(httpClient);
	if (response == null || response.statusCode >= 400) {
		throw BinaryUpdaterException("failed to find a release with the tag $version");
	}
	for (final releaseAsset in (await response.toJson())["assets"]) {
		if (releaseAsset["name"] == asset) {
			final assetResponse = await Uri.parse(releaseAsset["browser_download_url"]).get(
				httpClient,
			);
			if (assetResponse == null || assetResponse.statusCode >= 400) {
				throw BinaryUpdaterException(
					"failed to fetch the asset of version $version and name $asset",
				);
			}
			final List<int> bytes = [];
			ProgressValue<List<int>> progress = ProgressValue<List<int>>(
				total: assetResponse.contentLength,
			);
			await for (final data in assetResponse) {
				yield progress;
				bytes.addAll(data);
				progress += data.length;
			}
			yield progress.copyWith(value: bytes);
			return;
		}
	}
	yield null;
	return;
}
