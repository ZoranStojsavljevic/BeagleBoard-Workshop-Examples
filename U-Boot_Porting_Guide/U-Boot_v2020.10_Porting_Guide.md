### Beagleboard U-Boot repo
https://github.com/beagleboard/u-boot

### Cloning the Beagleboard U-Boot
git clone https://github.com/beagleboard/u-boot

### The branch v2020.10-bbb.io-am335x

The branch: v2020.10-bbb.io-am335x already has prebuilt changes for the overlays:

	$ cd u-boot
	$ git describe
	v2021.10-rc3-107-g5c25757326
	$ git checkout v2020.10-bbb.io-am335x
	Branch 'v2020.10-bbb.io-am335x' set up to track remote branch 'v2020.10-bbb.io-am335x' from 'origin'.
	Switched to a new branch 'v2020.10-bbb.io-am335x'
	$ git describe
	v2020.10-2-g2e37c17b0c

Please, continue building the U-boot from:

### Configure and Build (for both BBB and PB)
https://github.com/ZoranStojsavljevic/BeagleBoard-Workshop-Examples/blob/master/U-Boot_Porting_Guide/U-Boot_v2019.04_Porting_Guide.md#configure-and-build-for-both-bbb-and-pb
