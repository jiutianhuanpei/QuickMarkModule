Pod::Spec.new do |s|
  s.name         = "QuickMarkModule"
  s.version      = "0.0.2"
  s.summary      = "二维码识别模块"
  s.description  = <<-DESC
    二维码识别，识别图片内二维码，文本生成二维码图片
                   DESC
  s.homepage     = "https://github.com/jiutianhuanpei/QuickMarkModule"
  s.license      = "MIT"
  s.author             = { "shenhongbang" => "shenhongbang@163.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/jiutianhuanpei/QuickMarkModule.git", :tag => s.version }
  s.source_files  = "QuickMarkModule/**/*"
  s.resources = ["QuickMarkModule/Image/*.png"]
  s.frameworks = "CoreImage", "CoreMedia", "UIKit", "AVFoundation"
  s.dependency  'HYMediator'
  s.xcconfig = {
    'USER_HEADER_SEARCH_PATHS' => '$(inherited) $(SRCROOT)/HYMediator'
  }
  s.requires_arc = true
end