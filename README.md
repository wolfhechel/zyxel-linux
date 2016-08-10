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


## TODO

[ ] The ADM6996L isn't detected
[ ] BootBase PROM routines
[x] ADM6996L device driver
[ ] TIATM device driver
[ ] ar7-gpio: failed to add gpiochip
[ ] Fix early serial from decompression

## AR7 (TNETD7300) Features

MIPS™ 32-Bit 160-MHz Reduced Instruction Set
Computer (RISC) Processor
Two IEEE Std. 802.3 Ethernet Memory Access Controllers
(MACs) With One External Media Independent Interface
(MII)
– IEEE Std. 802.1p/q support
– 10-Mbit/s and 100-Mbit/s (half- or full-duplex)
– Hardware flow control
– Address filtering (Unicast, Multicast, Broadcast,
or Promiscuous Mode)
One Integrated IEEE Std. 802.3/802.3u Ethernet PHY
– 10-Mbit/s and 100-Mbit/s (half- or full-duplex)
– Autonegotiation and parallel detect capability
Two VLYNQ™ High-Speed Point-to-Point Serial
Interfaces
TMS320C62x™ ADSL PHY Subsystem with Integrated
Transceiver, Coder/Decoder (Codec), Line Driver, and
Line Receiver
– Single-Core DSP subsystem
– Integrated power management
– Supports most common POTS and ISDN ADSL
standards and signaling methods
– ITU 992.1 (G.dmt) Annex A, B, C
– ITU 992.2 (G.lite)
– ITU 992.3 ADSL2 (G.dmt.bis)
– ITU 992.4 ADSL2 (G.lite.bis)
– ANSI T1.413 issue
– Includes ADSL+, Extended-Reach ADSL, All-DigitalLoop
ADSL capabilities, Reed-Solomon with S = 1/2
Ethernet MII Serial Management Interface (MDIO)
Flexible Universal Serial Bus (USB) Interface
Function
– USB 1.1 compliant slave interface
One Flexible Serial Interface (FSER)
– Configurable as a UART with Software Flow Control
or as an Inter-Integrated Circuit (IIC) Master Interface
One Four-Channel General-Purpose Direct-Memory
Access (DMA) Engine
Reset Controller
Other Peripherals
– JTAG Test Access Port Controller for IEEE
Std.1149 Boundary Scan
– Emulation JTAG (EJTAG) for MIPS
– DSP JTAG interface for debug
Device Packaged in 324-Terminal Thermally-Enhanced
Plastic Ball Grid Array (GDW)
Asynchronous Transfer Mode (ATM) Segmentation
and Reassembly (SAR) Sublayer
– ATM Adaptation Layer 5 (AAL5) and Operations,
Administration and Management (OAM)
– ATM Adaptation Layer 0 (AAL0) support in hardware
– ATM Adaptation Layer 1, 3 and 4 (AAL1, AAL3/4)
support via software
ATM Quality of Service (QoS)
– Programmable cell scheduling for AAL5 SAR
– Support for Constant Bit Rate (CBR), Real-Time
Variable Bit Rate (VBR-rt), Non-Real-Time Variable Bit
Rate (VBR-NRT), and Unspecified Bit Rate (UBR+)
ATM Transmission Convergence
– Automated Idle Cell-Based BERT
– Support for HDLC over ADSL


## Short facts of the AR7
- Supposedly 32 GPIO's on the chip
- Has two JTAG interfaces, EJTAG for the MIPS CPU and a JTAG for the TMS320C62x DSP.
- 
