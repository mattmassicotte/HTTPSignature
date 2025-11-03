// swift-tools-version: 6.1

import PackageDescription

let package = Package(
	name: "HTTPSignature",
	platforms: [.macOS(.v13), .iOS(.v16)],
	products: [
		.library(
			name: "HTTPSignature",
			targets: ["HTTPSignature"]
		),
	],
	targets: [
		.target(
			name: "HTTPSignature"
		),
		.testTarget(
			name: "HTTPSignatureTests",
			dependencies: ["HTTPSignature"]
		),
	]
)
