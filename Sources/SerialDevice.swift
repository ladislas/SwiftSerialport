//
//  SerialDevice.swift
//  SwiftIOKitBridge
//
//  Created by Ladislas de Toldi on 12/10/2018.
//

import Foundation
import IOKit.usb

public typealias SerialDevice_t = (id:UInt64,
									vendorId:UInt16,
									productId:UInt16,
									name:String,
									locationId:UInt32,
									vendorName:String?,
									serialNr:String?,
									bsdPath:String?,
									deviceInterfacePtrPtr:UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?,
									plugInInterfacePtrPtr:UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?)

public struct SerialDevice {

	public let id:UInt64
	public let vendorId:UInt16
	public let productId:UInt16
	public let name:String
	public let locationId:UInt32
	public let vendorName:String?
	public let serialNr:String?
	public let bsdPath:String?

	public let deviceInterfacePtrPtr:UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?
	public let plugInInterfacePtrPtr:UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?

	public init(id:UInt64,
				vendorId:UInt16,
				productId:UInt16,
				name:String,
				locationId:UInt32,
				vendorName:String?,
				serialNr:String?,
				bsdPath:String?,
				deviceInterfacePtrPtr:UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?,
				plugInInterfacePtrPtr:UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?) {

		self.id = id
		self.vendorId = vendorId
		self.productId = productId
		self.name = name
		self.deviceInterfacePtrPtr = deviceInterfacePtrPtr
		self.plugInInterfacePtrPtr = plugInInterfacePtrPtr
		self.locationId = locationId
		self.vendorName = vendorName
		self.serialNr = serialNr
		self.bsdPath = bsdPath

	}

	public init(with device: SerialDevice_t) {

		self.id = device.id
		self.vendorId = device.vendorId
		self.productId = device.productId
		self.name = device.name
		self.deviceInterfacePtrPtr = device.deviceInterfacePtrPtr
		self.plugInInterfacePtrPtr = device.plugInInterfacePtrPtr
		self.locationId = device.locationId
		self.vendorName = device.vendorName
		self.serialNr = device.serialNr
		self.bsdPath = device.bsdPath

	}

}
