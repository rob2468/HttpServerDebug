#!/usr/bin/env bash

# Dependencies onfiguration
FMDB_INCLUDE=0
CocoaLumberjack_INCLUDE=1
CocoaAsyncSocket_INCLUDE=1
CocoaHttpServer_INCLUDE=1

# Constant variables
PROJECT_NAME="HttpServerDebug"
OUTPUT_FOLDER_NAME="output"
BUILD_FOLDER_NAME="build"
IPHONEOS_SDK="iphoneos"
IPHONESIMULATOR_SDK="iphonesimulator"
LIBRARY_NAME="libHttpServerDebug.a"

rm -rf ${OUTPUT_FOLDER_NAME}
mkdir ${OUTPUT_FOLDER_NAME}

# Build Device and Simulator versions
build_combine() {
  SDK=$1
  build_cmd='xcodebuild -project "${PROJECT_NAME}.xcodeproj" -configuration "Debug" -sdk ${SDK} ONLY_ACTIVE_ARCH=NO'
  combine_cmd='libtool -static -o "${BUILD_FOLDER_NAME}/Debug-${SDK}/aggregation.a" "${BUILD_FOLDER_NAME}/Debug-${SDK}/${LIBRARY_NAME}"'

  eval ${build_cmd}' -target "HttpServerDebug"'
  if [[ FMDB_INCLUDE -eq 1 ]]; then
    eval ${build_cmd}' -target "FMDB"'
    combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/Debug-${SDK}/libFMDB.a"'
  fi
  if [[ CocoaLumberjack_INCLUDE -eq 1 ]]; then
    eval ${build_cmd}' -target "CocoaLumberjack"'
    combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/Debug-${SDK}/libCocoaLumberjack.a"'
  fi
  if [[ CocoaAsyncSocket_INCLUDE -eq 1 ]]; then
    eval ${build_cmd}' -target "CocoaAsyncSocket"'
    combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/Debug-${SDK}/libCocoaAsyncSocket.a"'
  fi
  if [[ CocoaHttpServer_INCLUDE -eq 1 ]]; then
    eval ${build_cmd}' -target "CocoaHttpServer"'
    combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/Debug-${SDK}/libCocoaHttpServer.a"'
  fi

  eval ${combine_cmd}
}

build_combine ${IPHONEOS_SDK}
build_combine ${IPHONESIMULATOR_SDK}

# Create universal binary file
lipo -create -output "${OUTPUT_FOLDER_NAME}/${LIBRARY_NAME}" "${BUILD_FOLDER_NAME}/Debug-${IPHONEOS_SDK}/aggregation.a" "${BUILD_FOLDER_NAME}/Debug-${IPHONESIMULATOR_SDK}/aggregation.a"

# Copy header files
cp -R "${BUILD_FOLDER_NAME}/Debug-${IPHONEOS_SDK}/include/" "${OUTPUT_FOLDER_NAME}/Headers/"

# Copy bundle
cp -R "${PROJECT_NAME}/Resources/${PROJECT_NAME}.bundle" "${OUTPUT_FOLDER_NAME}/"
