//
//  SerialErrors.swift
//  Serialport
//
//  Created by Ladislas de Toldi on 18/10/2018.
//

import Foundation

public enum SerialError: Error {

	case pathNotFound

	case portNotAvailable

	case invalidFileDescriptor

	case portCannotBeOpened

	case flagCannotBeCleared

	case failedToReadModemLines

	case attributesCannotBeSet

	case readNotPossible

	case writeNotPossible

}
