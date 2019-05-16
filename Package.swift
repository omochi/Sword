// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Sword",
  platforms: [
    .macOS(.v10_14)
  ],
  products: [
    .library(
      name: "Sword",
      targets: ["Sword"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/omochi/nio-websocket-client.git",
      .branch("buffer-early-stream")
    ),
    .package(
      url: "https://github.com/swift-server/swift-nio-http-client.git",
      .branch("master")
    )
  ],
  targets: [
    .target(
      name: "Sword",
      dependencies: [
        "NIOWebSocketClient",
        "NIOHTTPClient"
      ]
    ),
    .testTarget(
      name: "SwordTests",
      dependencies: ["Sword"]
    ),
  ],
  swiftLanguageVersions: [.v5]
)
