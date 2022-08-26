

final batchInstallScript = """
@ECHO OFF
TASKKILL /F %1
MOVE /Y %2 %3
DEL "%~f0" & EXIT
""";

final bashInstallScript = r"""
#!/bin/sh
{
kill -9 $1 && wait $1
mv -f $2 $3
rm -rf $0
} >/dev/null 2>&1
""";
