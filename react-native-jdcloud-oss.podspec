require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name          = package['name']
  s.version       = package['version']
  s.summary       = package['description']
  s.author        = { 'Yudong Bai' => 'summer88123@163.com' }
  s.license       = package['license']
  s.homepage      = package['homepage']
  s.source        = { :git => 'https://github.com/hecom-rn/react-native-jdcloud-oss.git' }
  s.platform      = :ios, '9.0'
  s.source_files  = 'ios/**/*'
  s.framework     = 'Photos', 'MobileCoreServices'
  s.xcconfig      = {
    'OTHER_LDFLAGS' => '-ObjC',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  s.dependency 'React'
end
