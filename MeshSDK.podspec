Pod::Spec.new do |spec|

  spec.name         = "MeshSDK"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of MeshSDK."

  spec.description  = "mxchip mesh sdk"
  spec.homepage     = "https://rd.mxchip.com/mx/mx_sdk_ios"

  spec.license      = ""

  spec.author       = { "huafeng" => "zhanghf@mxchip.com" }

  spec.source       = { :git => "https://github.com/MXCHIP/MXFrameworks_IOS.git" }
  
  spec.ios.deployment_target  = '12.0'
  
  spec.static_framework = true
  spec.vendored_frameworks = 'MXFrameworks/MeshSDK.framework'
  
  spec.dependency 'CryptoSwift', '1.4.0'

end
