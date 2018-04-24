# HttpServerDebug (HSD)

## Overview

HSD offers debug utilities (exploring file system, inspecting database, etc.) with the help of http server. HSD will start http server in your device, and you can connect to the server through user agents in the local area network.

## Demo screenshot

![index](http://ozel6a0l7.bkt.clouddn.com/hsd-demo-index.png)

![file explorer](http://ozel6a0l7.bkt.clouddn.com/hsd-demo-file-explorer.png)

![database inspect](http://ozel6a0l7.bkt.clouddn.com/hsd-demo-database-inspect.png)

![view debug](http://ozel6a0l7.bkt.clouddn.com/hsd-demo-view-debug.gif)

![console log](http://ozel6a0l7.bkt.clouddn.com/hsd-demo-console-log.gif)

## Access HSD

As HSD is started as a http server in your device, you can access it just like browsing normal websites in your favorite web browser. HSD also provides some useful server apis, you can get these apis' description from Documents/ Directory.

HSD provides a method to get the address which is the combination of protocol (http), ip address and port number, like "http://x.x.x.x:xxxx". You can provide this information in a custome user interface. Or you can set a static port number, and get ip address from your iOS device's Setting app, then combine all these parts together.

You may feel annoying to access HSD by typing ip addresses. You are able to access HSD with meaningful domain names.

When HSD is started, the builtin bonjour broadcasting of `_http._tcp` type service is also published. You can browse for instances of service type `_http._tcp` in domain `local.`. When you get the instance name, you can lookup the target hostname to contact. In the following example, we use the `dns-sd` tool to browse and lookup the target hostname. As the outputs shown, you can now connect HSD with "chenjundeiPhone-7.local.:5555" instead of something like "http://x.x.x.x:xxxx".

```shell
chenjundeMacBook-Pro:~ chenjun$ dns-sd -B _http
Browsing for _http._tcp
DATE: ---Wed 04 Apr 2018---
10:10:14.738  ...STARTING...
Timestamp     A/R    Flags  if Domain               Service Type         Instance Name
10:10:14.738  Add        2  13 local.               _http._tcp.          陈军的iPhone 7

chenjundeMacBook-Pro:~ chenjun$ dns-sd -L "陈军的iPhone 7" _http
Lookup 陈军的iPhone 7._http._tcp.local
DATE: ---Wed 04 Apr 2018---
10:10:45.715  ...STARTING...
10:10:45.879  陈军的iPhone\0327._http._tcp.local. can be reached at chenjundeiPhone-7.local.:5555 (interface 13)
```

## Packaging

In the root directory, there is the "archive.sh" script. `cd` to the root directory, then `bash archive.sh`. This script will generate files in the "output" folder in the same directory. The "output" folder contains three kinds of files, headers, library and bundle. These are all files that needed.

You may need add libxml2 to your project after integrating HttpServerDebug. In "Build Phases -> Link Binary With Libraries", add libxml2.

## Customized packaging

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

## Acknowledgments

[CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer)

[FLEX](https://github.com/Flipboard/FLEX)
