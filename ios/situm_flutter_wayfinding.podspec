#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint situm_flutter_wayfinding.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'situm_flutter_wayfinding'
  s.version          = '0.0.12'
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
  s.dependency 'SitumSDK', '~> 2.59.0'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
