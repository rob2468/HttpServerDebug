Pod::Spec.new do |s|
  s.name         = "HttpServerDebug"
  s.version      = "0.2.2"
  s.summary      = "HSD offers debug utilities (exploring file system, inspecting " \
                  "database, etc.) with the help of http server."
  s.description  = <<-DESC
                  HSD offers debug utilities (exploring file system, inspecting
                  database, etc.) with the help of http server. HSD will start
                  http server in your device, and you can connect to the server
                  through user agents in the local area network.
                   DESC

  s.homepage     = "https://github.com/rob2468/HttpServerDebug"
  s.screenshots  = "https://user-images.githubusercontent.com/1450652/44396867-ca139000-a570-11e8-9a5c-80da964159ba.gif", \
                  "https://user-images.githubusercontent.com/1450652/44396868-ca139000-a570-11e8-8a05-871de9efeb34.gif", \
                  "https://user-images.githubusercontent.com/1450652/44396869-ca139000-a570-11e8-9018-dc27634ebd9d.gif"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = { "jam.chenjun" => "jam.chenjun@gmail.com" }
  s.social_media_url   = "https://weibo.com/rob2468"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/rob2468/HttpServerDebug.git", :commit => "b71963cf29e8992ebb1ba88ad2457c040b7e3b3c" }
  s.source_files  = "Classes/**/*.{h,m,c}"
  s.public_header_files = "Classes/**/{HSDDelegate,HSDHttpServerControlPannelController,HSDManager,HttpServerDebug}.h"
  s.resources = "Resources/HttpServerDebug.bundle"
  s.frameworks = "UIKit", "Foundation"
  s.requires_arc = true
  s.dependency "FMDB", "~> 2.7"
end
