// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(
	
    name: "OpenSendCloseExample",

	dependencies: [
		.package(path: "../../../SwiftSerialport")
	],

    targets: [
        .target(name: "OpenSendCloseExample", dependencies: ["SwiftSerialport"]),
    ]
)
