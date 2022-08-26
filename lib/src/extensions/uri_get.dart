
import 'dart:io';


extension UriGet on Uri {

	Future<HttpClientResponse?> get(HttpClient httpClient) async {
		try {
			final request = await httpClient.getUrl(this);
			return request.close();
		} on Exception {
			return null;
		}
	}
}
