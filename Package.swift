// swift-tools-version: 6.2
import PackageDescription

import Foundation
let packageDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path
let hasSherpaFramework = FileManager.default.fileExists(
    atPath: packageDir + "/Frameworks/sherpa-onnx.xcframework/Info.plist"
)
let hasCloudSubscription = FileManager.default.fileExists(
    atPath: packageDir + "/KeyType/CloudSubscription/marker"
)

var swiftDefines: [SwiftSetting] = [.swiftLanguageMode(.v5)]
if hasSherpaFramework { swiftDefines.append(.define("HAS_SHERPA_ONNX")) }
if hasCloudSubscription { swiftDefines.append(.define("HAS_CLOUD_SUBSCRIPTION")) }

var excludes = ["Resources"]
if !hasCloudSubscription { excludes.append("CloudSubscription") }

var targets: [Target] = [
    .executableTarget(
        name: "KeyType",
        dependencies: hasSherpaFramework ? ["SherpaOnnxLib"] : [],
        path: "KeyType",
        exclude: excludes,
        cSettings: hasSherpaFramework ? [.headerSearchPath("Bridge")] : [],
        swiftSettings: swiftDefines,
        linkerSettings: (hasSherpaFramework ? [
            .linkedLibrary("c++"),
            .linkedFramework("Accelerate"),
            .linkedFramework("Foundation"),
        ] : []) + [
            .linkedFramework("MediaPlayer"),
        ]
    ),
    .testTarget(
        name: "KeyTypeTests",
        dependencies: ["KeyType"],
        path: "KeyTypeTests"
    ),
]

if hasSherpaFramework {
    targets.insert(
        .binaryTarget(name: "SherpaOnnxLib", path: "Frameworks/sherpa-onnx.xcframework"),
        at: 0
    )
}

let package = Package(
    name: "KeyType",
    platforms: [.macOS(.v14)],
    dependencies: [],
    targets: targets
)
