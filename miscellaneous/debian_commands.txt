### How to Install Kernel Headers in Ubuntu and Debian
https://www.tecmint.com/install-kernel-headers-in-ubuntu-and-debian/

	$ uname -r
	$ apt search linux-headers-$(uname -r)
	$ sudo apt update
	$ sudo apt install linux-headers-$(uname -r)

### How to generate/create initramfs

Install dracut package:

	$ sudo apt install dracut

Create a backup copy of the current initrd:

	$ sudo cp -p /boot/initrd-$(uname -r).img /boot/initrd-$(uname -r).img.bak

Now create the initrd for the current kernel:

	$ sudo mkinitrd -f -v /boot/initrd-$(uname -r).img $(uname -r)

Or:

	$ sudo dracut -f /boot/initrd-$(uname -r).img $(uname -r)
