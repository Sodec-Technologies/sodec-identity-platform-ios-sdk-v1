// swift-tools-version:5.9
import PackageDescription

// SAMobileCapture 1.0.6+ ships as a "static-inside-dynamic" xcframework:
// the framework binary is itself dynamic (so it can be embedded as a regular
// .framework in the host app), but every transitive ML / Google / Computer
// Vision dependency is statically embedded inside the binary at SDK build
// time. This means consumers no longer need to add MLKit / OpenCV / TFLite
// SPM packages to their project, no longer need TensorFlowLiteSwift branch
// overrides, and no longer need to add `-ObjC -all_load` to their
// application target's Other Linker Flags.
//
// The only external dynamic dependency is OpenSSL, which is shipped as a
// pre-built dynamic xcframework by the upstream OpenSSL package and cannot
// be statically embedded.

let package = Package(
    name: "SAMobileCapture",
    platforms: [
        .iOS("15.6")
    ],
    products: [
        .library(
            name: "SAMobileCapture",
            targets: ["SAMobileCaptureBootstrap"]
        )
    ],
    dependencies: [
        // OpenSSL: 3.3.2000 is the minimum version that ships an Apple
        // Silicon arm64 simulator slice. The SAMobileCapture binary
        // dynamically links @rpath/OpenSSL.framework/OpenSSL at runtime,
        // so this package must be present in the resolved graph.
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", from: "3.3.2000")
    ],
    targets: [
        // Binary distribution. All ML Kit, TensorFlow Lite, OpenCV, and
        // Google Promises / Utilities transitive dependencies are statically
        // embedded inside this xcframework.
        .binaryTarget(
            name: "SAMobileCapture",
            url: "https://github.com/Sodec-Technologies/sodec-identity-platform-ios-sdk-v1/releases/download/1.0.7/SAMobileCapture.xcframework.zip",
            checksum: "d3c378e884ade21f2d9d89e10eacc03dcf8128caabc1233bf8fa02ef2c7b2d19"
        ),

        // Bootstrap target. Apple SPM forbids attaching dependencies, linker
        // settings, or resources directly to a binary target; everything
        // is wired here. ML Kit resource bundles ship inside the
        // SAMobileCapture xcframework itself (LatinOCRResources.bundle,
        // GoogleMVFaceDetectorResources.bundle, *_Privacy.bundle), so no
        // `resources:` directive is required.
        .target(
            name: "SAMobileCaptureBootstrap",
            dependencies: [
                "SAMobileCapture",
                .product(name: "OpenSSL", package: "OpenSSL")
            ],
            path: "Sources/SAMobileCaptureBootstrap"
        )
    ]
)
