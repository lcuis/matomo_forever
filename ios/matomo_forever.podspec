#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint matomo_forever.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'matomo_forever'
  s.version          = '0.0.1'
  s.license      = { :type => 'MIT' }
  s.summary          = 'A new flutter plugin project.'
  s.description      = 'A perennial Dart plugin to send data to a Matomo server with a Flutter example app.'
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :git => 'https://github.com/lcuis/matomo_forever.git' }
  s.source_files = 'matomo_forever/Sources/matomo_forever/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
