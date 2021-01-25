## Manifesto
https://github.com/vaishnav98/manifesto/blob/mikrobusv3/README.md

Copied from: https://github.com/vaishnav98/manifesto

A simple tool to generate a mikroBUS manifest blob from a Python ConfigParser-style
input file.

Provided under BSD license. See *LICENSE* for details.

### Creating a Manifest Blob

For creating a manifest blob(.mnfb) from a manifest file(.mnfs) :

	manifesto -i /path/to/input.mnfs -o /path/to/output.mnfb

## Install

For generating the manifest blobs from all the manifest sources in the manifest/ directory,
run the installation script:

	sh install.sh

## Reproducing the Results using PocketBeagle 

Flash the testing image with the mikrobus driver available at [https://rcn-ee.net/rootfs/bb.org/testing/2020-08-15/buster-iot-mikrobus/](https://rcn-ee.net/rootfs/bb.org/testing/2020-08-15/buster-iot-mikrobus/) using [Etcher](https://www.balena.io/etcher/), then to load the mikrobus driver: 

Then edit the uEnv.txt to load the overlays for the mikrobus port-0 and port-1 on the pocketbeagle

	sudo nano /boot/uEnv.txt
	(Edit the below lines)
	#uboot_overlay_addr0=/lib/firmware/<file0>.dtbo
	#uboot_overlay_addr1=/lib/firmware/<file1>.dtbo
	(to)
	uboot_overlay_addr0=/lib/firmware/PB-MIKROBUS-0.dtbo
	uboot_overlay_addr1=/lib/firmware/PB-MIKROBUS-1.dtbo

Then clone the manifesto repository and checkout the mikrobusv3 branch and create all the manifest binaries:

	git clone https://github.com/vaishnav98/manifesto.git
	cd manifesto
	git checkout mikrobusv3
	./install.sh (will take about a minute)

The click can now be plugged in to the mikrobus port and the manifest binary can be passed to the
mikrobus driver to load the click device driver(s), the manifests under manifests/ directory are
TESTED and the test script provided can be used for testing different click.

### Test Script Usage

	debian@beaglebone:~/manifesto$ ./test
	board name> ETH-		(Press Tab to Auto complete from list of supported clicks)
	ETH-CLICK  ETH-WIZ-CLICK
	board name> ETH-CLICK
	port> mikrobus-			(Press Tab to Auto complete from list of attached mikrobus port)
	mikrobus-0  mikrobus-1
	port> mikrobus-0
	testing ETH-CLICK on mikrobus-0

	[ 1796.471765] mikrobus_manifest:mikrobus_manifest_attach_device: parsed device 1, driver=enc28j60
	[ 1796.471775] mikrobus_manifest:mikrobus_manifest_parse:  ETH Click manifest parsed with 1 devices
	[ 1796.482600] mikrobus:mikrobus_port_pinctrl_select: setting pinctrl pwm_default
	[ 1796.501342] mikrobus:mikrobus_port_pinctrl_select: setting pinctrl uart_default
	[ 1796.509828] mikrobus:mikrobus_port_pinctrl_select: setting pinctrl i2c_default
	[ 1796.518227] mikrobus:mikrobus_port_pinctrl_select: setting pinctrl spi_default
	[ 1796.526590] mikrobus mikrobus-0: registering device : enc28j60
	[ 1796.542878] enc28j60 spi0.0: Ethernet driver 1.02 loaded
	[ 1796.586682] enc28j60 spi0.0 eth0: link down
	[ 1796.598546] enc28j60 spi0.0 eth0: multicast mode
	[ 1796.611050] enc28j60 spi0.0 eth0: multicast mode
	[ 1797.551382] enc28j60 spi0.0 eth0: link up - Half duplex
	[ 1797.557113] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
	[ 1797.572018] enc28j60 spi0.0 eth0: multicast mode
	[ 1796.509828] mikrobus:mikrobus_port_pinctrl_select: setting pinctrl i2c_default
	[ 1796.518227] mikrobus:mikrobus_port_pinctrl_select: setting pinctrl spi_default
	[ 1796.526590] mikrobus mikrobus-0: registering device : enc28j60
	[ 1796.542878] enc28j60 spi0.0: Ethernet driver 1.02 loaded
	[ 1796.586682] enc28j60 spi0.0 eth0: link down
	[ 1796.598546] enc28j60 spi0.0 eth0: multicast mode
	[ 1796.611050] enc28j60 spi0.0 eth0: multicast mode
	[ 1797.720267] 8021q: 802.1Q VLAN Support v1.8
	[ 1797.551382] enc28j60 spi0.0 eth0: link up - Half duplex
	[ 1797.557113] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
	[ 1797.572018] enc28j60 spi0.0 eth0: multicast mode
	Traceback (most recent call last):
	  File "./test", line 82, in <module>
	    main()
	  File "./test", line 65, in main
	    choice = raw_input("remove board[y/n]> ")
	NameError: name 'raw_input' is[ 1797.759619] enc28j60 spi0.0 eth0: multicast mode
	 not defined
	debian@arm:~/manifesto$ [ 1799.528003] enc28j60 spi0.0 eth0: multicast mode
	[ 1799.540352] enc28j60 spi0.0 eth0: multicast mode
	[ 1801.010005] enc28j60 spi0.0 eth0: multicast mode
	[ 1801.026216] enc28j60 spi0.0 eth0: multicast mode
	[ 1803.096771] enc28j60 spi0.0 eth0: multicast mode

### Loading Add-on Board (Debug Interface run as root)

	cat manifests/<BOARD-NAME>.mnfb > /sys/class/mikrobus-port/mikrobus-0/new_device
	cat manifests/ETH-CLICK.mnfb > /sys/class/mikrobus-port/mikrobus-0/new_device

### Unloading the Add-on Board (Debug Interface run as root)

	echo 0 > /sys/class/mikrobus-port/mikrobus-0/delete_device

### Writing a Manifest Blob to EEPROM

For writing a manifest blob(.mnfb) created from a manifest file(.mnfs) to an EEPROM (the EEPROM
probe is specific to the type of EEPROM):

	echo 24c32 0x57 > /sys/bus/i2c/devices/i2c-1/new_device
	./manifesto -i manifests/mpu9dof.mnfs -o /sys/bus/nvmem/devices/1-00570/nvmem
	echo 0x57 > /sys/bus/i2c/devices/i2c-1/delete_device

### Writing a Manifest Blob to Click ID EEPROM

If a valid manifest binary is not found in the Click ID EEPROM, the device is exposed as a NVMEM
device and the manifest can be written to the EEPROM in the following manner.

	$ ./manifesto -i manifests/ETH-CLICK.mnfs -o /sys/bus/nvmem/devices/mikrobus-port0/nvmem
	$ xxd /sys/bus/nvmem/devices/mikrobus-port0/nvmem		(reading back written manifest)
	00000000: 8000 0001 0800 0100 0102 0000 1800 0200  ................
	00000010: 1001 4d69 6b72 6f45 6c65 6b74 726f 6e69  ..MikroElektroni
	00000020: 6b61 0000 1000 0200 0902 4554 4820 436c  ka........ETH Cl
	00000030: 6963 6b00 1000 0500 0401 0707 0606 0505  ick.............
	00000040: 0505 0201 0800 0300 010a 0000 0800 0400  ................
	00000050: 0100 0102 0800 0400 0200 010b 1400 0700  ................
	00000060: 0103 0b00 0024 f400 0102 0000 0000 0000  .....$..........
	00000070: 1000 0200 0803 656e 6332 386a 3630 0000  ......enc28j60..
	00000080: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000090: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000000a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000000b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000000c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000000d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000000e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000000f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000100: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000110: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000120: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000130: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000140: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000150: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000160: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000170: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000180: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000190: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000001a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000001b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000001c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000001d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000001e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	000001f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
	00000200: ffff ffff ffff ffff ffff ffff ffff ffff  ................

### Writing Manifests for new Add-On Boards

For writing manifests for new add-on boards using an interactive interface head over to https://vaishnav98.github.io/manifesto/

### Status of Supported Add-on Boards

To see the status of Supported add-on boards, view [this CSV sheet](click_info.csv)

### Hardware Modifications

Some of the Existing Clicks require minor hardware modifications to work with the kernel driver
correctly. This section maintains the list of the clicks which require hardware modifications:

* GNSS ZOE Click : Swap COMM SEL Jumpers Default Position to select UART.
* GNSS Clicks: All GNSS Clicks are Supported through the gnss linux subsytems, so their COMM SEL
Default position needs to be in the UART Position
* 6 LoWPAN T Click : The driver requires fifo, fifop, sfd, cca, vreg and reset gpio of which vreg,
reset and fifo gpios are routed to the mikroBUS headers correctly but the  other GPIOs are not
accessible, GPIO 2,3,4 from CC2520 needs to be routed to the mikroBUS headers(GPIO reference 1MHZ
Clock is not necessary).
* 6 LoWPAN C Click : The driver requires fifo, fifop, sfd, cca, vreg and reset gpio of which vreg,
reset and fifo gpios are routed to the mikroBUS headers correctly but the  other GPIOs are not
accessible, GPIO 2,3,4 from CC2520 needs to be routed to the mikroBUS headers(GPIO reference 1MHZ
Clock is not necessary).

### Kconfig
This list contains a few dependent Kconfig settings that needs to be applied (if testing all of
the supported) apart from the Click Driver Kconfig.

	CONFIG_MODULES=y
	CONFIG_SYSFS=y
	CONFIG_I2C=y
	CONFIG_SPI=y
	CONFIG_GPIOLIB=y
	CONFIG_PWM=y
	CONFIG_IIO=m
	CONFIG_MIKROBUS=m
	CONFIG_STAGING=y
	CONFIG_FB=y
	CONFIG_FB_TFT=m
	CONFIG_NET=y
	CONFIG_NETDEVICES=y
	CONFIG_ETHERNET=y
	CONFIG_NET_VENDOR_MICROCHIP=y
	CONFIG_MMC=m
	CONFIG_RTC_CLASS=y
	CONFIG_NFC=m
	CONFIG_NFC_DIGITAL=m
