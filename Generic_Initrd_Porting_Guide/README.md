### Generating the GENERIC initramfs/initrd

The following script should be executed in order to create the GENERIC /boot/initrd.img-$(uname -r) :

	configure_initramfs.sh

Then, on the target BBB platform, it should be renamed in the /boot directory as:

	mv initramfs.img initrd.img-$(uname -r)

$(uname -r) is the kernel name from /boot/uEnv.txt which should be used for initial booting!

### How to re-generate the REAL (matching used $(uname -r) kernel) initramfs/initrd

After executing the generic initrd on the host cross-development machine and porting
it to the target platform (after booting the BBB platform from the SDcard)...

The following should be done in the /boot directory on the BBB target:

	$ sudo apt install dracut dracut-generic
	# Create a dracut enabled kernel ramdisk image
	$ sudo dracut /boot/initrd.img-$(uname -r) $(uname -r)
