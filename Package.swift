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
    ),
    .library(
      name: "ARNetworking",
      targets: ["ARNetworking"]
    ),
    .library(
      name: "ARUI",
      targets: ["ARUI"]
    )
  ],
  dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0")
  ],
  targets: [
    .target(
      name: "ARUtilities",
      dependencies: ["ARNavigation", "ARPersistence", "ARNetworking", "ARUI"],
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
    .target(
      name: "ARNetworking",
      dependencies: ["ARPersistence"],
      path: "Sources/ARNetworking"
    ),
    .target(
      name: "ARUI",
      path: "Sources/ARUI",
      swiftSettings: [
          .enableExperimentalFeature("IsolatedDeinit")
      ]
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
    .testTarget(
      name: "ARNetworkingTests",
      dependencies: ["ARNetworking", "ARPersistence"],
      path: "Tests/ARNetworkingTests"
    ),
    .testTarget(
      name: "ARUITests",
      dependencies: [
        "ARUI",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
      ],
      path: "Tests/ARUITests",
      swiftSettings: [
          .enableExperimentalFeature("IsolatedDeinit")
      ]
    ),
  ]
)
