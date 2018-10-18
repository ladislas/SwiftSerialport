import Serialport

let sp = Serialport(path: "/dev/tty.usbmodem14101")

try? sp.open()

if sp.isOpen {
	print("I'm open!")
}
else {
	print("I'm sad...")
}

sp.close()
