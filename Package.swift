// swift-tools-version:5.9
import PackageDescription

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
        // ML Kit has no official SPM. Community wrapper pinned to the only
        // App Store Connect-safe release (the 9.0.0 wrapper Info.plist regression
        // is fixed in the -1 pre-release).
        .package(url: "https://github.com/d-date/google-mlkit-swiftpm", exact: "9.0.0-1"),

        .package(url: "https://github.com/yeatse/opencv-spm",           from: "4.13.0"),

        // OpenSSL: 3.3.2000 is the minimum version that ships an Apple Silicon
        // arm64 simulator slice.
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git",   from: "3.3.2000"),

        // TensorFlow Lite has no official SPM. The Swift wrapper is pinned to
        // exact 2.14.0 so the bundled ML models stay aligned with the C
        // runtime ABI. The consuming application MUST add this same package
        // again at the root level using `branch: "master"` so Apple SPM can
        // satisfy the wrapper's transitive `branch: "master"` requirement on
        // TensorFlowLiteC (Apple SPM forbids stable->unstable resolution).
        // See the README "Installation" section for the override snippet.
        .package(url: "https://github.com/kewlbear/TensorFlowLiteSwift.git", exact: "2.14.0")
    ],
    targets: [
        // Binary distribution. MNN, ncnn, and openmp are statically embedded
        // inside this xcframework, so they are NOT declared as separate
        // binary targets.
        .binaryTarget(
            name: "SAMobileCapture",
            url: "https://github.com/Sodec-Technologies/sodec-identity-platform-ios-sdk-v1/releases/download/1.0.0/SAMobileCapture.xcframework.zip",
            checksum: "a62207168e5b5e464207250600ab3e39eff15635a4284818a8faea4d58f8c5ec"
        ),

        // Bootstrap target. Apple SPM forbids attaching dependencies, linker
        // settings, or resources directly to a binary target; all such wiring
        // lives here. ML Kit resource bundles ship inside the SAMobileCapture
        // xcframework itself, so no `resources:` directive is required.
        .target(
            name: "SAMobileCaptureBootstrap",
            dependencies: [
                "SAMobileCapture",
                .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm"),
                .product(name: "MLKitFaceDetection",   package: "google-mlkit-swiftpm"),
                .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
                .product(name: "OpenCV",              package: "opencv-spm"),
                .product(name: "OpenSSL",              package: "OpenSSL"),
                .product(name: "TensorFlowLite",       package: "TensorFlowLiteSwift")
            ],
            path: "Sources/SAMobileCaptureBootstrap",
            linkerSettings: [
                // -ObjC: required for ML Kit category +load methods.
                // -all_load: required by ML Kit category dispatch on SPM
                //  (binary targets cannot carry linker flags themselves).
                // CoreNFC, CryptoKit, and CryptoTokenKit are weak-linked so
                //  hosts without NFC / Secure Enclave do not crash at launch.
                .unsafeFlags([
                    "-ObjC",
                    "-all_load",
                    "-weak_framework", "CoreNFC",
                    "-weak_framework", "CryptoKit",
                    "-weak_framework", "CryptoTokenKit"
                ])
            ]
        )
    ]
)
