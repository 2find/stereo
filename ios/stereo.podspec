Pod::Spec.new do |s|
  s.name             = 'stereo'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter plugin for playing music on iOS and Android.'
  s.description      = <<-DESC
A Flutter plugin for playing music on iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/2find/stereo'
  s.license          = { :file => '../LICENSE' }
  s.author           = { '2find Team' => 'faku99dev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.frameworks = 'AVFoundation', 'MediaPlayer'
  s.ios.frameworks = 'UIKit'
  
  s.ios.deployment_target = '8.0'
end

