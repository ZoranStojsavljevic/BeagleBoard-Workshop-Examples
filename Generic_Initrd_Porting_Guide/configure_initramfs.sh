#!/bin/bash

### Copyright (C) 2020, Zoran Stojsavljevic <zoran.stojsavljevic@gmail.com>
### SPDX-License-Identifier:	GNU General Public License v3.0
### Executed on Debian 10 (Debian Buster) Linux for the Open Source (as targeted platform) BBB platform
### Please, do note that this initramfs is a VERY generic one, applicable for all the ARM platforms!

### Make the necessary directories in which to work and where the output will be stored so it is accessible from the website
mkdir -p work/initramfs
cd work

### Download the busybox source code and unzip it
wget http://busybox.net/downloads/busybox-1.31.1.tar.bz2
tar -xvf busybox-1.31.1.tar.bz2
cd busybox-1.31.1

### Create the default configuration
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- defconfig

### Configure and make the initramfs
### make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig <<== Interractive Change
### Select the following settings: Busybox Settings → Build Options → Build Busybox as a static binary (no shared libs)

cp .config CONFIG
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' .config

### Verify differences and display 'em
diff -c .config CONFIG

### Execute the following commands for building the initramfs
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- CONFIG_PREFIX=/home/vagrant/initrd_bbox/work/initramfs /home/vagrant/initrd_bbox/work/initramfs install

cp CONFIG .config.old
cd ../initramfs

### Check we're in initramfs
wdir=$(pwd)
locn=$(basename $wdir)
if [ $locn != "initramfs" ]; then
	echo this script must be run from the initramfs directory
	exit 1
fi
### Create /dev and special files
mkdir dev

sudo mknod dev/console c 5 1
sudo mknod dev/null c 1 3
sudo mknod dev/zero c 1 5

### Populate /lib
mkdir lib usr/lib

rsync -a /usr/arm-linux-gnueabihf/lib/ ./lib/

### Add mount points
mkdir proc sys root
### /etc and configuration files
mkdir etc

echo "null::sysinit:/bin/mount -a" > etc/inittab
echo "null::sysinit:/bin/hostname -F /etc/hostname" >> etc/inittab
echo "null::respawn:/bin/cttyhack /bin/login root" >> etc/inittab
echo "null::restart:/sbin/reboot" >> etc/inittab

echo "proc  /proc proc  defaults  0 0" > etc/fstab
echo "sysfs /sys  sysfs defaults  0 0" >> etc/fstab

echo  beagleboneblack > etc/hostname

echo "root::0:0:root:/root:/bin/sh" > etc/passwd

### Do NOT use a soft link - problematic unexplored part, to be (for now) skipped!!!
### ln -s sbin/init init

### Create the initramfs
### find . -depth -print | cpio -ocvB | gzip -c > ../initramfs.cpio.gz <<== Just for the future considerations!
find . | cpio --create --format='newc' > ../../initramfs
cd ../..
gzip initramfs
mv initramfs.gz initramfs.img
