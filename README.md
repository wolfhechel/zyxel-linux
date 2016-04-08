# Zyxel Firmware

## BootBase
The BootBase code is the initial boot code loaded from the base ROMIO mapped address ($ROM:BootBas).
This code is executed straight after the device has been powered on. Its primary object is (probably?) to setup interrupts, setup some sane configurations for the CPU and to load the BootExtension code from $ROM:BootExt.


## BootExtension
The BootExtension code is an extension to BootBase, this is the code that performs the DRAM POST Testing and provides the initial user interface against the serial port.

After DRAM POST Testing the BootExtension allows a user connected to the serial port to enter debug mode. This is a primitive prompt that provides some basic AT commands (See full list below).

If the debug mode does not enter the device continues to load code from $ROM:RASCode into $RAM:RASCode and continues execution (See Loading compressed images for full procedure).

### Loading compressed images
The BootExtension code has the possibility to load a compressed image into it's main execution address, the compression algorithm varies between LZMA on some older firmwares and GZIP on more recent versions.

The BootExt command ATSD loads a named compressed image from $RAM into its respective table entry in $ROM, default examples for these are HTPCode and RASCode.

So for HTPCode it would decompress $ROM:HTPCode (0xb0028000) into $RAM:HTPCode (0x9402000).

## (HTPCode) Hardware Test Program
The Hardware Test Program is an extended POST procedure that performs sanity checks on the hardware against the configuration entries stored in $USER section.

A user can in debug mode tell the device to by default load the HTPCode on boot rather than the RASCode (which is factory default).

## (RASCode) Remote Access Service

The RASCode is the actual system which sets up the Remote Access Services (depending on the firmware this could be a HTTP Web, Telnet or in some cases even SSH service).

The RASCode appears to be doing much more however then just starting these services, since the entire OS is based in RASCode it would also start the system itself which would cause to load the tiadsl and tiwlan devices firmwares from $ROM.

## Firmware layout:

### $RAM section
Holds references and memory addresses to where certain data should and has been loaded.

#### 0: BootExt(RAMBOOT) BootExtension (0x94008000)
This is where the BootExtension code has been loaded into.

#### 1: HTPCode(RAMCODE) Hardware Test Program (0x94020000)
Tells BootExt where to load the Hardware Test Program located in $ROM:HTPCode.

#### 2: RASCode(RAMCODE) Remote Access Service (0x94020000)
This shares the same memory address as HTPCode due to the fact that
the code at debug mode has not yet been loaded.
Triggering the bootup process (ATGR) loads the code from $ROM:RASCode
into the memory address, then starts executing the code.

### $ROM section
Holds references and a memory map table to the different objects stored
in Flash.

### $USER section
This section appears to be holding variables used to configure
the system on boot.

## Memory Mapping

### 0xBFC00000 - On-chip 4Kb PROM

### 0x80000000 - On-chip 4Kb RAM

### 0x???????? - DSP

### 0x90000000 - CS0 (FLASH)

### 0x94000000 - CS1 (RAM)
