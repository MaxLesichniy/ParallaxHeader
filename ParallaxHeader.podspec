Pod::Spec.new do |s|
  s.name         = "ParallaxHeader"
  s.version      = "3.0.0"
  s.summary      = "Simple way to add parallax header to scrollView/tableView"
  s.description  = "The ParallaxHeader allows to add parallax header to UIScrollView and it's subclasses within UIScrollView extension"
  s.homepage     = "https://github.com/romansorochak"
  s.license      = "MIT"
  s.author             = { "Roman Sorochak" => "roman.sorochak@gmail.com" }
  s.platform     = :ios, "11.0"
  s.swift_version = '5.0'
  s.ios.deployment_target = "11.0"
  s.tvos.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/romansorochak/ParallaxHeader.git", :tag => s.version }
  s.source_files  = "ParallaxHeader/*.swift"
end
