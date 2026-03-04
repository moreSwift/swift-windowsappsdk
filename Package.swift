// swift-tools-version: 5.10

import PackageDescription
import Foundation

let currentDirectory = Context.packageDirectory

let linkerSettings: [LinkerSetting] = [
/* Figure out magic incantation so we can delay load these dlls
    .unsafeFlags(["-L\(currentDirectory)/Sources/CWinAppSDK/nuget/lib"]),
    .unsafeFlags(["-Xlinker" , "/DELAYLOAD:Microsoft.WindowsAppRuntime.Bootstrap.dll"]),
*/
]

#if arch(x86_64)
    let windowsAppRTBootstrapDll: Resource = .copy("nuget/bin/x86_64/Microsoft.WindowsAppRuntime.Bootstrap.dll")
#elseif arch(arm64)
    let windowsAppRTBootstrapDll: Resource = .copy("nuget/bin/arm64/Microsoft.WindowsAppRuntime.Bootstrap.dll")
#endif

let package = Package(
    name: "swift-windowsappsdk",
    products: [
        .library(name: "WinAppSDK", type: .dynamic, targets: ["WinAppSDK"]),
        .library(name: "CWinAppSDK", targets: ["CWinAppSDK"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/moreSwift/swift-cwinrt",
            .upToNextMinor(from: "0.1.0")
        ),
        .package(
            url: "https://github.com/moreSwift/swift-uwp",
            .upToNextMinor(from: "0.1.0")
        ),
        .package(
            url: "https://github.com/moreSwift/swift-windowsfoundation",
            .upToNextMinor(from: "0.1.0")
        ),
    ],
    targets: [
        .target(
            name: "WinAppSDK",
            dependencies: [
                .product(name: "CWinRT", package: "swift-cwinrt"),
                .product(name: "UWP", package: "swift-uwp"),
                .product(name: "WindowsFoundation", package: "swift-windowsfoundation"),
                "CWinAppSDK"
            ]
        ),
        .target(
            name: "CWinAppSDK",
            resources: [
                windowsAppRTBootstrapDll,
            ],
            linkerSettings: linkerSettings
        ),
        .testTarget(
            name: "WinAppSDKTests",
            dependencies: [
                "WinAppSDK",
            ]
        )
    ]
)
