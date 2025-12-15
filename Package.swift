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
    ),
    .library(
      name: "ARNavigation",
      targets: ["ARNavigation"]
    ),
    .library(
      name: "ARPersistence",
      targets: ["ARPersistence"]
    )
  ],
  targets: [
    .target(
      name: "ARUtilities",
      dependencies: ["ARNavigation", "ARPersistence"],
      path: "Sources/ARUtilities"
    ),
    .target(
      name: "ARNavigation",
      path: "Sources/ARNavigation"
    ),
    .target(
      name: "ARPersistence",
      path: "Sources/ARPersistence"
    ),
    .testTarget(
      name: "ARUtilitiesTests",
      dependencies: ["ARUtilities"],
      path: "Tests/ARUtilitiesTests"
    ),
    .testTarget(
      name: "ARNavigationTests",
      dependencies: ["ARNavigation"],
      path: "Tests/ARNavigationTests"
    ),
    .testTarget(
      name: "ARPersistenceTests",
      dependencies: ["ARPersistence"],
      path: "Tests/ARPersistenceTests"
    ),
  ]
)
