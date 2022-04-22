

String resolveExecScheme(String scheme, Map<String, String> schemeMap) => 
	scheme.replaceAllMapped(
		RegExp(r"(?<!{){(\w+)}(?!})"),
		(match) => schemeMap[match.group(1)] ?? "",
	);
