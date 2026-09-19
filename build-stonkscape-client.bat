@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ===============================================
echo  Stonkscape client builder
echo ===============================================
echo.

echo [1/4] Pulling latest changes...
git pull
git submodule update --init --recursive
if errorlevel 1 (
    echo Failed to update the repo. Fix any git errors above and re-run this script.
    pause
    exit /b 1
)

echo.
echo [2/4] Building the client (Java 8 will be auto-downloaded by Gradle the
echo        first time if you don't already have it - this can take a while).
rem This project's build tooling doesn't support very new Java versions yet,
rem so find a separately-installed Java 21 to run Gradle itself with (this
rem does NOT affect your main Java install or the server, which stay as-is).
set GRADLE_JAVA21=
for /d %%d in ("C:\Program Files\Eclipse Adoptium\jdk-21*") do set GRADLE_JAVA21=%%d
if "%GRADLE_JAVA21%"=="" (
    echo.
    echo Could not find a Java 21 install needed to run this build ^(your main
    echo Java is newer than this old project's tooling supports^).
    echo Install it from: https://adoptium.net/temurin/releases/?version=21
    echo then re-run this script.
    pause
    exit /b 1
)
set JAVA_HOME=%GRADLE_JAVA21%
cd client-src
call gradlew.bat :client:shadowJar
if errorlevel 1 (
    echo Build failed. See errors above.
    pause
    exit /b 1
)
cd ..

echo.
echo [3/4] Copying the built jar into client\...
set CLIENT_JAR=
for %%f in (client-src\client\build\libs\void-client*.jar) do set CLIENT_JAR=%%~nxf
if "%CLIENT_JAR%"=="" (
    echo Could not find the built jar. Something went wrong with the build.
    pause
    exit /b 1
)
copy /Y "client-src\client\build\libs\%CLIENT_JAR%" "client\%CLIENT_JAR%" >nul

echo.
echo [4/4] Building the Stonkscape installer (.exe)...
echo        This needs the WiX Toolset installed - see
echo        https://github.com/wixtoolset/wix3/releases if this step fails.
if exist dist rmdir /s /q dist
jpackage --input client-src\client\build\libs --main-jar "%CLIENT_JAR%" ^
  --name Stonkscape --icon client-src\client\resources\icon.ico ^
  --java-options "-Dsun.java2d.uiScale=1" --type exe --win-shortcut ^
  --win-menu --dest dist --app-version 1.0.0
if errorlevel 1 (
    echo.
    echo jpackage failed. Common causes:
    echo  - WiX Toolset not installed: https://github.com/wixtoolset/wix3/releases
    echo  - No JDK 14+ with jpackage on your PATH ^(run "jpackage --version" to check^)
    pause
    exit /b 1
)

echo.
echo ===============================================
echo  Done! Your installer is at:
echo    dist\Stonkscape-1.0.0.exe
echo  This is the ONE file to give to players - they
echo  just run it and it installs the game with a
echo  Start Menu / Desktop shortcut, ready to play.
echo ===============================================
pause
