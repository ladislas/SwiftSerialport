// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(

	name: "SwiftSerialport",

	products: [
			.library(name: "SwiftSerialport", targets: ["Serialport"]),
	],

	targets: [
			.target(name: "Serialport", dependencies: [], path: "Sources"),

			.testTarget(name: "SerialportTests", dependencies: ["Serialport"]),
			.testTarget(name: "SerialWatcherTests", dependencies: ["Serialport"]),
			.testTarget(name: "SerialBufferTests", dependencies: ["Serialport"]),
	]

)
