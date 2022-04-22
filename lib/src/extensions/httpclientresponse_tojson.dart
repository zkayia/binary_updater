
import 'dart:convert';
import 'dart:io';


extension HttpClientResponseToJson on HttpClientResponse {

	Future<dynamic> toJson() async => jsonDecode(
		await transform(utf8.decoder).join(),
	);
}
