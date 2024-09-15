#!/usr/bin/env bash

set -euo pipefail

PICS_URL=${PICS_URL:-""}
FIELDS_URL=${FIELDS_URL:-""}
COVERS_URL=${COVERS_URL:-""}
DISCORD_APP_ID=${DISCORD_APP_ID:-""}
UPDATE_URL=${UPDATE_URL:-""}
ARCH=${ARCH:-"x64"}
TARGET_OS=${TARGET_OS:-""}
BUNDLED_FONT=""
if [[ -f "NotoSansJP-Regular.otf" ]]; then
  BUNDLED_FONT="--bundled-font=NotoSansJP-Regular.otf"
fi

if [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
  if [[ -z "${VS_GEN:-""}" ]]; then
    ./premake5 vs2017 $BUNDLED_FONT --no-core=true --oldwindows=true --sound=sfml --no-joystick=true --pics=\"$PICS_URL\"
    msbuild.exe -m -p:Configuration=$BUILD_CONFIG -p:Platform=Win32 ./build/ygo.sln -t:ygoprodll -verbosity:minimal -p:EchoOff=true
  else
    ./premake5 $VS_GEN $BUNDLED_FONT --no-core=true --sound=sfml --no-joystick=true --pics=\"$PICS_URL\"
    msbuild.exe -m -p:Configuration=$BUILD_CONFIG -p:Platform=Win32 ./build/ygo.sln -t:ygoprodll -verbosity:minimal -p:EchoOff=true
  fi
  exit 0
fi
PREMAKE_FLAGS=""
if [[ -n "${ARCH:-""}" ]]; then
  PREMAKE_FLAGS=" --architecture=$ARCH"
fi
if [[ -n "${TARGET_OS:-""}" ]]; then
  PREMAKE_FLAGS="$PREMAKE_FLAGS --os=$TARGET_OS"
fi
if [[ "TARGET_OS" != "ios" ]]; then
  ./premake5 gmake2 $PREMAKE_FLAGS $BUNDLED_FONT --no-core=true --vcpkg-root=$VCPKG_ROOT --sound=sfml --no-joystick=true --pics=\"$PICS_URL\" --fields=\"$FIELDS_URL\" --covers=\"$COVERS_URL\"
else
  ./premake5 gmake2 $PREMAKE_FLAGS $BUNDLED_FONT --no-core=true --vcpkg-root=$VCPKG_ROOT --sound=sfml --no-joystick=true --pics=\"$PICS_URL\" --fields=\"$FIELDS_URL\" --covers=\"$COVERS_URL\"
fi
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  CFLAGS=-E
  make -Cbuild -j4 config="${BUILD_CONFIG}_${ARCH}" ygoprodll
  ls -lah /home/runner/work/edopro/edopro/

  ls -lah /home/runner/work/edopro/edopro/bin
  ls -lah /home/runner/work/edopro/edopro/build

fi
if [[ "$TRAVIS_OS_NAME" == "macosx" ]]; then
  AR=ar make -Cbuild -j3 config="${BUILD_CONFIG}_${ARCH}" ygoprodll
fi
