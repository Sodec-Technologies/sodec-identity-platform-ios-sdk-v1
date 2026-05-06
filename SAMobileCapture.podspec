Pod::Spec.new do |spec|

  spec.name             = 'SAMobileCapture'
  spec.version          = '1.0.0'
  spec.summary          = 'Sodec Identity Platform SDK for iOS (dynamic xcframework).'
  spec.description      = <<-DESC
    Sodec Identity Platform delivers a fast, accessible, App Store-ready
    digital onboarding and KYC stack for iOS, including document capture,
    OCR, face detection, liveness, and electronic ID NFC chip reading.
    The xcframework binary is downloaded from the corresponding GitHub
    Release asset; CocoaPods verifies it against a SHA-256 checksum.
  DESC

  spec.homepage         = 'https://sodec.com'
  spec.license          = { :type => 'Proprietary', :file => 'LICENSE' }
  spec.authors          = { 'Sodec Technologies' => 'support@sodec.com' }

  spec.platform              = :ios
  spec.ios.deployment_target = '15.6'
  spec.swift_version         = '5.9'

  # CocoaPods downloads the xcframework zip directly from the GitHub Release
  # asset and verifies its SHA-256 before unpacking. Because the asset lives
  # in a public GitHub Release, no Personal Access Token is required.
  spec.source = {
    :http   => 'https://github.com/Sodec-Technologies/sodec-identity-platform-ios-sdk-v1/releases/download/1.0.0/SAMobileCapture.xcframework.zip',
    :sha256 => 'a62207168e5b5e464207250600ab3e39eff15635a4284818a8faea4d58f8c5ec'
  }

  # Pre-built dynamic xcframework. Headers are exposed automatically by
  # vendored_frameworks, so source_files / public_header_files are not needed.
  spec.vendored_frameworks = 'SAMobileCapture.xcframework'

  # System frameworks the SDK links against at runtime.
  spec.ios.frameworks = [
    'AVFoundation', 'Accelerate', 'CoreGraphics', 'CoreImage', 'CoreMedia',
    'CoreVideo', 'CoreText', 'Foundation', 'MessageUI', 'MobileCoreServices',
    'OpenGLES', 'QuartzCore', 'Photos', 'ReplayKit', 'UIKit', 'Security',
    'SystemConfiguration', 'Metal'
  ]

  spec.dependency 'GoogleMLKit/TextRecognition', '8.0.0'
  spec.dependency 'GoogleMLKit/FaceDetection',   '8.0.0'
  spec.dependency 'GoogleMLKit/BarcodeScanning', '8.0.0'
  spec.dependency 'TensorFlowLiteSwift',         '2.14.0'
  spec.dependency 'OpenCV',                      '4.3.0'
  spec.dependency 'OpenSSL-Universal',           '3.3.2000'

  # Weakly link NFC + Crypto frameworks so hosts without NFC / Secure Enclave
  # support do not crash at launch.
  spec.xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC -all_load -framework CoreLocation -framework CoreML -weak_framework CoreNFC -weak_framework CryptoKit -weak_framework CryptoTokenKit'
  }

  # MNN / ncnn / openmp are statically embedded inside the xcframework binary,
  # so they MUST NOT be referenced from -framework here.
  spec.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC -l"c++" -l"sqlite3" -l"z" ' \
      '-framework AVFoundation -framework Accelerate -framework CoreGraphics ' \
      '-framework CoreImage -framework CoreMedia -framework CoreVideo ' \
      '-framework CoreText -weak_framework CoreNFC -weak_framework CryptoKit ' \
      '-weak_framework CryptoTokenKit -framework Foundation ' \
      '-framework GTMSessionFetcher -framework GoogleDataTransport ' \
      '-framework GoogleToolboxForMac -framework MLImage ' \
      '-framework MLKitBarcodeScanning -framework MLKitCommon ' \
      '-framework MLKitFaceDetection -framework MLKitTextRecognition ' \
      '-framework MLKitVision -framework OpenSSL -framework TensorFlowLiteC ' \
      '-framework nanopb -framework opencv2 -framework MessageUI ' \
      '-framework MobileCoreServices -framework OpenGLES -framework QuartzCore ' \
      '-framework Photos -framework ReplayKit -framework UIKit ' \
      '-framework Security -framework SystemConfiguration -framework Metal',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*][config=Debug]'   => 'arm64',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*][config=Release]' => 'arm64',
  }

end
