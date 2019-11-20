//
//  SerialErrors.swift
//  Serialport
//
//  Created by Ladislas de Toldi on 18/10/2018.
//

import Foundation

public enum SerialError: Error {

	case failedToOpenPort
	case failedToClearNonblockFlag
	case failedToSetAttributes

	case invalidFileDescriptor

	case pathNotFound

	case portNotAvailable



	case portCannotBeOpened

	case flagCannotBeCleared

	case failedToReadModemLines


	case readNotPossible

	case writeFailed

}
