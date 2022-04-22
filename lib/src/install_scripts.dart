

final batchInstallScript = r"""
@ECHO OFF
TASKKILL /F %1
MOVE /Y %2 %3
DEL "%~f0" & EXIT
""";

final bashInstallScript = r"""
#!/bin/sh
kill -9 $1
mv -f $2 $3
rm $0
""";
