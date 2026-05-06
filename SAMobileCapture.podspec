Pod::Spec.new do |spec|

  spec.name             = 'SAMobileCapture'
  spec.version          = '1.0.6'
  spec.summary          = 'Sodec Identity Platform SDK for iOS.'
  spec.description      = <<-DESC
    Sodec Identity Platform delivers a fast, accessible, App Store-ready
    digital onboarding and KYC stack for iOS, including document capture,
    OCR, face detection, liveness, and electronic ID NFC chip reading.

    Starting with 1.0.6, the xcframework ships as a "static-inside-dynamic"
    binary: every ML Kit, TensorFlow Lite, OpenCV, and Google Promises /
    Utilities dependency is statically embedded inside the SDK at build
    time. The host application no longer needs to declare these as
    transitive pods, no longer needs `-ObjC -all_load`, and no longer
    suffers from `dyld: Library not loaded` runtime crashes when
    integrated via Swift Package Manager.

    The xcframework binary is downloaded from the corresponding GitHub
    Release asset and verified against a SHA-256 checksum on every install.
  DESC

  spec.homepage         = 'https://sodec.com'
  spec.license          = { :type => 'Proprietary', :file => 'LICENSE' }
  spec.authors          = { 'Sodec Technologies' => 'support@sodec.com' }

  spec.platform              = :ios
  spec.ios.deployment_target = '15.6'
  spec.swift_version         = '5.9'

  # CocoaPods downloads the xcframework zip directly from the public GitHub
  # Release asset and verifies its SHA-256 before unpacking. No Personal
  # Access Token is required.
  spec.source = {
    :http   => 'https://github.com/Sodec-Technologies/sodec-identity-platform-ios-sdk-v1/releases/download/1.0.6/SAMobileCapture.xcframework.zip',
    :sha256 => '2e7725c547a2f2b5d99ac9323c766c7ef812235097861d6dfb299c9446a0b685'
  }

  # Pre-built xcframework (dynamic outer shell, statically embedded
  # transitive deps). Headers and resource bundles are exposed
  # automatically by vendored_frameworks.
  spec.vendored_frameworks = 'SAMobileCapture.xcframework'

  # System frameworks the SDK links against at runtime. ML Kit, TFLite,
  # OpenCV, FBLPromises, GTMSessionFetcher, GoogleDataTransport,
  # GoogleToolboxForMac, GoogleUtilities, and nanopb are all statically
  # embedded inside the binary, so they MUST NOT be referenced here.
  spec.ios.frameworks = [
    'AVFoundation', 'Accelerate', 'CoreGraphics', 'CoreImage', 'CoreLocation',
    'CoreMedia', 'CoreML', 'CoreText', 'CoreVideo', 'Foundation', 'MessageUI',
    'Metal', 'MobileCoreServices', 'OpenGLES', 'Photos', 'QuartzCore',
    'ReplayKit', 'Security', 'SystemConfiguration', 'UIKit'
  ]

  # OpenSSL is the only external dynamic dependency that survives the
  # static embedding pass: the upstream pod ships a pre-built dynamic
  # xcframework, so it cannot be statically merged.
  spec.dependency 'OpenSSL-Universal', '3.3.2000'

  # Weakly link NFC and CryptoKit / CryptoTokenKit so applications running
  # on devices without these capabilities do not crash at launch.
  spec.xcconfig = {
    'OTHER_LDFLAGS' => '-weak_framework CoreNFC -weak_framework CryptoKit -weak_framework CryptoTokenKit'
  }

  # Apple Silicon simulator slice is not yet shipped (ML Kit limitation).
  # Apple Silicon hosts must build simulator targets under Rosetta 2.
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*][config=Debug]'   => 'arm64',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*][config=Release]' => 'arm64'
  }

end
