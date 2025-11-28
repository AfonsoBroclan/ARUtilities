// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "ARUtilities",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "ARUtilities",
      targets: ["ARUtilities"]
    )
  ],
  targets: [
    .target(
      name: "ARUtilities",
      path: "Sources/ARUtilities"
    ),
    .testTarget(
      name: "ARUtilitiesTests",
      dependencies: ["ARUtilities"],
      path: "Tests/ARUtilitiesTests"
    )
  ]
)
