//
//  SerialportManager.swift
//  Serialport
//
//  Created by Ladislas de Toldi on 18/10/2018.
//

import Foundation
import Darwin.POSIX.termios


public class Serialport {

	//
	// MARK: - Properties
	//

	let path: String
	var serialSettings: SerialSettings
	var status: SerialStatus
	let buffer: SerialBuffer

	var originalOptions: termios?

	public var isOpen: Bool {
		return self.status == .open ? true : false
	}

	public var dataAvailable: Int32 {
		guard let fd = self.fileDescriptor else {
			print("not working")
			return -1
		}

		return ioctl(fd, FIONREAD)
	}

	var fileDescriptor: Int32?

	let queue = DispatchQueue.global(qos: .userInitiated)



	//
	// MARK: - Initialization
	//

	public init(path: String, bufferLength length: Int = 1024, withSettings settings: SerialSettings = SerialSettings()) {

		self.path = path
		self.serialSettings = settings
		self.status = .closed
		self.buffer = SerialBuffer(length: length)

	}

	//
	// MARK: - Open / Close
	//

	public func open() throws {

		if self.isOpen { return }

		// see https://www.gnu.org/software/libc/manual/html_node/File-Status-Flags.html#File-Status-Flags
		// for more information
		let fd = Darwin.open(self.path, O_RDWR | O_NOCTTY | O_EXLOCK | O_NONBLOCK)

		if fd < 1 {
			print("ERROR - Port \"\(path)\" could not be open")
			throw SerialError.failedToOpenPort
		}

		if fcntl(fd, F_SETFL, 0) == -1 {
			print("ERROR - Failed to clear O_NONBLOCK \(self.path) - \(String(describing: strerror(errno)))(\(errno)).\n")
			throw SerialError.failedToClearNonblockFlag
		}

		self.fileDescriptor = fd
		self.status = .open

		var opts = termios()
		tcgetattr(fd, &opts)
		self.originalOptions = opts

		try? setup()

		// TODO: try with and without that
		var modemLines: Int32 = 0
		if (ioctl(fd, TIOCMGET, &modemLines) < 0) {
			print("ERROR - Failed to read modem lines status")
			throw SerialError.failedToReadModemLines
		}

		let desiredRTS = self.serialSettings.RTS
		let desiredDTR = self.serialSettings.DTR
		self.serialSettings.RTS = modemLines & TIOCM_RTS != 0
		self.serialSettings.DTR = modemLines & TIOCM_DTR != 0
		self.serialSettings.RTS = desiredRTS
		self.serialSettings.DTR = desiredDTR

	}

	public func waitForData() {

		queue.async {

			guard let fd = self.fileDescriptor else {
				return
			}

			while true {

				let size = self.buffer.length
				
				var data = [UInt8](repeating: 0, count: size)

				let bytesRead = Darwin.read(fd, &data, size)

				self.buffer.append(array: data)

				let str = String(data: self.buffer.data[0...bytesRead - 1], encoding: .utf8)
				print(str!, terminator: "")

			}

		}

	}

	public func close() {

		self.status = .closed

		if let _ = self.fileDescriptor {
			Darwin.close(self.fileDescriptor!)
			self.fileDescriptor = nil
			self.originalOptions = nil
		}

	}

	//
	// MARK: - Setup
	//

	public func set(baudrate: speed_t) {

		self.serialSettings.baudrate = baudrate
		try? setup()

	}

	public func setup() throws {

		// TODO : remove or not the unwrapp
//		if let fd = self.fileDescriptor || self.fileDescriptor < Int32(1) {return}
		guard let fd = self.fileDescriptor else {
//			print("ERROR - File descriptor is not valid")
			throw SerialError.invalidFileDescriptor
		}

		var options = termios()
		tcgetattr(fd, &options)

		cfmakeraw(&options)

		/**
		Setup VMIN and VTIME
		see http://www.unixwiz.net/techtips/termios-vmin-vtime.html for more information
		VMIN  = 1 --> Wait for at least 1 character before returning from read
		VTIME = 2 --> Wait for 200 milliseconds after last byte before returning from read
		*/
		self.serialSettings.controlCharacters.VMIN = cc_t(1)
		self.serialSettings.controlCharacters.VTIME = cc_t(2)
		options.c_cc = self.serialSettings.controlCharacters

		// Set 8 data bits
		options.c_cflag &= ~tcflag_t(CSIZE)
		options.c_cflag |= tcflag_t(CS8)

		options.parity = self.serialSettings.parity
		options.numberOfStopBits = self.serialSettings.numberOfStopBits
		options.withRTSCTSFlowControl = self.serialSettings.withRTSCTSFlowControl
		options.withDTRDSRFlowControl = self.serialSettings.withDTRDSRFlowControl
		options.withDCDOutputFlowControl = self.serialSettings.withDCDOutputFlowControl

		options.c_cflag |= tcflag_t(HUPCL) // Turn on hangup on close
		options.c_cflag |= tcflag_t(CLOCAL) // Set local mode on
		options.c_cflag |= tcflag_t(CREAD) // Enable receiver
		options.c_lflag &= ~tcflag_t(ICANON | ISIG) // Turn off canonical mode and signals

		// Set baud rate
		cfsetspeed(&options, self.serialSettings.baudrate)

		let result = tcsetattr(fd, TCSANOW, &options)
		if result != 0 {
			throw SerialError.failedToSetAttributes
		}

		usleep(10000)

	}

	//
	// MARK: - Write
	//

	@discardableResult
	public func write(buffer: UnsafeRawPointer, size: Int) -> Int {

		guard let fd = self.fileDescriptor else {
			return -1
		}

		let bytesWritten = Darwin.write(fd, buffer, size)

		if bytesWritten < 1 {
			print("ERROR (\(bytesWritten)) - Failed to write UnsafeRawPointer")
		}

		return bytesWritten

	}

	@discardableResult
	public func write(byte: UInt8) -> Int {

		var byte = byte
		let bytesWritten = self.write(buffer: &byte, size: 1)

		if bytesWritten < 1 {
			print("ERROR (\(bytesWritten)) - Failed to write byte: \(byte)")
		}

		return bytesWritten

	}

	@discardableResult
	public func write(array: [UInt8]) -> Int {

		let bytesWritten = self.write(buffer: array, size: array.count)

		if bytesWritten < 1 {
			print("ERROR (\(bytesWritten)) - Failed to write array: \(array)")
		}

		return bytesWritten

	}

	@discardableResult
	public func write(data: Data) -> Int {

		let size = data.count
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)

		defer {
			buffer.deallocate()
		}

		data.copyBytes(to: buffer, count: size)

		let bytesWritten = self.write(buffer: buffer, size: size)

		return bytesWritten

	}

	@discardableResult
	public func write(string: String) -> Int {

		let data = Data(string.utf8)

		let bytesWritten = self.write(data: data)

		return bytesWritten

	}

	//
	// MARK: - Read
	//

	public func read() {

	}

	public func read(length: Int) {

	}

}
