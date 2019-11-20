//
//  SerialWatcher.swift
//  SwiftSerialport
//
//  Created by Ladislas de Toldi on 12/10/2018.
//

import Foundation

public class SerialWatcher {

	private weak var delegate: SerialWatcherDelegate?
	
	private var notificationPort = IONotificationPortCreate(kIOMasterPortDefault)
	private var addedIterator: io_iterator_t = 0
	private var removedIterator: io_iterator_t = 0

	public init(delegate: SerialWatcherDelegate? = nil) {
		self.delegate = delegate
	}

	public func start() {

		func handleNotification(instance: UnsafeMutableRawPointer?, _ iterator: io_iterator_t) {
			//the delay here is very important, because it gives the usb port time to set the bsp path for instance, this is sometimes needed.
			//maybe it should be on another thread?
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {

				let watcher = Unmanaged<SerialWatcher>.fromOpaque(instance!).takeUnretainedValue()
				let handler: ((io_iterator_t) -> Void)?

				switch iterator {

				case watcher.addedIterator:
					handler = watcher.delegate?.didAdd

				case watcher.removedIterator:
					handler = watcher.delegate?.didRemove

				default:
					assertionFailure("received unexpected IOIterator - \(iterator)")
					return

				}

				while case let device = IOIteratorNext(iterator), device != IO_OBJECT_NULL {
					handler?(device)
					IOObjectRelease(device)
				}
			})

		}

		let query = IOServiceMatching(kIOUSBDeviceClassName)
		let opaqueSelf = Unmanaged.passUnretained(self).toOpaque()

		// Watch for connected devices.
		IOServiceAddMatchingNotification(
			notificationPort, kIOMatchedNotification, query,
			handleNotification, opaqueSelf, &addedIterator)

		handleNotification(instance: opaqueSelf, addedIterator)

		// Watch for disconnected devices.
		IOServiceAddMatchingNotification(
			notificationPort, kIOTerminatedNotification, query,
			handleNotification, opaqueSelf, &removedIterator)

		handleNotification(instance: opaqueSelf, removedIterator)

		// Add the notification to the main run loop to receive future updates.
		CFRunLoopAddSource(CFRunLoopGetMain(), IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue(), .commonModes)

	}

	public func stop() {
		CFRunLoopRemoveSource(CFRunLoopGetMain(), IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue(), .commonModes)
		notificationPort = IONotificationPortCreate(kIOMasterPortDefault)
		addedIterator = 0
		removedIterator = 0
	}

	deinit {
		IOObjectRelease(addedIterator)
		IOObjectRelease(removedIterator)
		IONotificationPortDestroy(notificationPort)
	}

}
