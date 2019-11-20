import Foundation
import Serialport

class Example: SerialWatcherDelegate {
	// private var usbWatcher: USBWatcher!
	init() {
		// usbWatcher = USBWatcher(delegate: self)
	}

	func didAdd(device: io_object_t) {
		print("device added: \(device.name() ?? "<unknown>")")
		if let usbDevice = device.getInfo() {
			print("usbDevice.getInfo(): \(usbDevice)")
		}else{
			print("usbDevice: no extra info")
		}
	}

	func didRemove(device: io_object_t) {
		print("device removed: \(device.name() ?? "<unknown>")")
	}
}

private var serialWatcher: SerialWatcher!

let example = Example()
serialWatcher = SerialWatcher(delegate: example)

serialWatcher.start()

DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(5), execute: {
	serialWatcher.stop()
})

DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(10), execute: {
	serialWatcher.start()
})

RunLoop.main.run()
