# Changelog

All notable changes to **SAMobileCapture** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-06

### Added
- Single dynamic `SAMobileCapture.xcframework` distributed via this private
  GitHub repository (CocoaPods + Swift Package Manager).
- Bootstrap target (`SAMobileCaptureBootstrap`) that wires Apple-required
  linker flags and external dependencies on the SPM side.
- Customer-facing installation guide (`README.md`) covering Personal Access
  Token generation, `~/.netrc` setup, and CI/CD secret recipes.

### Changed
- Computer Vision stack upgraded to **OpenCV 4.3.0** (CocoaPods) /
  `yeatse/opencv-spm` 4.13.0+ (SPM). All deprecated OpenCV 3.x C-style
  macros migrated to OpenCV 4.x `cv::` namespace.
- ML Kit stack upgraded to **8.0.0** (CocoaPods) / `d-date/google-mlkit-swiftpm`
  9.0.0-1 (SPM).
- Minimum supported deployment target raised to **iOS 15.6**.

### Removed
- `Lottie-ios` dependency removed entirely. Onboarding animations now play
  via `AVPlayer` with HEVC-with-alpha `.mov` assets, eliminating Lottie
  version conflicts in host applications and reducing binary size.

### Security
- Vendored AFNetworking 4.0.1 source has been renamed to **`SANetworking`**
  (with all `AF*` symbols, notification names, and `com.alamofire.*` string
  literals re-prefixed) to avoid Objective-C class collisions with host
  applications that still ship AFNetworking.
- Removed all references to the private `<netinet6/in6.h>` header so the
  SDK builds cleanly on Xcode 26.4.

### Fixed
- iOS 15+ `UIToolbar` and `UINavigationBar` transparent-background
  regressions resolved via `UIToolbarAppearance` /
  `UINavigationBarAppearance` opaque configuration helpers.
