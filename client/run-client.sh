#!/usr/bin/env bash
# Launches a downloaded void-client jar with the JVM flag that fixes
# click-position drift on high-DPI displays (Java scales the window but not
# input coordinates unless told not to).
cd "$(dirname "$0")"

JAR=$(ls void-client*.jar 2>/dev/null | head -n1)
if [ -z "$JAR" ]; then
  echo "No void-client jar found in this folder."
  echo "Download one from https://github.com/GregHib/void-client/releases"
  echo "and place it in: $(pwd)"
  exit 1
fi

java -Dsun.java2d.uiScale=1 -jar "$JAR"
