//
//  Extension-termios.swift
//  Serialport
//
//  Created by Ladislas de Toldi on 18/10/2018.
//

import Foundation

public typealias ControlCharacters_t = (VEOF: cc_t, VEOL: cc_t, VEOL2: cc_t, VERASE: cc_t, VWERASE: cc_t, VKILL: cc_t, VREPRINT: cc_t, spare1: cc_t, VINTR: cc_t, VQUIT: cc_t, VSUSP: cc_t, VDSUSP: cc_t, VSTART: cc_t, VSTOP: cc_t, VLNEXT: cc_t, VDISCARD: cc_t, VMIN: cc_t, VTIME: cc_t, VSTATUS: cc_t, spare: cc_t)

public extension termios {

	var numberOfStopBits: SerialStopBits {
		get {
			return self.c_cflag & tcflag_t(CSTOPB) != 0 ? .two : .one
		}
		set {
			if numberOfStopBits == .one {
				self.c_cflag |= tcflag_t(CSTOPB)
			} else {
				self.c_cflag &= ~tcflag_t(CSTOPB)
			}
		}
	}

	var shouldEchoReceivedData: Bool {
		get {
			return self.c_lflag & tcflag_t(ECHO) != 0
		}
		set {
			if shouldEchoReceivedData {
				self.c_lflag |= tcflag_t(ECHO)
			} else {
				self.c_lflag &= ~tcflag_t(ECHO)
			}
		}
	}

	var usesRTSCTSFlowControl: Bool {
		get {
			return self.c_cflag & tcflag_t((CCTS_OFLOW | CRTS_IFLOW)) != 0
		}
		set {
			if usesRTSCTSFlowControl {
				self.c_cflag |= tcflag_t((CCTS_OFLOW | CRTS_IFLOW))
			} else {
				self.c_cflag &= ~tcflag_t((CCTS_OFLOW | CRTS_IFLOW))
			}
		}
	}

	var usesDTRDSRFlowControl: Bool {
		get {
			return self.c_cflag & tcflag_t((CDTR_IFLOW | CDSR_OFLOW)) != 0
		}
		set {
			if usesDTRDSRFlowControl {
				self.c_cflag |= tcflag_t((CDTR_IFLOW | CDSR_OFLOW))
			} else {
				self.c_cflag &= ~tcflag_t((CDTR_IFLOW | CDSR_OFLOW))
			}
		}
	}

	var usesDCDOutputFlowControl: Bool {
		get {
			return self.c_cflag & tcflag_t(CCAR_OFLOW) != 0
		}
		set {
			if usesDCDOutputFlowControl {
				self.c_cflag |= tcflag_t(CCAR_OFLOW)
			} else {
				self.c_cflag &= ~tcflag_t(CCAR_OFLOW)
			}
		}
	}

	/// Convenience property for getting/setting parity
	var parity: SerialParity {
		get {
			if self.c_cflag & tcflag_t(PARENB) == 0 {
				return .none
			}
			if self.c_cflag & tcflag_t(PARODD) == 0 {
				return .even
			} else {
				return .odd
			}
		}
		set {
			switch parity {
			case .none:
				self.c_cflag &= ~tcflag_t(PARENB);
				break;
			case .even:
				self.c_cflag |= tcflag_t(PARENB);
				self.c_cflag &= ~tcflag_t(PARODD);
				break;
			case .odd:
				self.c_cflag |= tcflag_t(PARENB);
				self.c_cflag |= tcflag_t(PARODD);
				break;
			}
		}
	}
}
