Pod::Spec.new do |s|
  s.name             = 'ID-Card-Camera'
  s.module_name      = 'IDCardCamera'
  s.version          = '1.4.2'
  s.summary          = 'Detects an ID card in a camera view and returns the de-warped image of the ID card.'
  s.homepage         = 'https://github.com/AppliedRecognition'
  s.license          = { :type => 'MIT', :file => 'LICENCE' }
  s.author           = { 'jakubdolejs' => 'jakubdolejs@gmail.com' }
  s.source           = { :git => 'https://github.com/AppliedRecognition/ID-Card-Camera.git', :tag => "v#{s.version}" }
  s.platform	     = :ios, '11.0'
  s.swift_version    = '5'
  s.source_files = 'Sources/IDCardCamera*.swift'
  s.exclude_files = [ 'Sources/BundleHelperSPM.swift' ]
  s.resource = 'Sources/IDCardCamera/Resources/*.{xcassets,xib}'
  s.resource_bundle = { 'IDCardCameraResources' => 'Sources/IDCardCamera/Resources/*.{xcassets,xib}' }
  s.frameworks = 'UIKit', 'Vision', 'Accelerate', 'CoreMedia', 'AVFoundation'
  s.app_spec do |app|
    app.source_files = 'Sources/TestApp/*.swift'
    app.resource = 'Sources/TestApp/**/*.{xib,xcassets}'
    app.resource_bundle = { 'IDCardCameraTestApp' => 'Sources/TestApp/**/*.{xib,xcassets}' }
  end
end
