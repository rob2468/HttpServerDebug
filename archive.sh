#!/usr/bin/env bash

# CONFIGURATION_SETTING="Debug"
CONFIGURATION_SETTING="Release"

# Dependencies onfiguration
FMDB_INCLUDE=0
CocoaLumberjack_INCLUDE=1
CocoaAsyncSocket_INCLUDE=1
CocoaHttpServer_INCLUDE=1
ZipArchive_INCLUDE=0

# Constant variables
PROJECT_NAME="HttpServerDebug"
OUTPUT_FOLDER_NAME="output"
BUILD_FOLDER_NAME="build"
IPHONEOS_SDK="iphoneos"
IPHONESIMULATOR_SDK="iphonesimulator"

rm -rf ${OUTPUT_FOLDER_NAME}
mkdir ${OUTPUT_FOLDER_NAME}

# Build Device and Simulator versions
build_combine() {
    SDK=$1
    build_cmd='xcodebuild -project "${PROJECT_NAME}.xcodeproj" -configuration ${CONFIGURATION_SETTING} -sdk ${SDK} ONLY_ACTIVE_ARCH=NO'
    combine_cmd='libtool -static -o "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${SDK}/aggregation.a" "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${SDK}/libHttpServerDebug.a"'

    eval ${build_cmd}' -target "HttpServerDebug"'
    if [[ FMDB_INCLUDE -eq 1 ]]; then
        eval ${build_cmd}' -target "FMDB"'
        combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${SDK}/libFMDB.a"'
    fi
    if [[ CocoaLumberjack_INCLUDE -eq 1 ]]; then
        eval ${build_cmd}' -target "CocoaLumberjack"'
        combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${SDK}/libCocoaLumberjack.a"'
    fi
    if [[ CocoaAsyncSocket_INCLUDE -eq 1 ]]; then
        eval ${build_cmd}' -target "CocoaAsyncSocket"'
        combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${SDK}/libCocoaAsyncSocket.a"'
    fi
    if [[ CocoaHttpServer_INCLUDE -eq 1 ]]; then
        eval ${build_cmd}' -target "CocoaHttpServer"'
        combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${SDK}/libCocoaHttpServer.a"'
    fi
    if [[ ZipArchive_INCLUDE -eq 1 ]]; then
        eval ${build_cmd}' -target "ZipArchive"'
        combine_cmd=${combine_cmd}' "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${SDK}/libZipArchive.a"'
    fi
    eval ${combine_cmd}
}

build_combine ${IPHONEOS_SDK}
build_combine ${IPHONESIMULATOR_SDK}

# Create universal binary file
lipo -create -output "${OUTPUT_FOLDER_NAME}/libHttpServerDebug.a" "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${IPHONEOS_SDK}/aggregation.a" "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${IPHONESIMULATOR_SDK}/aggregation.a"

# Copy header files
cp -R "${BUILD_FOLDER_NAME}/${CONFIGURATION_SETTING}-${IPHONEOS_SDK}/include/" "${OUTPUT_FOLDER_NAME}/Headers/"

# Copy bundle
cp -R "Resources/${PROJECT_NAME}.bundle" "${OUTPUT_FOLDER_NAME}/"

# Copy documents
cp -R "./Documents" "${OUTPUT_FOLDER_NAME}/"
