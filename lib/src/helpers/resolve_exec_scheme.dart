

String resolveExecScheme(String scheme, Map<String, String> schemeMap) {
	String result = scheme;
	for (final variable in schemeMap.entries) {
		result = result
			.replaceAll(
				RegExp("(?<!{){${variable.key}}(?!})"),
				variable.value,
			)
			.replaceAll(
				"{{${variable.key}}}",
				"{${variable.key}}",
			);
	}
	return result;
}
