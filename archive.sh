#!/usr/bin/env bash
PROJECT_NAME="HttpServerDebug"
OUTPUT_FOLDER_NAME="output"
BUILD_FOLDER_NAME="build"
IPHONEOS_FOLDER_NAME="Debug-iphoneos"
IPHONESIMULATOR_FOLDER_NAME="Debug-iphonesimulator"
LIBRARY_NAME="libHttpServerDebug.a"

rm -rf ${OUTPUT_FOLDER_NAME}
mkdir ${OUTPUT_FOLDER_NAME}

# Build Device and Simulator versions
xcodebuild -project "${PROJECT_NAME}.xcodeproj" -target "FMDB" -target "HttpServerDebug" -configuration "Debug" -sdk iphoneos ONLY_ACTIVE_ARCH=NO
xcodebuild -project "${PROJECT_NAME}.xcodeproj" -target "FMDB" -target "HttpServerDebug" -configuration "Debug" -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO

# Create universal binary file
lipo -create -output "${OUTPUT_FOLDER_NAME}/${LIBRARY_NAME}" "${BUILD_FOLDER_NAME}/${IPHONEOS_FOLDER_NAME}/${LIBRARY_NAME}" "${BUILD_FOLDER_NAME}/${IPHONESIMULATOR_FOLDER_NAME}/${LIBRARY_NAME}"

# Copy header files
cp -R "${BUILD_FOLDER_NAME}/${IPHONEOS_FOLDER_NAME}/include/" "${OUTPUT_FOLDER_NAME}/Headers/"

# Copy bundle
cp -R "${PROJECT_NAME}/Resources/${PROJECT_NAME}.bundle" "${OUTPUT_FOLDER_NAME}/"
