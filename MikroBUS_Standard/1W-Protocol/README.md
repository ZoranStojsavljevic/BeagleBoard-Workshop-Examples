## 1W Protocol
https://developer.electricimp.com/resources/onewire

### Multiple Devices

#### Unique factory-programmed 64-bit ID number

Each 1-Wire device has a unique, unalterable and factory-programmed 64-bit ID number which serves as
its address on the 1-Wire bus. The ID comprises an 8-bit ‘family’ ID, a 48-bit serial number and an
8-bit CRC checksum. This ID is used to locate a specific device on the bus: the host searches through
every device’s ID by comparing the bits that make up those IDs, LSB first.

##### Features/Benefits

	Each 1-Wire slave has stored in ROM a unique 64-bit serial number that acts as its node address
	device to be individually selected from among many that can be connected to the same bus wire
	This globally unique address is composed of eight bytes divided into three main sections.

	Starting with the LSB, the first byte stores the 8-bit family codes that identify the device
	type.

	The next six bytes store a customizable 48-bit individual address.

	The last byte, the most significant byte (MSB), contains a cyclic redundancy check (CRC) with a
	value based on the data contained in the first seven bytes.

This allows the master to determine if an address was read without error. With a 2^48 serial number
pool, conflicting or duplicate node addresses on the net are never a problem.

##### !W protocol slave device id example

	[    5.054606] w1_master_driver w1_bus_master1: Attaching one wire slave ac.22222211ccbb crc 22

#### Standard 1-Wire search algorithm

All the devices with a 0 at a certain digit in their ID can be separated from those with a 1 at that
point. In the standard 1-Wire search algorithm, if we write a 0, say, all devices with an address
that has a 1 at the current digit will ignore any future bus activity until the bus is reset.

Now the remaining devices are compared, this time using the next bit in sequence. Again, only those
devices that share the value of that bit are kept in play; the rest join those already offline.
The process repeats until the host is left with a single device. Any remaining bits in the ID are
read to provide the host with that device’s full ID.

With one device’s ID known, this value can be saved, and the host repeats the search pattern as many
times as necessary to find the IDs of all the remaining devices.
