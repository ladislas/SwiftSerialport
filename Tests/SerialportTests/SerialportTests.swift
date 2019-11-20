//
//  SerialportTests.swift
//  SerialportTests
//
//  Created by Ladislas de Toldi on 22/10/2018.
//

import XCTest
@testable import Serialport

fileprivate var path = "/Users/ladislas/dev/ladislas/SwiftSerialport/.build/testFile.txt"

fileprivate func contentOfPort(_ path: String) -> [UInt8] {

	let url = URL(fileURLWithPath: path)

	do {
		let data = try Data(contentsOf: url)
		var buffer = [UInt8](repeating: 0, count: data.count)
		data.copyBytes(to: &buffer, count: data.count)
		return buffer
	} catch {
		print(error)
	}

	return []

}

final class InitTests: XCTestCase {

	override func setUp() {

		let fm = FileManager.default

		if fm.createFile(atPath: path, contents: nil) {
			print("File created at: \(path)")
		} else {
			print("ERROR - Could not create file at: \(path)")
		}

	}

	override func tearDown() {
		let fm = FileManager.default

		do {
			try fm.removeItem(atPath: path)
		} catch {
			print("ERROR (\(error)) - Could not remove file at: \(path)")
		}
	}

	func test_init() {

		let sp = Serialport(path: path)

		XCTAssertEqual(sp.path, path)
		XCTAssertEqual(sp.serialSettings, SerialSettings())
		XCTAssertEqual(sp.status, SerialStatus.closed)
		XCTAssertFalse(sp.isOpen)

	}

}

final class OpenCloseSetupTests: XCTestCase {

	override func setUp() {

		let fm = FileManager.default

		if fm.createFile(atPath: path, contents: nil) {
			print("File created at: \(path)")
		} else {
			print("ERROR - Could not create file at: \(path)")
		}

	}

	override func tearDown() {
		let fm = FileManager.default

		do {
			try fm.removeItem(atPath: path)
		} catch {
			print("ERROR (\(error)) - Could not remove file at: \(path)")
		}
	}

	func test_open() {

		let sp = Serialport(path: path)

		try! sp.open()

		XCTAssertTrue(sp.isOpen)
		XCTAssertNotNil(sp.originalOptions)
		XCTAssertNotNil(sp.fileDescriptor)

		sp.close()

	}

	func test_open_wrong_port() {

		let sp = Serialport(path: "/dev/notaport")

		XCTAssertThrowsError(try sp.open())

		XCTAssertFalse(sp.isOpen)
		XCTAssertNil(sp.originalOptions)
		XCTAssertNil(sp.fileDescriptor)

		sp.close()

	}

	func test_open_opened_port() {

		let sp = Serialport(path: path)

		try? sp.open()

		XCTAssertTrue(sp.isOpen)
		XCTAssertNotNil(sp.originalOptions)
		XCTAssertNotNil(sp.fileDescriptor)

		try? sp.open()

		XCTAssertTrue(sp.isOpen)
		XCTAssertNotNil(sp.originalOptions)
		XCTAssertNotNil(sp.fileDescriptor)

		sp.close()

	}

	func test_close() {

		let sp = Serialport(path: path)

		try? sp.open()

		XCTAssertTrue(sp.isOpen)
		XCTAssertNotNil(sp.originalOptions)
		XCTAssertNotNil(sp.fileDescriptor)

		sp.close()

		XCTAssertFalse(sp.isOpen)
		XCTAssertNil(sp.originalOptions)
		XCTAssertNil(sp.fileDescriptor)

	}

	func test_setBaudrate() {

		let sp = Serialport(path: path)

		sp.set(baudrate: 115200)

		XCTAssertEqual(sp.serialSettings.baudrate, 115200)

		try? sp.open()

		XCTAssertTrue(sp.isOpen)
		XCTAssertNotNil(sp.originalOptions)
		XCTAssertNotNil(sp.fileDescriptor)
		XCTAssertEqual(sp.serialSettings.baudrate, 115200)

		sp.close()

	}

}

final class WriteTests: XCTestCase {

	override func setUp() {

		let fm = FileManager.default

		if fm.createFile(atPath: path, contents: nil) {
			print("File created at: \(path)")
		} else {
			print("ERROR - Could not create file at: \(path)")
		}

	}

	override func tearDown() {
		let fm = FileManager.default

		do {
			try fm.removeItem(atPath: path)
		} catch {
			print("ERROR (\(error)) - Could not remove file at: \(path)")
		}
	}

	func test_write_buffer_byte() {

		let sp = Serialport(path: path)

		try? sp.open()

		var buf: UInt8 = 42

		let bw = sp.write(buffer: &buf, size: 1)

		XCTAssertEqual(bw, 1)
		XCTAssertEqual(contentOfPort(path), [buf])

	}

	func test_write_buffer_array() {

		let sp = Serialport(path: path)

		try? sp.open()

		let buf: [UInt8] = [1, 2, 3, 4, 5]

		let bw = sp.write(buffer: buf, size: 5)

		XCTAssertEqual(bw, 5)
		XCTAssertEqual(contentOfPort(path), buf)

	}

	func test_write_byte() {

		let sp = Serialport(path: path)

		try? sp.open()

		let bw = sp.write(byte: 42)

		XCTAssertEqual(bw, 1)
		XCTAssertEqual(contentOfPort(path), [UInt8(42)])

	}

	func test_write_array() {

		let sp = Serialport(path: path)

		try? sp.open()

		let bw = sp.write(array: [42, 43, 44, 45])

		XCTAssertEqual(bw, 4)
		XCTAssertEqual(contentOfPort(path), [42, 43, 44, 45])

	}



	func test_write_data() {

		let sp = Serialport(path: path)

		try? sp.open()

		let d = Data([1, 2, 3, 4])

		let bw = sp.write(data: d)

		XCTAssertEqual(bw, 4)
		XCTAssertEqual(contentOfPort(path), [1, 2, 3, 4])

	}

	func test_write_string() {

		let sp = Serialport(path: path)

		try? sp.open()

		let bw = sp.write(string: "+-+-+-+-")

		XCTAssertEqual(bw, 8)
		XCTAssertEqual(contentOfPort(path), [43, 45, 43, 45, 43, 45, 43, 45])

	}

}

final class ReadTests: XCTestCase {

	override func setUp() {

		let fm = FileManager.default

		if fm.createFile(atPath: path, contents: nil) {
			print("File created at: \(path)")
		} else {
			print("ERROR - Could not create file at: \(path)")
		}

	}

	override func tearDown() {
		let fm = FileManager.default

		do {
			try fm.removeItem(atPath: path)
		} catch {
			print("ERROR (\(error)) - Could not remove file at: \(path)")
		}
		
	}

}
