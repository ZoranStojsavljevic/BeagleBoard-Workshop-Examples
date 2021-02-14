### Debian Root File System

	Debian Buster user: debian, passwd: temppwd
	Debian Buster root: root, passwd: root

Download Debian Root File System:

	$ wget -c https://rcn-ee.com/rootfs/eewiki/minfs/debian-10.4-minimal-armhf-2020-05-10.tar.xz
	$ tar -xvf debian-10.4-minimal-armhf-2020-05-10.tar.xz

### Assuming Mounting Point

Mounting point for the SDcard could be various paths:

	/media/rootfs/
	/run/media/vuser/rootfs/

Assuming /run/media/vuser/rootfs mounting point in this example!

### Copy Root File System

	$ sudo tar xfvp ./*-*-*-armhf-*/armhf-rootfs-*.tar -C /run/media/vuser/rootfs
	$ sync
	$ sudo chown root:root /run/media/vuser/rootfs
	$ sudo chmod 755 /run/media/vuser/rootfs/

WARNING: Please, do note that in the /run/media/vuser/rootfs/boot/ there is NO
any data, since the given Debian Root File System tends to be GENERIC Root
Tree, applicable for ANY ARM architecture!

### Set uname_r in /boot/uEnv.txt

	$ sudo sh -c "echo 'uname_r=${kernel_version}' >> /run/media/vuser/rootfs/boot/uEnv.txt"

### Building a Custom BB-kernel on the cross-compiling (HOST) platform - The preffered method
https://github.com/RobertCNelson/bb-kernel

Current development is found under branches.

Example: https://github.com/RobertCNelson/bb-kernel/tree/am33x-v5.9

Execute the following to build the custom menuconfig:

	host$ git clone https://github.com/RobertCNelson/bb-kernel.git
	host$ cd bb-kernel
	host$ git remote show origin
	host$ git checkout am33x-v5.9
	host$ git branch ## to verify the execution of the last command
	host$ git describe
	host$ ./build_kernel.sh

After building the kernel the following 4 files are placed in the .../bb-kernel/deploy/
directory (example for the: kernel_version = `uname -r`):

	[vuser@fedora31-ssd bb-kernel-${kernel_version}]$ cd deploy/
	[vuser@fedora31-ssd deploy]$ ls -al
	total 31932
	drwxr-xr-x.  2 vuser vboxusers     4096 May 26 21:45 .
	drwxr-xr-x. 11 vuser vboxusers     4096 May 27 07:14 ..
	-rw-r--r--.  1 vuser vboxusers   673198 May 26 21:45 ${kernel_version}-dtbs.tar.gz
	-rw-r--r--.  1 vuser vboxusers 23056720 May 26 21:45 ${kernel_version}-modules.tar.gz
	-rwxr-xr-x.  1 vuser vboxusers  8771136 May 26 21:44 ${kernel_version}.zImage
	-rw-r--r--.  1 vuser vboxusers   179383 May 26 21:44 config-${kernel_version}
	[vuser@fedora31-ssd deploy]$

### Add bash Kernel Version ENV Variable

	$ export kernel_version=`uname -r`

### Copy Config (.config) File

	$ sudo cp -v ./bb-kernel/deploy/config-${kernel_version} /run/media/vuser/rootfs/boot/config-${kernel_version}

### Copy Kernel Image

	$ sudo cp -v ./bb-kernel/deploy/${kernel_version}.zImage /run/media/vuser/rootfs/boot/vmlinuz-${kernel_version}

### Copy Kernel Modules

	$ sudo tar xfv ./bb-kernel/deploy/${kernel_version}-modules.tar.gz -C /run/media/vuser/rootfs/

### Copy Kernel Device Tree Binaries

	$ sudo mkdir -p /run/media/vuser/rootfs/boot/dtbs/${kernel_version}/
	$ sudo tar xfv ./bb-kernel/deploy/${kernel_version}-dtbs.tar.gz -C /run/media/vuser/rootfs/boot/dtbs/${kernel_version}/

### Save System.map for out-of-tree device driver compilation

	$ sudo cp -v ./bb-kernel/KERNEL/System.map ./bb-kernel/deploy/System.map

### Save Module.symvers for out-of-tree device driver compilation

	$ sudo cp -v ./bb-kernel/KERNEL/Module.symvers ./bb-kernel/deploy/Module.symvers

