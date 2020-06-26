## THIS EXAMPLE (./configure_initramfs.sh) still does NOT work, would NOT be fixed in this context!

This one is here just for the references and some useful bash commands, for anybody to try to make a better one. :)

Please, refer to the WORKING initrd_example_2 (file create_initramfs.sh) example for the true help in:

https://github.com/ZoranStojsavljevic/BBB_Workshop_Examples/tree/master/Generic_Initrd_Porting_Guide/initrd_example_2

### Generating the GENERIC initramfs/initrd

The following script should be executed in order to create the GENERIC /boot/initrd.img-$(uname -r) :

	$ chmod 755 configure_initramfs.sh
	$ ./configure_initramfs.sh

From the $(root_initramfs_dir), which is equivalent to `pwd` of the script execution directory,
the following outcome/creation of the initramfs.img should happen in the $(root_initramfs_dir):

	$ ls -al
	total 6136
	drwxr-xr-x  3 vagrant vagrant    4096 Jun 17 19:02 .
	drwxr-xr-x 12 vagrant vagrant    4096 Jun 17 18:29 ..
	-rwxr-xr-x  1 vagrant vagrant    2742 Jun 17 18:59 configure_initramfs.sh
	-rw-r--r--  1 vagrant vagrant 6263142 Jun 17 19:02 initramfs.img
	drwxr-xr-x  4 vagrant vagrant    4096 Jun 17 18:59 work

And NOT only... The folowing is the outcome of the ./configure_initramfs.sh script execution in
the $(root_initramfs_dir):

	$ tree -L 3
	.
	├── configure_initramfs.sh
	├── initramfs.cpio.gz
	├── initramfs.cpio.xz
	├── initramfs.img
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
	    └── initramfs
	        ├── bin
	        ├── dev
	        ├── etc
	        ├── lib
	        ├── linuxrc -> bin/busybox
	        ├── proc
	        ├── root
	        ├── sbin
	        ├── sys
	        └── usr

	45 directories, 27 files

Since the initramfs.img is used for the special purposes. Currently, the / mount point is done
directly to SDcard.

Here is the kernel command line, used for the SDcard (from booting dmesg logs):

Kernel command line: console=ttyO0,115200n8 bone_capemgr.uboot_capemgr_enabled=1 root=/dev/mmcblk0p1 ro \
rootfstype=ext4 rootwait coherent_pool=1M net.ifnames=0 rng_core.default_quality=100

### Using an initramfs.img, for the special testing purposes

In the kernel command line, the following should be changed (initial - root=/dev/mmcblk0p1 ro):

	root=/dev/ram0 rw

On the target BBB platform, initramfs.img should be renamed in the /boot directory as:

	$ mv initramfs.img initrd.img-$(uname -r)

$(uname -r) is the kernel name from /boot/uEnv.txt which should be used for initial booting!

### How to re-generate the REAL (matching used $(uname -r) kernel) initramfs/initrd

After executing the generic initrd on the host cross-development machine and porting
it to the target platform (after booting the BBB platform from the SDcard)...

The following should be done in the /boot directory on the BBB target:

	$ sudo apt install dracut dracut-generic
	# Create a dracut enabled kernel ramdisk image
	$ sudo dracut /boot/initrd.img-$(uname -r) $(uname -r)
