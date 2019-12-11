Pod::Spec.new do |s|
  s.name             = 'ID-Card-Camera'
  s.module_name      = 'IDCardCamera'
  s.version          = '1.0.0'
  s.summary          = 'Detects an ID card in a camera view and returns the de-warped image of the ID card.'
  s.homepage         = 'https://github.com/AppliedRecognition'
  s.license          = { :type => 'MIT', :file => 'LICENCE' }
  s.author           = { 'jakubdolejs' => 'jakubdolejs@gmail.com', :tag => "v#{s.version}" }
  s.source           = { :git => 'https://github.com/AppliedRecognition/ID-Card-Camera.git' }
  s.platform	     = :ios, '11.0'
  s.swift_versions   = ["5.0", "5.1"]
  s.source_files = 'IDCardCamera/*.swift'
  s.resources = 'IDCardCamera/*.{xcassets,xib}'
  s.frameworks = 'UIKit', 'Vision', 'Accelerate', 'CoreMedia', 'AVFoundation'
end
