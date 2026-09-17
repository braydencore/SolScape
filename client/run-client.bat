@echo off
setlocal enabledelayedexpansion
REM Launches a downloaded void-client jar with the JVM flag that fixes
REM click-position drift on high-DPI displays (Java scales the window but
REM not input coordinates unless told not to).
cd /d "%~dp0"

set JAR=
for %%f in (void-client*.jar) do set JAR=%%f

if "%JAR%"=="" (
  echo No void-client jar found in this folder.
  echo Download one from https://github.com/GregHib/void-client/releases
  echo and place it in: %cd%
  pause
  exit /b 1
)

java -Dsun.java2d.uiScale=1 -jar "%JAR%"
pause
