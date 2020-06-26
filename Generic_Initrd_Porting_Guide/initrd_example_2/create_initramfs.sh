#!/bin/bash

### Copyright (C) 2020, Zoran Stojsavljevic <zoran.stojsavljevic@gmail.com>
### SPDX-License-Identifier:	GNU General Public License v3.0
### Executed on Debian 10 (Debian Buster) Linux for the Open Source (as targeted platform) BBB platform
### Please, do note that this initramfs is a VERY generic one, applicable for all the ARM platforms!

### Housekeeping...
sudo rm -rf work
sudo umount -f -d /mnt/initrd
rm -f /tmp/ramdisk.img
rm -f /tmp/ramdisk.img.gz
sudo rm -rf /mnt/*

### Ramdisk Constants
RDSIZE=8000
BLKSIZE=1024

### Create an empty ramdisk image
dd if=/dev/zero of=/tmp/ramdisk.img bs=$BLKSIZE count=$RDSIZE

### Make it an ext2 mountable file system
### sudo /sbin/mke2fs ‑F ‑m 0 ‑b $BLKSIZE /tmp/ramdisk.img $RDSIZE
sudo /sbin/mke2fs -b $BLKSIZE /tmp/ramdisk.img $RDSIZE

sudo mkdir /mnt/initrd

### Mount it so that it could be populated
sudo mount -t ext2 -o loop /tmp/ramdisk.img /mnt/initrd

### Populate the filesystem (subdirectories)
sudo mkdir /mnt/initrd/sys
sudo mkdir /mnt/initrd/dev
sudo mkdir /mnt/initrd/proc

### Make the necessary directories in which to work and where the output will be stored so it is accessible from the website
mkdir work
cd work

### Download the busybox-1.31.1 source code and unzip it
wget http://busybox.net/downloads/busybox-1.31.1.tar.bz2
tar -xvf busybox-1.31.1.tar.bz2
cd busybox-1.31.1

### Create the default configuration
ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make defconfig

### Configure and make the initramfs
### make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig <<== Interractive Change
### Select the following settings: Busybox Settings → Build Options → Build Busybox as a static binary (no shared libs)

cp .config .config.old
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' .config

### Verify differences and display 'em
diff -c .config .config.old

### Execute the following commands for building the initramfs
sudo ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make CONFIG_PREFIX=/mnt/initrd /mnt/initrd install

### Get back to the initial working directory
cd ..

### Create /dev special files
sudo mknod /mnt/initrd/dev/console c 5 1
sudo mknod /mnt/initrd/dev/null c 1 3
sudo mknod /mnt/initrd/dev/zero c 1 5
sudo mknod -m 660 /mnt/initrd/dev/ram0 b 1 0
sudo chown root:disk /mnt/initrd/dev/ram0

sudo rm /mnt/initrd/linuxrc
sudo touch /mnt/initrd/linuxrc
sudo chmod 777 /mnt/initrd/linuxrc

### Create the init file
cat >> /mnt/initrd/linuxrc << EOF
#!/bin/ash
echo
echo "Simple initrd is active"
echo
mount ‑t proc /proc /proc
mount ‑t sysfs none /sys
/bin/ash ‑‑login
EOF

sudo chmod +x /mnt/initrd/linuxrc

### Finish the initrd creation
sudo umount -f -d /mnt/initrd

gzip ‑9 /tmp/ramdisk.img
