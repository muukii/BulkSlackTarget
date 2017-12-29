// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BulkSlackTarget",
  products: [
    .library(
      name: "BulkSlackTarget",
      targets: ["BulkSlackTarget"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/muukii/Bulk.git", .upToNextMinor(from:"0.4.3")),
  ],
  targets: [
    .target(
      name: "BulkSlackTarget",
      dependencies: [
        "Bulk",
      ]),
  ]
)
