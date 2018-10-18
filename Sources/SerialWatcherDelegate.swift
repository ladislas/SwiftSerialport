//
//  SerialWatcherDelegate.swift
//  SwiftSerialport
//
//  Created by Ladislas de Toldi on 12/10/2018.
//

import Foundation

public protocol SerialWatcherDelegate: class {

	/// Called on the main thread when a device is connected.
	func didAdd(device: io_object_t)

	/// Called on the main thread when a device is disconnected.
	func didRemove(device: io_object_t)

}
