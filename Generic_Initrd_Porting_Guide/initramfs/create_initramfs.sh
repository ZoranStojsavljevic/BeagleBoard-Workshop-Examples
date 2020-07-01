#!/bin/bash

### Copyright (C) 2020, Zoran Stojsavljevic <zoran.stojsavljevic@gmail.com>
### SPDX-License-Identifier:	GNU General Public License v3.0
### Executed on Debian 10 (Debian Buster) Linux for the Open Source (as targeted platform) BBB platform
### Please, do note that this initramfs is a VERY generic one, applicable for all the ARM platforms!

### Set the root_project directory as a root_initramfs_dir absolute path
root_initramfs_dir=`pwd`

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
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- CONFIG_PREFIX=$root_initramfs_dir/work/initramfs $root_initramfs_dir/work/initramfs install

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
mkdir proc sys root etc

echo "null::sysinit:/bin/mount -a" > etc/inittab
echo "null::sysinit:/bin/hostname -F /etc/hostname" >> etc/inittab
echo "null::respawn:/bin/cttyhack /bin/login root" >> etc/inittab
echo "null::restart:/sbin/reboot" >> etc/inittab

echo "proc  /proc proc  defaults  0 0" > etc/fstab
echo "sysfs /sys  sysfs defaults  0 0" >> etc/fstab

echo  beagleboneblack > etc/hostname

echo "root::0:0:root:/root:/bin/sh" > etc/passwd

touch init
chmod 777 init

### Create the init file
cat >> init << EOF
#!/bin/sh

### Mount things needed by this script
mount -t proc proc /proc
mount -t sysfs sysfs /sys

echo "Dropping to a shell"
exec sh
EOF

### Create the initramfs as .cpio.gz in $(root_initramfs_dir):
find . -print0 | cpio --null --create --verbose --format='newc' | gzip --best > ../../initramfs.cpio.gz
