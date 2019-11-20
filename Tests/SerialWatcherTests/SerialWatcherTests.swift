//
//  SerialWatcherTests.swift
//  SerialportTests
//
//  Created by Ladislas de Toldi on 22/10/2018.
//

import Foundation
import XCTest
@testable import Serialport

class SWDelegate: SerialWatcherDelegate {

	init() {
		// nothing to to here...
	}

	func didAdd(device: io_object_t) {
		print("device added: \(device.name() ?? "<unknown>")")
		if let usbDevice = device.getInfo() {
			print("usbDevice.getInfo(): \(usbDevice)")
		} else {
			print("usbDevice: no extra info")
		}
	}

	func didRemove(device: io_object_t) {
		print("device removed: \(device.name() ?? "<unknown>")")
	}

}

class SerialWatcherTests: XCTestCase {

	func test_init() {

		let runLoop = CFRunLoopGetCurrent()

		let swd = SWDelegate()
		let sw = SerialWatcher(delegate: swd)

		sw.start()
		
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(2), execute: {
			sw.stop()
			CFRunLoopStop(runLoop)
		})

		CFRunLoopRun()

	}

}
