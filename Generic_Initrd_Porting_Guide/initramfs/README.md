## Short INITRAMFS guide (with the basic working example presented)

https://github.com/ZoranStojsavljevic/BBB_Workshop_Examples/tree/master/Generic_Initrd_Porting_Guide/initramfs

### Generating the GENERIC initramfs

The following script should be executed in order to create the GENERIC /boot/initrd.img-$(uname -r) :

	$ chmod 755 create_initramfs.sh
	$ ./create_initramfs.sh

From the $(root_initramfs_dir), which is equivalent to `pwd` of the script execution directory, the
following outcome/creation of the initramfs.cpio.gz should happen in the $(root_initramfs_dir) :

	$ ls -al
	total 6084
	drwxr-xr-x 3 vagrant vagrant    4096 Jul  1 18:02 .
	drwxr-xr-x 5 vagrant vagrant    4096 Jul  1 16:48 ..
	-rwxrwxrwx 1 vagrant vagrant    2737 Jul  1 18:02 create_initramfs.sh
	-rw-r--r-- 1 vagrant vagrant 6210165 Jul  1 18:03 initramfs.cpio.gz
	drwxr-xr-x 4 vagrant vagrant    4096 Jul  1 18:03 work

And NOT only... The folowing is the outcome of the ./create_initramfs.sh script execution in
the $(root_initramfs_dir):

	$ tree -L 3
	,
	├── create_initramfs.sh
	├── initramfs.cpio.gz
	└── work
	    ├── busybox-1.31.1
	    │   ├── applets
	    │   ├── applets_sh
	    │   ├── arch
	    │   ├── archival
	    │   ├── AUTHORS
	    │   ├── busybox
	    │   ├── busybox.links
	    │   ├── busybox_unstripped
	    │   ├── busybox_unstripped.map
	    │   ├── busybox_unstripped.out
	    │   ├── CONFIG
	    │   ├── Config.in
	    │   ├── configs
	    │   ├── console-tools
	    │   ├── coreutils
	    │   ├── debianutils
	    │   ├── docs
	    │   ├── e2fsprogs
	    │   ├── editors
	    │   ├── examples
	    │   ├── findutils
	    │   ├── include
	    │   ├── init
	    │   ├── INSTALL
	    │   ├── klibc-utils
	    │   ├── libbb
	    │   ├── libpwdgrp
	    │   ├── LICENSE
	    │   ├── loginutils
	    │   ├── mailutils
	    │   ├── Makefile
	    │   ├── Makefile.custom
	    │   ├── Makefile.flags
	    │   ├── Makefile.help
	    │   ├── make_single_applets.sh
	    │   ├── miscutils
	    │   ├── modutils
	    │   ├── networking
	    │   ├── NOFORK_NOEXEC.lst
	    │   ├── NOFORK_NOEXEC.sh
	    │   ├── printutils
	    │   ├── procps
	    │   ├── qemu_multiarch_testing
	    │   ├── README
	    │   ├── runit
	    │   ├── scripts
	    │   ├── selinux
	    │   ├── shell
	    │   ├── size_single_applets.sh
	    │   ├── sysklogd
	    │   ├── testsuite
	    │   ├── TODO
	    │   ├── TODO_unicode
	    │   └── util-linux
	    ├── busybox-1.31.1.tar.bz2
	    ├── busybox-1.31.1.tar.bz2.1
	    └── initramfs
	        ├── bin
	        ├── dev
	        ├── etc
	        ├── init
	        ├── lib
	        ├── linuxrc -> bin/busybox
	        ├── proc
	        ├── root
	        ├── sbin
	        ├── sys
	        └── usr

45 directories, 27 files

Since the initramfs.cpio.gz is used for the special purposes. Currently, the / mount point is done
directly to SDcard.

Here is the kernel command line, used for the SDcard (from booting dmesg logs):

Kernel command line: console=ttyO0,115200n8 bone_capemgr.uboot_capemgr_enabled=1 root=/dev/mmcblk0p1 ro \
rootfstype=ext4 rootwait coherent_pool=1M net.ifnames=0 rng_core.default_quality=100

### Using an initramfs.cpio.gz, for the special testing purposes

In the kernel command line, the following should be changed (initial - root=/dev/mmcblk0p1 ro):

	root=/dev/ram0 rw

On the target BBB platform, initramfs.cpio.gz should be renamed in the /boot directory as:

	$ mv initramfs.cpio.gz initrd.img-$(uname -r)

$(uname -r) is the kernel name from /boot/uEnv.txt which should be used for initial booting!

### How to re-generate the REAL (matching used $(uname -r) kernel) initrd

After executing the generic initrd on the host cross-development machine and porting
it to the target platform (after booting the BBB platform from the SDcard)...

The following should be done in the /boot directory on the BBB target:

	$ sudo apt install dracut dracut-generic
	# Create a dracut enabled kernel ramdisk image
	$ sudo dracut /boot/initrd.img-$(uname -r) $(uname -r)

### THIS EXAMPLE (./create_initramfs.sh) does work!

Was created on the Debian Buster, with the following features/parameters exposed:

	vagrant@buster:~$ uname -a
	Linux buster 4.19.0-9-amd64 #1 SMP Debian 4.19.118-2 (2020-04-29) x86_64 GNU/Linux

	vagrant@buster:~$ lsb_release -da
	No LSB modules are available.
	Distributor ID:	Debian
	Description:	Debian GNU/Linux 10 (buster)
	Release:	10
	Codename:	buster

	vagrant@buster:~$ sudo su

	root@buster:/home/vagrant# hostnamectl
	   Static hostname: buster
	         Icon name: computer-vm
	           Chassis: vm
	        Machine ID: bcbcd74445ce40c18e24a1ef4bdcf418
	           Boot ID: 078047d5e320415cbf3f2aa31f782544
	    Virtualization: oracle
	  Operating System: Debian GNU/Linux 10 (buster)
	            Kernel: Linux 4.19.0-9-amd64
	      Architecture: x86-64

Verified by the following U-BOOT ash script from the (patched by overlay patches) U-Boot 2019.04:

	setenv autoload no
	setenv initrd_high 0xffffffff
	setenv loadkernel 'tftp 0x82000000 zImage'
	setenv loadinitrd 'tftp 0x88080000 initramfs.img.uboot; setenv initrd_size ${filesize}'
	setenv loadfdt 'tftp 0x88000000 am335x-boneblack.dtb'
	setenv bootargs 'console=ttyO0,115200n8 root=/dev/ram0 ip=dhcp'
	setenv bootcmd_ram 'dhcp; setenv serverip 192.168.178.20; run loadkernel; run loadinitrd; run loadfdt; bootz 0x82000000 0x88080000 0x88000000'
	run bootcmd_ram
