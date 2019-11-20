import Foundation
import Serialport

let sp = Serialport(path: "/dev/tty.usbmodem14101")

do {
	try sp.open()
} catch {
	print(error)
}


if sp.isOpen {

	do {
		sleep(2)

		var bw = try? sp.write(byte: 43)
		sleep(1)
		bw = try? sp.write(byte: 45)
		sleep(1)
		bw = try? sp.write(byte: 43)
		sleep(1)
		bw = try? sp.write(byte: 45)
		sleep(1)

		let a: [UInt8] = [43, 45, 43, 45, 43, 45, 43, 45, 43, 45]

		bw = try? sp.write(array: a)

		print("bw = \(String(describing: bw))")

		sleep(4)
		var on: UInt8 = 43
		var off: UInt8 = 45

		try sp.write(buffer: &on, size: 1)
		sleep(1)
		try sp.write(buffer: &off, size: 1)

		sleep(4)

		let c: [UInt8] = [43, 45, 43, 45, 43, 45]

		try sp.write(buffer: c, size: 6)
		sleep(1)
	} catch {
		print(error)
	}

	sp.close()

}
