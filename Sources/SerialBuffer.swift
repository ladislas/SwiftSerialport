//
//  SerialBuffer.swift
//  SwiftSerialport
//
//  Created by Ladislas de Toldi on 09/10/2018.
//

import Foundation

public class SerialBuffer {

	var buffer: Data
	let length: Int

	public var data: Data {
		return buffer
	}

	public var dataAvailable: Bool {
		return !self.buffer.isEmpty ? true : false
	}

	init(length: Int) {

		self.length = length
		self.buffer = Data()

	}

	@discardableResult
	func append(data: Data) -> Int {
		buffer.append(data)
		if buffer.count > length {
			buffer.removeSubrange(0...length - 1)
		}
		return data.count
	}

	@discardableResult
	func append(value: UInt8) -> Int {
		buffer.append(value)
		if buffer.count > length {
			buffer.removeSubrange(0...length - 1)
		}
		return 1
	}

	@discardableResult
	func append(array: [UInt8]) -> Int {
		buffer.append(Data(array))
		if buffer.count > length {
			buffer.removeSubrange(0...length - 1)
		}
		return array.count
	}

	func clear() {
		self.buffer = Data()
	}

}
