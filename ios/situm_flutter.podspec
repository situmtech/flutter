#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint situm_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'situm_flutter'
  s.version          = '3.3.2'
  s.summary          = 'Situm Flutter plugin.'
  s.description      = <<-DESC
  Situm Flutter plugin.
                       DESC
  s.homepage         = 'https://situm.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Situm Technologies S.L.' => 'situm@situm.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SitumSDK', '~> 3.0.3'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
