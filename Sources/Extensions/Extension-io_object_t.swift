//
//  Extension-io_object_t.swift
//  SwiftSerialport
//
//  Created by Ladislas de Toldi on 11/10/2018.
//

import Foundation
import IOKit
import IOKit.usb
import IOKit.serial
//import IOKit.usb.IOUSBLib

// from IOUSBLib.h & IOCFPlugin.h
public let kIOUSBDeviceUserClientTypeID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                         0x9d, 0xc7, 0xb7, 0x80, 0x9e, 0xc0, 0x11, 0xD4,
                                                                         0xa5, 0x4f, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)
public let kIOUSBDeviceInterfaceID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                    0x5c, 0x81, 0x87, 0xd0, 0x9e, 0xf3, 0x11, 0xD4,
                                                                    0x8b, 0x45, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)

public let kIOCFPlugInInterfaceID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                   0xC2, 0x44, 0xE8, 0x58, 0x10, 0x9C, 0x11, 0xD4,
                                                                   0x91, 0xD4, 0x00, 0x50, 0xE4, 0xC6, 0x42, 0x6F)

extension io_object_t {

	public func name() -> String? {
		let buf = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
		defer { buf.deallocate() }
		return buf.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<io_name_t>.size) {
			if IORegistryEntryGetName(self, $0) == KERN_SUCCESS {
				return String(cString: $0)
			}
			return nil
		}
	}

	public func getInfo(andOutput output: Bool = false) -> SerialDevice? {

		var score: Int32 = 0
		var kr: kern_return_t = 0
		var did: UInt64 = 0
		var vid: UInt16 = 0
		var pid: UInt16 = 0
		var lid: UInt32 = 0
		var serialNr: String?
		var vendorName: String?
		var bsdPath: String?

		var deviceInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?
		var plugInInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?

		kr = IORegistryEntryGetRegistryEntryID(self, &did)

		if(kr != kIOReturnSuccess) {
			print("Error getting device id")
		}

		kr = IOCreatePlugInInterfaceForService(
			self,
			kIOUSBDeviceUserClientTypeID,
			kIOCFPlugInInterfaceID,
				&plugInInterfacePtrPtr,
				&score)


		// Get plugInInterface for current USB device
		kr = IOCreatePlugInInterfaceForService(
			self,
			kIOUSBDeviceUserClientTypeID,
			kIOCFPlugInInterfaceID,
				&plugInInterfacePtrPtr,
				&score)

		// Dereference pointer for the plug-in interface
		if (kr != kIOReturnSuccess) {
			return nil
		}

		guard let plugInInterface = plugInInterfacePtrPtr?.pointee?.pointee else {
			print("Unable to get Plug-In Interface")
			return nil
		}

		// use plug in interface to get a device interface
		kr = withUnsafeMutablePointer(to: &deviceInterfacePtrPtr) {
			$0.withMemoryRebound(to: Optional<LPVOID>.self, capacity: 1) {
				plugInInterface.QueryInterface(
					plugInInterfacePtrPtr,
					CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
					$0)
			}
		}

		// dereference pointer for the device interface
		if (kr != kIOReturnSuccess) {
			return nil
		}

		guard let deviceInterface = deviceInterfacePtrPtr?.pointee?.pointee else {
			print("Unable to get Device Interface")
			return nil
		}

		kr = deviceInterface.USBDeviceOpen(deviceInterfacePtrPtr)

		// kIOReturnExclusiveAccess is not a problem as we can still do some things
		if (kr != kIOReturnSuccess && kr != kIOReturnExclusiveAccess) {
			print("Could not open device (error: \(kr))")
			return nil
		}

		kr = deviceInterface.GetDeviceVendor(deviceInterfacePtrPtr, &vid)
		if (kr != kIOReturnSuccess) {
			return nil
		}

		kr = deviceInterface.GetDeviceProduct(deviceInterfacePtrPtr, &pid)
		if (kr != kIOReturnSuccess) {
			return nil
		}

		kr = deviceInterface.GetLocationID(deviceInterfacePtrPtr, &lid)
		if (kr != kIOReturnSuccess) {
			return nil
		}

		var umDict: Unmanaged<CFMutableDictionary>? = nil
		kr = IORegistryEntryCreateCFProperties(self as io_registry_entry_t, &umDict, kCFAllocatorDefault, 0)



		if let dict = umDict?.takeRetainedValue() as? [String: Any] {

			if output {
				print("----------------------------")
				for (key, value) in dict {
					print("\(key): \(value)")
				}
				print("----------------------------")
			}

			if let _serialNumber = dict[kUSBSerialNumberString] as? String {
				serialNr = _serialNumber
			}


			if let _vendorName = dict["USB Vendor Name"] as? String {
				vendorName = _vendorName
			}

		}

		if let deviceBSDName_cf = IORegistryEntrySearchCFProperty (self, kIOServicePlane, kIOCalloutDeviceKey as CFString, kCFAllocatorDefault, UInt32(kIORegistryIterateRecursively)) {
			bsdPath = "\(deviceBSDName_cf)"
		}

		if let name = self.name() {

			return SerialDevice(id: did, vendorId: vid, productId: pid, name: name, locationId: lid, vendorName: vendorName, serialNr: serialNr, bsdPath: bsdPath, deviceInterfacePtrPtr: deviceInterfacePtrPtr, plugInInterfacePtrPtr: plugInInterfacePtrPtr)

		}

		return nil

	}
}
