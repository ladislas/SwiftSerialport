//
//  SerialPort.swift
//  Serialport
//
//  Created by Ladislas de Toldi on 18/10/2018.
//

import Foundation

public typealias SerialSettings_t = ()

public enum SerialParity: Int {

	case none
	case even
	case odd

}

public enum SerialStatus {

	case open
	case closed

}

public enum SerialStopBits {

	case one
	case two

}

public struct SerialSettings {

	var baudrate: speed_t
	let parity: SerialParity
	let numberOfStopBits: SerialStopBits

	let shouldEchoReceivedData: Bool

	let usesRTSCTSFlowControl: Bool
	let usesDTRDSRFlowControl: Bool
	let usesDCDOutputFlowControl: Bool
	var RTS: Bool
	var DTR: Bool
	var CTS: Bool
	var DSR: Bool
	var DCD: Bool

	var controlCharacters: ControlCharacters_t

	public init(baudrate: speed_t = 9600,
		 parity: SerialParity = .none,
		 numberOfStopBits: SerialStopBits = .one,
		 shouldEchoReceivedData: Bool = false,
		 usesRTSCTSFlowControl: Bool = false,
		 usesDTRDSRFlowControl: Bool = false,
		 usesDCDOutputFlowControl: Bool = false,
		 RTS: Bool = false,
		 DTR: Bool = false,
		 CTS: Bool = false,
		 DSR: Bool = false,
		 DCD: Bool = false) {

		self.baudrate = baudrate
		self.parity = parity
		self.numberOfStopBits = numberOfStopBits

		self.shouldEchoReceivedData = shouldEchoReceivedData

		self.usesRTSCTSFlowControl = usesRTSCTSFlowControl
		self.usesDTRDSRFlowControl = usesDTRDSRFlowControl
		self.usesDCDOutputFlowControl = usesDCDOutputFlowControl
		self.RTS = RTS
		self.DTR = DTR
		self.CTS = CTS
		self.DSR = DSR
		self.DCD = DCD

		self.controlCharacters = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

	}

//	let path: String
//	let IOKitDevice: io_object_t
//	let name: String
//	let baudRate = Int(B115200)
//	let allowsNonStandardBaudRates = false
//	let numberOfStopBits = UInt(1)
//	let shouldEchoReceivedData = false
//	let parity: SerialParity = .none
//	let usesRTSCTSFlowControl = false
//	let usesDTRDSRFlowControl = false
//	let usesDCDOutputFlowControl = false
//	let RTS = false
//	let DTR = false
//	let CTS = false
//	let DSR = false
//	let DCD = false



}
