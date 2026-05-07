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
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "SAMobileCapture",
            url: "https://github.com/Sodec-Technologies/sodec-identity-platform-ios-sdk-v1/releases/download/1.0.13/SAMobileCapture.xcframework.zip",
            checksum: "eb05a609d489e54a533cb99fc9f1684456373e105cefd524e4873d2ff547e1e5"
        ),

        // Binary targets cannot declare linker settings directly; this wrapper
        // keeps Apple system framework links attached to the exported product.
        .target(
            name: "SAMobileCaptureBootstrap",
            dependencies: [
                "SAMobileCapture"
            ],
            path: "Sources/SAMobileCaptureBootstrap",
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("sqlite3"),
                .linkedLibrary("z"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("Accelerate"),
                .linkedFramework("AssetsLibrary"),
                .linkedFramework("AudioToolbox"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreImage"),
                .linkedFramework("CoreLocation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreML"),
                .linkedFramework("CoreNFC"),
                .linkedFramework("CoreTelephony"),
                .linkedFramework("CoreText"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CryptoKit"),
                .linkedFramework("CryptoTokenKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("LocalAuthentication"),
                .linkedFramework("Metal"),
                .linkedFramework("MessageUI"),
                .linkedFramework("MobileCoreServices"),
                .linkedFramework("OpenGLES"),
                .linkedFramework("Photos"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("ReplayKit"),
                .linkedFramework("Security"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("UIKit")
            ]
        )
    ]
)
