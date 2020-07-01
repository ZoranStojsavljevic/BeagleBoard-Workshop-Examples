## Two ramfs approaches (INITRD and INITRAMFS), both known as ramfs concepts - both true working examples!

### INITRD concept shown
https://github.com/ZoranStojsavljevic/BBB_Workshop_Examples/tree/master/Generic_Initrd_Porting_Guide/initrd

### INITRAMFS concept shown
https://github.com/ZoranStojsavljevic/BBB_Workshop_Examples/tree/master/Generic_Initrd_Porting_Guide/initramfs

### Differences between initrd and initramfs

There are three options for getting early userspace and mounting the root filesystem:
2 with initrd and 1 with initramfs.

#### Short INITRD description

initrd is a filesystem (ext[234], squashfs, etc.) image, which is copied by the kernel
into ramdisk (/dev/ram*).

	- (obsolete) The kernel mounts the ramdisk, calls /linuxrc; /linuxrc loads required
	  modules, writes to /proc/sys/kernel/real-root-dev and exits. The kernel then mounts
	  the real root and calls the real /sbin/init

	- The kernel mounts the ramdisk, calls /sbin/init; /sbin/init mounts the real root,
	  calls pivot_root, execs the real /sbin/init

#### Short INITRAMFS description

	initramfs is a cpio archive, that is extracted by the kernel into tmpfs. The kernel
	calls /init, which is responsible for mounting the real root and exec'ing the real
	/sbin/init (via possibly via switch_root utility, which cleans up the tmpfs).

### References
https://wiki.gentoo.org/wiki/Initramfs/Guide#Linux_boot_process
