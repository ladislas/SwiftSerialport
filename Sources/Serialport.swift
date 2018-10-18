//
//  SerialportManager.swift
//  Serialport
//
//  Created by Ladislas de Toldi on 18/10/2018.
//

import Foundation

public class Serialport {

	//
	// MARK: - Properties
	//

	let path: String
	var serialSettings: SerialSettings
	var status: SerialStatus

	var originalOptions: termios?

	public var isOpen: Bool {
		return self.status == .open ? true : false
	}

	var fileDescriptor: Int32?

	//
	// MARK: - Initialization
	//

	public init(path: String, withSettings settings: SerialSettings = SerialSettings()) {

		self.path = path
		self.serialSettings = settings
		self.status = .closed

	}

	//
	// MARK: - Open / Close
	//

	public func open() throws {

		if self.isOpen { return }

		// TODO
//		let fd = Darwin.open(self.path.cString(using: String.Encoding.ascii)!, O_RDWR | O_NOCTTY | O_EXLOCK | O_NONBLOCK)
		let fd = Darwin.open(self.path, O_RDWR | O_NOCTTY | O_EXLOCK | O_NONBLOCK)

		if fd < 1 {
			print("ERROR - Port \"\(path)\" could not be open")
			throw SerialError.portCannotBeOpened
		}

		if fcntl(fd, F_SETFL, 0) == -1 {
			print("ERROR - Failed to clear O_NONBLOCK \(self.path) - \(String(describing: strerror(errno)))(\(errno)).\n")
			throw SerialError.flagCannotBeCleared
		}

		self.fileDescriptor = fd
		self.status = .open

		var opts = termios()
		tcgetattr(fd, &opts)
		self.originalOptions = opts

		try? setup()

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

	public func close() {


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
//		if self.fileDescriptor < 1 { return }
		guard let fd = self.fileDescriptor else {
			print("ERROR - File descriptor is not valid")
			throw SerialError.invalidFileDescriptor
		}

		var options = termios()
		tcgetattr(fd, &options)

		cfmakeraw(&options)

		// Wait for at least 1 character before returning from read
		self.serialSettings.controlCharacters.VMIN = cc_t(1)
		// Wait for 200 milliseconds after last byte before returning from read
		self.serialSettings.controlCharacters.VTIME = cc_t(2)
		options.c_cc = self.serialSettings.controlCharacters

		// Set 8 data bits
		options.c_cflag &= ~tcflag_t(CSIZE)
		options.c_cflag |= tcflag_t(CS8)

		options.parity = self.serialSettings.parity
		options.numberOfStopBits = self.serialSettings.numberOfStopBits
		options.usesRTSCTSFlowControl = self.serialSettings.usesRTSCTSFlowControl
		options.usesDTRDSRFlowControl = self.serialSettings.usesDTRDSRFlowControl
		options.usesDCDOutputFlowControl = self.serialSettings.usesDCDOutputFlowControl

		options.c_cflag |= tcflag_t(HUPCL) // Turn on hangup on close
		options.c_cflag |= tcflag_t(CLOCAL) // Set local mode on
		options.c_cflag |= tcflag_t(CREAD) // Enable receiver
		options.c_lflag &= ~tcflag_t(ICANON | ISIG) // Turn off canonical mode and signals

		// Set baud rate
		cfsetspeed(&options, self.serialSettings.baudrate)

		let result = tcsetattr(fd, TCSANOW, &options)
		if result != 0 {
			throw SerialError.attributesCannotBeSet
		}

	}

	//
	// MARK: - Write
	//

	public func write(byte: UInt8) {

	}

	public func write(array: [UInt8]) {

	}

	public func write(data: Data) {

	}

	//
	// MARK: - Read
	//

	public func read() {

	}

	public func read(length: Int) {

	}

}
