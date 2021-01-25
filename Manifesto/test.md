### Manifesto's test module

The test module is a simple python script that automates the hassle of user performing these
commands for the set of mikroBUS clicks, a typical user would use these command to instantiate
and use clicks from userspace(considering a no Click ID/EEPROM mechanism).

	cat manifests/<BOARD-NAME>.mnfb > /sys/class/mikrobus-port/mikrobus-0/new_device

For some sensor device the sensor values will be read from corresponding sysfs files and later,
after use, click can be unloaded:

	echo 0 > /sys/class/mikrobus-port/mikrobus-0/delete_device

The test script automates the process, loading the click, reading the sensor values, etc and
the later unloading the click:

https://github.com/vaishnav98/manifesto/blob/mikrobusv3/test#L51

It takes in the mikrobus port name and click name as input arguments over the command line
interface and then writes the manifest (from manifests/ directory) to /sys/class/mikrobus-port/{mikrobus-n}/new_device

	55	with open("/sys/class/mikrobus-port/{}/new_device".format(port), 'wb') as outFile:
	56		with open("manifests/{}.mnfb".format(click_test), 'rb') as mnfb:
	57			outFile.write(mnfb.read())

Then tries to read some sensor data (for sensor type clicks):

https://github.com/vaishnav98/manifesto/blob/mikrobusv3/test#L64

It ouputs them and later allows to remove the click:

https://github.com/vaishnav98/manifesto/blob/mikrobusv3/test#L67

	67	with open("/sys/class/mikrobus-port/{}/delete_device".format(port), 'wb') as outFile:
	68		outFile.write("0")
	69	time.sleep(0.5)
	70	os.system("dmesg | tail -n5 | grep mikrobus | grep removing")

These sensor clicks are supported for reading the input values/data:

https://github.com/vaishnav98/manifesto/blob/mikrobusv3/test.json
