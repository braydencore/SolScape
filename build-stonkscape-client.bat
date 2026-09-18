@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ===============================================
echo  Stonkscape client builder
echo ===============================================
echo.

echo [1/5] Pulling latest changes...
git pull
git submodule update --init --recursive
if errorlevel 1 (
    echo Failed to update the repo. Fix any git errors above and re-run this script.
    pause
    exit /b 1
)

echo.
echo [2/5] Building the client (Java 8 will be auto-downloaded by Gradle the
echo        first time if you don't already have it - this can take a while).
cd client-src
call gradlew.bat :client:shadowJar
if errorlevel 1 (
    echo Build failed. See errors above.
    pause
    exit /b 1
)
cd ..

echo.
echo [3/5] Copying the built jar into client\...
set CLIENT_JAR=
for %%f in (client-src\client\build\libs\void-client*.jar) do set CLIENT_JAR=%%~nxf
if "%CLIENT_JAR%"=="" (
    echo Could not find the built jar. Something went wrong with the build.
    pause
    exit /b 1
)
copy /Y "client-src\client\build\libs\%CLIENT_JAR%" "client\%CLIENT_JAR%" >nul

echo.
echo [4/5] Packaging Stonkscape.exe (this replaces any previous build)...
if exist Stonkscape rmdir /s /q Stonkscape
jpackage --input client-src\client\build\libs --main-jar "%CLIENT_JAR%" ^
  --name Stonkscape --icon client-src\client\resources\icon.ico ^
  --java-options "-Dsun.java2d.uiScale=1" --type app-image
if errorlevel 1 (
    echo.
    echo jpackage failed. Make sure you have a JDK 14+ installed with jpackage
    echo on your PATH ^(run "jpackage --version" to check^), then re-run this script.
    pause
    exit /b 1
)

echo.
echo [5/5] Creating a desktop shortcut...
powershell -NoProfile -Command ^
  "$s = (New-Object -COM WScript.Shell).CreateShortcut(\"$env:USERPROFILE\Desktop\Stonkscape.lnk\"); ^
   $s.TargetPath = '%cd%\Stonkscape\Stonkscape.exe'; ^
   $s.IconLocation = '%cd%\Stonkscape\Stonkscape.exe'; ^
   $s.Save()"

echo.
echo ===============================================
echo  Done! A "Stonkscape" shortcut is now on your
echo  Desktop - double-click it to play.
echo ===============================================
pause
