// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(

    name: "SerialWatcherExample",

    dependencies: [
    	.package(path: "../../../SwiftSerialport")
	],

    targets: [
        .target(name: "SerialWatcherExample", dependencies: ["SwiftSerialport"]),
    ]

)
