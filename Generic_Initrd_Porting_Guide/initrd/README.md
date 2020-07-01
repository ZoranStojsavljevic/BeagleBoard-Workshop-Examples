### THIS EXAMPLE (./create_initrd.sh) does work!

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
	setenv loadinitrd 'tftp 0x88080000 ramdisk.img.gz.uboot; setenv initrd_size ${filesize}'
	setenv loadfdt 'tftp 0x88000000 am335x-boneblack.dtb'
	setenv bootargs 'console=ttyO0,115200n8 root=/dev/ram0 ip=dhcp'
	setenv bootcmd_ram 'dhcp; setenv serverip 192.168.178.20; run loadkernel; run loadinitrd; run loadfdt; bootz 0x82000000 0x88080000 0x88000000'
	run bootcmd_ram