### Port Kernel Source Tree into Target's /run/media/vuser/rootfs/usr/src/

	$ cd bb_kernel/KERNEL
	$ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j8 mrproper
	$ sudo mkdir /run/media/vuser/rootfs/usr/src/${kernel_version}
	$ sudo cp -Rfp . /run/media/vuser/rootfs/usr/src/${kernel_version}/

### Copy Module.symvers file to the target /usr/src/${kernel_version}/

	$ sudo cp -v ../../bb-kernel/deploy/Module.symvers /run/media/vuser/rootfs/usr/src/${kernel_version}/Module.symvers

### Copy System.map File to the target /boot/ and /usr/src/${kernel_version}/

	$ sudo cp -v ../../bb-kernel/deploy/System.map /run/media/vuser/rootfs/boot/System.map-${kernel_version}
	$ sudo cp -v ../../bb-kernel/deploy/System.map /run/media/vuser/rootfs/usr/src/${kernel_version}/System.map

### Create Proper Soft Links on the Target

	$ cd /run/media/vuser/rootfs/lib/modules/${kernel_version}
	$ sudo rm /run/media/vuser/rootfs/lib/modules/${kernel_version}/source
	$ sudo rm /run/media/vuser/rootfs/lib/modules/${kernel_version}/build
	$ sudo ln -s /usr/src/${kernel_version} source
	$ sudo ln -s /usr/src/${kernel_version}	build

### File Systems Table (/etc/fstab)

	$ sudo sh -c "echo '/dev/mmcblk0p1 / auto errors=remount-ro 0 1' >> /run/media/vuser/rootfs/etc/fstab"

### Target Board (after booting up to linux prompt)

#### Generate initrd-generic-$(uname -r).img

	debian@arm:~$ cd /boot
	debian@arm:/boot$ sudo dracut /boot/initrd-generic-$(uname -r).img $(uname -r)

#### Make Target Kernel Configuration in /usr/src/$(uname -r)/

To create include/generated/autoconf.h or include/config/auto.conf, the following should be ran: 'make oldconfig && make prepare'.

	debian@arm:~$ cd /usr/src/$(uname -r)
	## To syncronize local clock with files' timestamps
	echo "Syncronize local clock with files' timestamps"
	debian@arm:~$ find . -exec touch {} \;
	debian@arm:/usr/src/$(uname -r)$ su -m
	Password:
	debian@arm:/usr/src/$(uname -r)# make oldconfig && make prepare

#### Kernel < 5.10.0: to prepare out-of-tree device driver compilation in /usr/src/$(uname -r)/

	debian@arm:/usr/src/$(uname -r)# make scripts prepare

#### Kernel >= 5.10.0: to prepare out-of-tree device driver compilation in /usr/src/$(uname -r)/

	debian@arm:/usr/src/$(uname -r)# make modules_prepare

	root@arm:/usr/src/5.10.14-bone22# make modules_prepare
		CALL	scripts/checksyscalls.sh
		CALL	scripts/atomic/check-atomics.sh
		LDS	scripts/module.lds		<<======= NEW ADDITION =======

Please, do pay attention to the difference from previous kernels and 5.10.0 onwards: LDS     scripts/module.lds

The 5.10.0 patch changing the behaviour is the following:

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/Makefile?id=746b25b1aa0f5736d585728ded70a8141da91edb

	Preprocess scripts/modules.lds.S to allow CONFIG options in the module linker script

	diff --git a/Makefile b/Makefile
	index ebbd34801476a..e71979882e4fc 100644
	--- a/Makefile
	+++ b/Makefile

	@@ -1377,7 +1386,7 @@ endif
	 # using awk while concatenating to the final file.

	 PHONY += modules
	-modules: $(if $(KBUILD_BUILTIN),vmlinux) modules_check
	+modules: $(if $(KBUILD_BUILTIN),vmlinux) modules_check modules_prepare
	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.modpost

	PHONY += modules_check

### [OPTIONAL] Create the GENERIC initramfs/initrd for the very first time by custom script
https://github.com/ZoranStojsavljevic/BBB_Workshop_Examples/tree/master/Generic_Initrd_Porting_Guide/README.md

### Set Networking to work

Edit: /etc/network/interfaces file

	$ sudo nano /run/media/vuser/rootfs/etc/network/interfaces

Add to the /etc/network/interfaces:

	auto lo
	iface lo inet loopback

	auto eth0
	iface eth0 inet dhcp

### Remove microSD/SD card

	$ sync
	$ sudo umount /run/media/vuser/rootfs
