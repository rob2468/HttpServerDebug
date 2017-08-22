# HttpServerDebug

HttpServerDebug offers debug utilities (exploring file system, inspecting database, etc.) with the help of http server. HttpServerDebug will start http server in your device, and you can connect to the server through user agents.

In the root directory, there is the "archive.sh" script. `cd` to the root directory, then `bash archive.sh`. This script will generate files in the "output" folder in the same directory. The "output" folder contains three kinds of files, headers, library and bundle. These are all files that needed.

You may need add libxml2 to your project after integrating HttpServerDebug. In "Build Phases -> Link Binary With Libraries", add libxml2.

HttpServerDebug utilizes some third party libraries, CocoaAsyncSocket, CocoaLumberjack, CocoaHttpServer and FMDB. "archive.sh" script will compile all source files and integrate all contents in one static library, libHttpServerDebug.a. But sometimes you may want to exclude some third party libraries if your project has already import. You can update "archive.sh". For example, if you want to remove FMDB, set `FMDB_INCLUDE=0`.

```shell
# Dependencies onfiguration
FMDB_INCLUDE=1
CocoaLumberjack_INCLUDE=1
CocoaAsyncSocket_INCLUDE=1
CocoaHttpServer_INCLUDE=1
```

## FAQ

1. Why does Xcode produce dupliate symbol errors. ("duplicate symbol xxx in:/xxx/libHttpServerDebug.a(xxx.o) /xxx/xxx(xxx.o) ld: xxx duplicate symbols for architecture xxx")

When your project contains some same classes, the linker produces these errors.

As HttpServerDebug imports some third party libraries, if your project has already import one, then exclude it in the "archive.sh" as described above.

2. How to link HttpServerDebug in specific configuration?

For example, import HttpServerDebug only in Debug configuration.

- Search HttpServerDebug Headers in Debug configuration.

  * "Build Settings -> Header Search Paths", add header searching paths for Debug configuration.

- Link Binary With Libraries in Debug configuration.

  * "Build Settings -> Other Link Flags", add "-lHttpServerDebug" for Debug configuration.

  * "Build Settings -> Library Search Paths", add libHttpServerDebug.a searching path for Debug configuration.

- Copy Bundle Resources in Debug configuration.

  * Add copy bundle resources script in "Build Phases -> Run Script".

```shell
if [ "${CONFIGURATION}" == "Debug" ]; then
  cp -r "${PROJECT_DIR}/HttpServerDebug.bundle" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"
fi
```
