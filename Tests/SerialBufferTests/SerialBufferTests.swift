import XCTest
@testable import Serialport

final class InitTests: XCTestCase {

	func test_init() {

		let myBuffer = SerialBuffer(length: 3)

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data())

	}

}

final class AppendDataTests: XCTestCase {

	func test_append_data_as_Data_1() {

		let myBuffer = SerialBuffer(length: 3)
		let someData = Data([1, 2, 3])

		myBuffer.append(data: someData)

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, someData)
		XCTAssertEqual(myBuffer.data.count, myBuffer.length)

	}

	func test_append_data_as_Data_2() {

		let myBuffer = SerialBuffer(length: 3)

		myBuffer.append(data: Data([1]))

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([1]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

		myBuffer.append(data: Data([2, 3]))

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([1, 2, 3]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

	}

	func test_append_data_as_Data_overfow() {

		let myBuffer = SerialBuffer(length: 3)

		myBuffer.append(data: Data([1, 2, 3]))

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([1, 2, 3]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

		myBuffer.append(data: Data([4, 5, 6]))

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([4, 5, 6]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

	}

	func test_append_data_as_UInt() {

		let myBuffer = SerialBuffer(length: 3)

		myBuffer.append(value: 1)

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([1]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

		myBuffer.append(value: 2)
		myBuffer.append(value: 3)

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([1, 2, 3]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

	}

	func test_append_data_as_UInt_overflow() {

		let myBuffer = SerialBuffer(length: 3)

		myBuffer.append(value: 1)
		myBuffer.append(value: 2)
		myBuffer.append(value: 3)
		myBuffer.append(value: 4)
		myBuffer.append(value: 5)
		myBuffer.append(value: 6)

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([4, 5, 6]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

	}

	func test_append_data_as_UInt_Array() {

		let myBuffer = SerialBuffer(length: 3)

		myBuffer.append(array: [1])

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([1]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

		myBuffer.append(array: [2, 3])

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([1, 2, 3]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

	}

	func test_append_data_as_UInt_Array_overflow() {

		let myBuffer = SerialBuffer(length: 3)

		myBuffer.append(array: [1, 2, 3, 4, 5, 6])

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data([4, 5, 6]))
		XCTAssertLessThanOrEqual(myBuffer.data.count, myBuffer.length)

	}

}

final class StatusTests: XCTestCase {

	func test_dataAvailable() {

		let myBuffer = SerialBuffer(length: 3)

		XCTAssertFalse(myBuffer.dataAvailable)

		myBuffer.append(array: [1, 2, 3])

		XCTAssertTrue(myBuffer.dataAvailable)

	}

}

final class ClearDataTests: XCTestCase {

	func test_clear() {

		let myBuffer = SerialBuffer(length: 3)
		let someData = Data([1, 2, 3])

		myBuffer.append(data: someData)

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, someData)
		XCTAssertEqual(myBuffer.data.count, myBuffer.length)

		myBuffer.clear()

		XCTAssertEqual(myBuffer.length, 3)
		XCTAssertEqual(myBuffer.data, Data())
		XCTAssertEqual(myBuffer.data.count, 0)

	}

}
