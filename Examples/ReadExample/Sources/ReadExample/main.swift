import Foundation
//import Darwin
import Serialport

let sp = Serialport(path: "/dev/tty.usbmodem14101", bufferLength: 10)
sp.set(baudrate: 115200)

do {
	try sp.open()
} catch {
	print(error)
}

sp.waitForData()

sleep(2)

let info: [UInt8] = [0x2A, 0x2B, 0x2C, 0x2D, 0x01, 0x70, 0x70]

while true {
	let _ = readLine()
	print(sp.dataAvailable)
//	sp.write(array: info)

}


RunLoop.main.run()
