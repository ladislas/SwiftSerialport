// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(

    name: "ReadExample",

	dependencies: [
		.package(path: "../../../SwiftSerialport")
	],

    targets: [
        .target(name: "ReadExample", dependencies: ["SwiftSerialport"]),
    ]
    
)
