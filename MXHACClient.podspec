#
# Be sure to run `pod lib lint dsbridge.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MXHACClient'
  s.version          = '1.0.0'
  s.summary          = 'A short description of MXHACClient.'
  s.description      = "MXHACClient"
  s.homepage         = 'https://rd.mxchip.com/mx/mx_sdk_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huafeng' => 'zhanghf@mxchip.com' }
  s.source           = { :git => "https://github.com/MXCHIP/MXFrameworks_IOS.git" }

  s.ios.deployment_target = '10.0'
  s.source_files = 'MXFrameworks/MXHACClient/*'
  s.public_header_files = 'MXFrameworks/MXHACClient/*.h'
  s.vendored_libraries = 'MXFrameworks/MXHACClient/libOpenApiClient.a'
   
end
