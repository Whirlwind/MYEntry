Pod::Spec.new do |s|
  s.name         = "MYEntry"
  s.version      = "1.0"
  s.summary      = "Model of MYFramework."
  s.homepage     = "https://github.com/Whirlwind/MYEntry"
  s.license      = 'MIT'
  s.author       = { "Whirlwind" => "Whirlwindjames@foxmail.com" }
  s.source       = { :git => "https://github.com/Whirlwind/MYEntry.git", :tag=>'v1.0'}
  s.platform     = :ios, '5.0'
  s.source_files = 'MYEntry/MYEntry/Shared/**/*.{h,m}'
#s.resources = "src/*.{broadcast,route}"
  s.frameworks = 'UIKit', 'Foundation'
  # s.prefix_header_file = 'src/MYFramework-Prefix.pch'
  s.requires_arc = true

  s.dependency 'MYFramework'
  # s.dependency 'FMDB'
  # s.dependency 'ASIHTTPRequest/Basic'
  # s.dependency 'JSONAPI'
  # s.dependency 'BHAnalysis'
  # s.dependency 'MTStatusBarOverlay'
end
