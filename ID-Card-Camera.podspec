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
  s.source_files = 'IDCardCamera/*.swift'
  s.resource = 'IDCardCamera/*.{xcassets,xib}'
  s.resource_bundle = { 'IDCardCamera' => 'IDCardCamera/*.{xcassets,xib}' }
  s.frameworks = 'UIKit', 'Vision', 'Accelerate', 'CoreMedia', 'AVFoundation'
  s.app_spec do |app|
    app.source_files = 'TestApp/*.swift'
    app.resource = 'TestApp/**/*.{xib,xcassets}'
    app.resource_bundle = { 'IDCardCameraTestApp' => 'TestApp/**/*.{xib,xcassets}' }
  end
end
