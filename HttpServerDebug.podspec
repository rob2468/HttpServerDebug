Pod::Spec.new do |s|
  s.name         = "HttpServerDebug"
  s.version      = "0.1"
  s.summary      = "HSD offers debug utilities (exploring file system, inspecting " \
                  "database, etc.) with the help of http server."
  s.description  = <<-DESC
                  HSD offers debug utilities (exploring file system, inspecting 
                  database, etc.) with the help of http server. HSD will start 
                  http server in your device, and you can connect to the server 
                  through user agents in the local area network.
                   DESC

  s.homepage     = "https://github.com/rob2468/HttpServerDebug"
  s.screenshots  = "http://ozel6a0l7.bkt.clouddn.com/hsd-demo-index.png", \
                  "http://ozel6a0l7.bkt.clouddn.com/hsd-demo-file-explorer.png", \
                  "http://ozel6a0l7.bkt.clouddn.com/hsd-demo-database-inspect.png", \
                  "http://ozel6a0l7.bkt.clouddn.com/hsd-demo-view-debug.gif", \
                  "http://ozel6a0l7.bkt.clouddn.com/hsd-demo-console-log.gif"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = { "jam.chenjun" => "jam.chenjun@gmail.com" }
  s.social_media_url   = "https://weibo.com/rob2468"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/rob2468/HttpServerDebug.git", :tag => s.version }
  s.source_files  = "Classes/**/*.{h,m}"
  s.public_header_files = "Classes/**/{HSDDelegate,HSDHttpServerControlPannelController,HSDManager,HttpServerDebug}.h"
  s.resources = "Resources/HttpServerDebug.bundle"
  s.frameworks = "UIKit", "Foundation"
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
  s.requires_arc = true
  s.dependency "CocoaHTTPServer", "~> 2.3"
  s.dependency "FMDB", "~> 2.7"
  s.dependency "SSZipArchive", "~> 2.1"
end
