// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let checksum = "c584d9f7f33e7a932ef14081ba3adf55e57cd4304f14b8ec617f83ee48572778"
let version = "v0.0.1-alpha.9"
let url = "https://github.com/UniPassID/ios-custom-auth-sdk/releases/download/\(version)/SharedFFI.xcframework.zip"

let package = Package(
  name: "CustomAuthSdk",
  platforms: [
    .iOS(.v13),
    .macOS(.v12)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "CustomAuthSdk",
      targets: ["CustomAuthSdk"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/argentlabs/web3.swift", from: "1.1.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .binaryTarget(name: "SharedFFI", url: url,checksum: checksum ),
    .target(name: "Shared", dependencies: [.target(name: "SharedFFI")]),
    .target(name: "CustomAuthSdk", dependencies: [.target(name: "Shared"), "web3.swift"]),
  ]
)
