### U-boot 04.2019 Overlays

The mandatory reading to understand U-boot 04.2019 overlays and environment
setup is posted here:

BeagleBone Black

https://www.digikey.com/eewiki/display/linuxonarm/BeagleBone+Black

Please, read this link very carefully!

#### Bootloader: U-Boot

Das U-Boot – the Universal Boot Loader: http://www.denx.de/wiki/U-Boot

eewiki.net patch archive: https://github.com/eewiki/u-boot-patches

Download U-Boot:

	user@localhost:~$
	git clone https://github.com/u-boot/u-boot
	cd u-boot/
	git checkout v2019.04 -b tmp

Or download U-Boot v2019.04 from:

	https://github.com/u-boot/u-boot/releases/tag/v2019.04

U-Boot Patches:

	user@localhost:~/u-boot$
	wget -c https://github.com/eewiki/u-boot-patches/raw/master/v2019.04/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
	wget -c https://github.com/eewiki/u-boot-patches/raw/master/v2019.04/0002-U-Boot-BeagleBone-Cape-Manager.patch

	patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
	patch -p1 < 0002-U-Boot-BeagleBone-Cape-Manager.patch

Configure and Build:

	user@localhost:~/u-boot$
	make ARCH=arm CROSS_COMPILE=${CC} distclean
	make ARCH=arm CROSS_COMPILE=${CC} am335x_evm_defconfig
	make ARCH=arm CROSS_COMPILE=${CC}

	With ${CC} = arm-linux-gnueabihf- :

	Debian:
	ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j8 am335x_evm_defconfig
	ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j8 menuconfig
	ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j8

	Optional for Fedora:
	ARCH=arm CROSS_COMPILE=arm-linux-gnu- make -j8 am335x_evm_defconfig
	ARCH=arm CROSS_COMPILE=arm-linux-gnu- make -j8 menuconfig
	ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j8 menuconfig (if Linaro cross GCC compiler installed)

#### Optional Reading

U-Boot Overlays:

https://elinux.org/Beagleboard:BeagleBoneBlack_Debian#U-Boot_Overlays

BeagleBone uboot transplantation:

http://www.programmersought.com/article/19361176463/

### Setup U-Boot microSD card

Erase partition table/labels on microSD card:

	$ sudo dd if=/dev/zero of=${DISK} bs=1M count=10

For the BBB board case, two files are generated: MLO and u-boot.img .

In order to flash the SD card!

MLO should reside at offset 1024KB (1MB) of the SD card. To place it there (assuming ${DISK} is /dev/sdX):

	Flash the MLO image into the SD card:
	$ sudo dd if=MLO of=${DISK} bs=128k count=1 seek=1; sync

	Flash the u-boot.img image into the SD card:
	$ sudo dd if=u-boot.img of=${DISK} bs=384k count=2 seek=1; sync

Similar:

Install Bootloader:

	$ sudo dd if=MLO of=/dev/sdc count=1 seek=1 bs=128k
	$ sudo dd if=u-boot.img of=/dev/sdc count=2 seek=1 bs=384k

Create User / partition for the Debian Buster:

	$ echo "Create primary partition 1 for rootfs"
	$ sudo echo -e "n\np\n1\n\n+16384M\nw\n" | fdisk ${DISK}

	$ echo "Formatting primary partition ${DISK} for rootfs"
	$ sudo mkfs.ext4 -F ${DISK}

For the Workshop:

	$ echo "Create primary partition 1 for rootfs"
	$ sudo echo -e "n\np\n1\n\n+16384M\nw\n" | /sbin/fdisk /dev/sdc

	$ echo "Formatting primary partition sdb1 for rootfs"
	$ sudo mkfs.ext4 -F /dev/sdc1

### BBB Version Number & The eMMC Size Discovery

The board has an EEPROM on it that has revision information. Please, stop at the U-Boot prompt,
then use the i2c commands to read it:

	=> i2c md 0x50 0.2 0x10
	0000: aa 55 33 ee 41 33 33 35 42 4e 4c 54 30 30 43 30    .U3.A335BNLT00C0

The U-Boot code also save this in its environment:

	U-Boot# printenv
	arch=arm
	baudrate=115200
	board=am335x
	board_name=A335BNLT
	board_rev=00C0
	board_serial=0218BBBK040F
