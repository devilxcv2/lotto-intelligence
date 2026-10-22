#!/usr/bin/env bash
# tools/environment_check.sh
set -u
echo "uname: $(uname -a)"
flutter --version
java -version
echo "ANDROID_HOME=${ANDROID_HOME:-}"
echo "ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-}"
flutter doctor
