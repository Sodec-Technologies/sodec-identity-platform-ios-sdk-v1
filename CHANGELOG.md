# Changelog

All notable changes to **SAMobileCapture** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.7] - 2026-05-06

### Fixed
- **`Unable to find module dependency: 'TensorFlowLite'`** Swift compiler
  error that SPM consumers hit when the host application's target had to
  type-check `import SAMobileCapture`. The SDK's three internal Swift
  files that drive the on-device TFLite interpreters
  (`SADocumentAligner.swift`, `SAPhotocopyDetector.swift`,
  `ModelDataHandler.swift`) now use `@_implementationOnly import
  TensorFlowLite`, so the public Swift module interface no longer leaks
  the `TensorFlowLite` dependency to consumers.

## [1.0.6] - 2026-05-06

### Changed
- **Distribution model rebuilt as "static-inside-dynamic".** The
  xcframework binary is still a dynamic framework (so it embeds into the
  host application as a regular `.framework`), but every ML Kit, TensorFlow
  Lite, OpenCV, FBLPromises, GTMSessionFetcher, GoogleDataTransport,
  GoogleToolboxForMac, GoogleUtilities, and nanopb dependency is now
  statically embedded inside the binary at SDK build time. Only OpenSSL
  remains as an external dynamic dependency (the upstream package ships
  pre-built dynamic xcframeworks that cannot be statically merged).

### Fixed
- **`dyld: Library not loaded: @rpath/FBLPromises.framework/...`** runtime
  crash when the SDK was integrated via Swift Package Manager. SPM did
  not embed the Google transitive frameworks because it resolved them as
  static object files from the source packages, while the previously
  shipped dynamic-linkage binary expected them as `@rpath` dynamic
  frameworks. The new build pattern removes those `@rpath` references
  entirely; only `OpenSSL` and `SAMobileCapture` itself remain.

### Removed
- Customer-side requirement to declare `MLKit*`, `TensorFlowLiteSwift`,
  `opencv-spm`, and `TensorFlowLiteSwift branch: "master"` SPM packages.
- Customer-side requirement to add `-ObjC -all_load` to *Other Linker
  Flags*. ML Kit category dispatch now resolves entirely inside the SDK
  binary at SDK build time.
- Transitive CocoaPods dependencies on `GoogleMLKit/*`,
  `TensorFlowLiteSwift`, and `OpenCV`. Hosts only need `OpenSSL-Universal`.

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
