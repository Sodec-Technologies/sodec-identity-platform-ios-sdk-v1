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
        // ML Kit has no official SPM. This community wrapper exposes the
        // upstream ML Kit binary xcframeworks to Swift Package Manager.
        .package(url: "https://github.com/d-date/google-mlkit-swiftpm", exact: "9.0.0-1"),

        .package(url: "https://github.com/yeatse/opencv-spm", from: "4.13.0"),

        // OpenSSL remains a dynamic binary dependency of SAMobileCapture.
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", from: "3.3.2000"),

        // TensorFlowLiteSwift 2.14.0 depends on TensorFlowLiteC via branch.
        // Consumers may need to add TensorFlowLiteSwift with branch "master"
        // at the root app project to satisfy Apple's stable-to-unstable rule.
        .package(url: "https://github.com/kewlbear/TensorFlowLiteSwift.git", exact: "2.14.0")
    ],
    targets: [
        .binaryTarget(
            name: "SAMobileCapture",
            url: "https://github.com/Sodec-Technologies/sodec-identity-platform-ios-sdk-v1/releases/download/1.0.9/SAMobileCapture.xcframework.zip",
            checksum: "4ceaf231c98feda5656ad203cdad8c5dac5ea03871f05e5edfe449381da84b23"
        ),

        // Binary targets cannot declare dependencies directly; this wrapper
        // target publishes the SDK dependency graph to SPM consumers.
        .target(
            name: "SAMobileCaptureBootstrap",
            dependencies: [
                "SAMobileCapture",
                .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm"),
                .product(name: "MLKitFaceDetection",   package: "google-mlkit-swiftpm"),
                .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
                .product(name: "OpenCV",               package: "opencv-spm"),
                .product(name: "OpenSSL",              package: "OpenSSL"),
                .product(name: "TensorFlowLiteSwift",  package: "TensorFlowLiteSwift")
            ],
            path: "Sources/SAMobileCaptureBootstrap",
            linkerSettings: [
                .linkedFramework("CoreLocation"),
                .linkedFramework("CoreML")
                // ML Kit's SPM wrapper also requires host apps to add
                // -ObjC and -all_load in Other Linker Flags.
            ]
        )
    ]
)
