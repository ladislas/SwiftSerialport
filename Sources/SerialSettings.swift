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

	let withRTSCTSFlowControl: Bool
	let withDTRDSRFlowControl: Bool
	let withDCDOutputFlowControl: Bool

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
		 withRTSCTSFlowControl: Bool = false,
		 withDTRDSRFlowControl: Bool = false,
		 withDCDOutputFlowControl: Bool = false,
		 RTS: Bool = false,
		 DTR: Bool = false,
		 CTS: Bool = false,
		 DSR: Bool = false,
		 DCD: Bool = false) {

		self.baudrate = baudrate
		self.parity = parity
		self.numberOfStopBits = numberOfStopBits

		self.shouldEchoReceivedData = shouldEchoReceivedData

		self.withRTSCTSFlowControl = withRTSCTSFlowControl
		self.withDTRDSRFlowControl = withDTRDSRFlowControl
		self.withDCDOutputFlowControl = withDCDOutputFlowControl
		self.RTS = RTS
		self.DTR = DTR
		self.CTS = CTS
		self.DSR = DSR
		self.DCD = DCD

		self.controlCharacters = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

	}

}

extension SerialSettings: Equatable {

	public static func == (lhs: SerialSettings, rhs: SerialSettings) -> Bool {

		return
			lhs.baudrate == rhs.baudrate &&
			lhs.parity == rhs.parity &&
			lhs.numberOfStopBits == rhs.numberOfStopBits &&

			lhs.shouldEchoReceivedData == rhs.shouldEchoReceivedData &&

			lhs.withRTSCTSFlowControl == rhs.withRTSCTSFlowControl &&
			lhs.withDTRDSRFlowControl == rhs.withDTRDSRFlowControl &&
			lhs.withDCDOutputFlowControl == rhs.withDCDOutputFlowControl &&

			lhs.RTS == rhs.RTS &&
			lhs.DTR == rhs.DTR &&
			lhs.CTS == rhs.CTS &&
			lhs.DSR == rhs.DSR &&
			lhs.DCD == rhs.DCD

	}
}
