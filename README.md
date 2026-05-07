# Sodec Identity Platform SDK for iOS

[![iOS 15.6+](https://img.shields.io/badge/iOS-15.6%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)](#swift-package-manager)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-supported-brightgreen.svg)](#cocoapods)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

`SAMobileCapture` is the iOS client SDK of the **Sodec Identity Platform**.
It provides a production-ready toolkit for digital onboarding and KYC
flows: document capture and quality validation, on-device OCR, face
detection and liveness, photocopy/screen-replay attack detection, and
electronic identity card NFC chip reading.

This single repository serves both **Swift Package Manager** and
**CocoaPods**. The xcframework binary is shipped as a GitHub Release
asset and verified against a SHA-256 checksum on every install.

---

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
- [Resource bundles](#resource-bundles)
- [Continuous integration](#continuous-integration)
- [Minimal usage example](#minimal-usage-example)
- [Required `Info.plist` keys](#required-infoplist-keys)
- [Versioning and support](#versioning-and-support)

---

## Requirements

| Requirement                | Minimum |
| -------------------------- | ------- |
| Xcode                      | 15.0    |
| iOS deployment target      | 15.6    |
| Swift toolchain            | 5.9     |
| CocoaPods (CocoaPods only) | 1.10    |

Supported architectures:

- Device: `arm64`
- Simulator: `x86_64` (Intel and Rosetta 2 on Apple Silicon)

> **Note:** Apple Silicon simulator (`arm64-simulator`) slices are not
> currently shipped. Build your simulator targets under Rosetta 2 or use
> an Intel-based macOS runner.

---

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/Sodec-Technologies/sodec-identity-platform-ios-sdk-v1.git",
        exact: "1.0.9"
    ),

    // Required workaround for Apple SPM's "stable depends on unstable"
    // resolver rule. The kewlbear/TensorFlowLiteSwift 2.14.0 manifest pins
    // its TensorFlowLiteC dependency to `branch: "master"`. Apple SPM
    // refuses to satisfy that branch requirement when the consuming root
    // requirement is a stable version. Declaring TensorFlowLiteSwift here
    // by branch promotes the entire chain to a branch-based requirement
    // that the resolver can satisfy.
    .package(
        url: "https://github.com/kewlbear/TensorFlowLiteSwift.git",
        branch: "master"
    )
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "SAMobileCapture",
                     package: "sodec-identity-platform-ios-sdk-v1")
        ]
    )
]
```

Or, in Xcode: **File → Add Package Dependencies… →** paste the repository
URL and pick version `1.0.9` or *Up to Next Major*. You must also add
`https://github.com/kewlbear/TensorFlowLiteSwift.git` as a separate
package dependency, choosing the *Branch* dependency rule with branch
`master` (see explanation above).

Resolve dependencies:

```bash
xcodebuild -resolvePackageDependencies
```

#### Required linker flags (SPM consumers)

Add these two flags to your **application target's** Build Settings.
This is the standard ML Kit-on-SPM requirement — every SDK that bundles
ML Kit (Firebase, Google Maps, MLKit-SPM wrapper, etc.) needs them, and
Apple Swift Package Manager does not let vendored packages propagate
them automatically.

`Build Settings → Linking - General → Other Linker Flags`:

```
-ObjC
-all_load
```

Or as `xcconfig`:

```
OTHER_LDFLAGS = $(inherited) -ObjC -all_load
```

Why these flags are needed:

| Flag         | Reason                                                                                |
| ------------ | ------------------------------------------------------------------------------------- |
| `-ObjC`      | Loads Objective-C categories from the ML Kit static libraries vendored inside the SDK |
| `-all_load`  | Forces every static library symbol to be loaded so ML Kit category dispatch works     |

If you forget either flag, the application will compile but will throw
`unrecognized selector` exceptions at runtime when ML Kit categories
are dispatched.

#### ML Kit resource bundles

Starting with `1.0.9`, `GoogleMVFaceDetectorResources.bundle` and
`LatinOCRResources.bundle` are embedded inside `SAMobileCapture.framework`,
so host applications do not need to copy these bundles manually for SDK
flows. If the host app uses the `google-mlkit-swiftpm` products directly
outside SAMobileCapture, follow that package's own bundle requirements.

CoreLocation, CoreML, weak-linked CoreNFC / CryptoKit / CryptoTokenKit, and
the required ML Kit resource bundles are already wired into the framework
binary and package manifest.

> **Apple Silicon Macs:** ML Kit ships only Intel simulator slices.
> Simulator builds on Apple Silicon must run under Rosetta 2, or you can
> exclude `arm64` from your simulator architectures. Device builds work
> natively on all Macs.

### CocoaPods

Add the following to your `Podfile`:

```ruby
platform :ios, '15.6'
use_frameworks!

target 'MyApp' do
  pod 'SAMobileCapture',
    :podspec => 'https://raw.githubusercontent.com/Sodec-Technologies/sodec-identity-platform-ios-sdk-v1/1.0.7/SAMobileCapture.podspec'
end
```

Then install:

```bash
pod install --repo-update
```

The xcframework is downloaded from the GitHub Release asset and
verified against the SHA-256 checksum declared in the podspec; no
authentication is required.

> **Tip:** If you prefer to vendor the podspec inside your repository,
> commit the file at `vendor/SAMobileCapture.podspec` and reference it
> with `:podspec => 'vendor/SAMobileCapture.podspec'`.

---

## Resource bundles

All ML Kit and Google resource bundles ship inside the
`SAMobileCapture.framework` itself:

- `LatinOCRResources.bundle`
- `GoogleMVFaceDetectorResources.bundle`
- `FBLPromises_Privacy.bundle`
- `GTMSessionFetcher_Core_Privacy.bundle`
- `GoogleDataTransport_Privacy.bundle`
- `GoogleToolboxForMac_Privacy.bundle`
- `GoogleToolboxForMac_Logger_Privacy.bundle`
- `GoogleUtilities_Privacy.bundle`
- `nanopb_Privacy.bundle`

The framework is signed and embedded by Xcode automatically, so no extra
*Copy Bundle Resources* phase is needed.

---

## Continuous integration

Because the xcframework is fetched from a public GitHub Release, no
secrets need to be configured in CI.

### GitHub Actions (SPM)

```yaml
- name: Resolve SPM dependencies
  run: xcodebuild -resolvePackageDependencies
```

### GitHub Actions (CocoaPods)

```yaml
- name: Pod install
  run: pod install --repo-update
```

### Bitrise / Jenkins

Use the standard *Cocoapods Install* and *Xcode Archive* steps; no
custom credential injection is required.

---

## Minimal usage example

```swift
import UIKit
import SAMobileCapture

final class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        startDocumentCapture()
    }

    private func startDocumentCapture() {
        // Pseudocode. Replace with the bootstrap entry point provided to
        // your team during integration onboarding.
        let captureViewController = SAMobileCapture.makeDocumentCaptureViewController { result in
            switch result {
            case .success(let document):
                print("Captured document:", document)
            case .failure(let error):
                print("Capture failed:", error)
            }
        }
        present(captureViewController, animated: true)
    }
}
```

> The exact API surface depends on your contract tier; refer to the
> integration handbook delivered with your contract.

---

## Required `Info.plist` keys

Add the following keys to the host application's `Info.plist`. Provide
human-readable descriptions in the language(s) you ship.

```xml
<key>NSCameraUsageDescription</key>
<string>Required to capture identity documents and selfie.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Required for liveness video capture.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Required to save captured documents when permitted.</string>

<key>NFCReaderUsageDescription</key>
<string>Required to read the chip on electronic identity documents.</string>

<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>A0000002471001</string>
</array>
```

If your application targets devices without NFC, the SDK still links the
`CoreNFC` framework weakly so app launch will not crash.

---

## Versioning and support

`SAMobileCapture` follows [Semantic Versioning](https://semver.org/).
Breaking changes only land in major releases; deprecations are flagged in
[`CHANGELOG.md`](CHANGELOG.md) at least one minor release in advance.

For technical support and integration questions, contact
<support@sodec.com>.

For licensing or commercial inquiries, contact <legal@sodec.com>.
