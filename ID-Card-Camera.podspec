Pod::Spec.new do |s|
  s.name             = 'ID-Card-Camera'
  S.module_name      = 'IDCardCamera'
  s.version          = '1.0.0'
  s.summary          = 'A short description of ID-Card-Camera.'
  s.homepage         = 'https://github.com/AppliedRecognition'
  s.license          = { :type => 'MIT', :file => 'LICENCE' }
  s.author           = { 'jakubdolejs' => 'jakubdolejs@gmail.com' }
  s.source           = { :git => 'https://github.com/AppliedRecognition/ID-Card-Camera.git', :tag => 'v#{s.version}' }
  s.platform	     = :ios, '11.0'
  s.source_files = 'Source/*.swift'
  s.resources = 'Source/*.{xcassets,xib}'
  s.frameworks = 'UIKit', 'Vision', 'Accelerate', 'CoreMedia', 'AVFoundation'
end
