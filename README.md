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


The SAR module described in the architecture overview is actually a generic PDSP.


# AAL5 - ATM Adaption Layer 5
ATM Adaptation Layer 5 (AAL5) is an ATM adaptation layer used to send variable-length packets up to 65,535 octets in size across an Asynchronous Transfer Mode (ATM) network.

# AAL2 - ATM Adaption Layer 2
ATM Adaptation Layer 2 (AAL2) is an ATM adaptation layer for Asynchronous Transfer Mode (ATM), used primarily in telecommunications; for example, it is used for the Iu interfaces in the Universal Mobile Telecommunications System, and is also used for transporting digital voice. 

# SAR (Segmentation and Reassembly)
The ATM SAR module is configured to receive Internet Protocol packets and segment the IP packets into ATM cells.

# CPSAR (Communications Processor Segmentation And Reassembly)

# CPMAC (Communications Processor Media Access Control)
# Data Pump
???

# PDSP (Packed Data Structure Processor)

* 32-bit processor
* Simpler command set
* 32 work registers and 32 constants registers each 32-bit
* Bit, byte, word, and longword accesses
* Special commands for searching the registers
* Little and Big-Endian support
* Register <> Memory Block Transfer Commands
* Commands for communication with external processor
* Single-Cycle Branches
* Sleep function with wake-up function and waiting functions
* Macro assembler with preprocessor and structure support

PDSP seems to be an earlier version of the PRU. Both architectures uses the pasm toolset.
https://www.google.ch/patents/US6223277

## Assembly
* http://processors.wiki.ti.com/index.php/PRU_Assembly_Instructions
* https://sourceware.org/ml/binutils/2016-12/msg00483.html

# CPHAL (Communications Processor Hardware Abstraction Layer)


The Texas Instruments AR7 device (TNETD7300) is a fully integrated single-chip Asymmetric Digital Subscriber Line (ADSL) bridge/router solution, integrating a broadband communications processor and peripherals, ADSL physical layer, ADSL line driver, USB physical layer, Ethernet physical layer and power management for use in Customer Premise Endpoint (CPE) modems for residential and small-office applications. The TNETD7300 can be used in modems ranging from simple Ethernet bridges to integrated access devices (IADs) and Residential Gateways.
The TNETD7300 includes features to enhance ADSL throughput when connected to a compatible central office ADSL modem. ADSL+ provides downstream transmission rates far beyond the 12Mb/s limit of S=1/2. Extended-Reach (ERADSL) and All Digital Loop ADSL allow 384-kb/s/128-kb/s service to be provided on loops as long as 6.4km. These features allow the TNETD7300 to greatly surpass the downstream throughput limit of 8 Mb/s and the 5.3km reach limits generally seen in previous ADSL modems, thus granting ADSL service providers access to a larger subscriber pool without requiring replacement of the local loop infrastructure.
The TNETD7300 includes a new VLYNQ™ peripheral bus extension that allows VLYNQ-enabled devices to be gluelessly interfaced to TNETD7300 for advanced applications such as voice-over-packet (VOP) telephony or ADSL-to-WLAN (802.11) bridging and interfaces such as USB 2.0 and PCI.
Featuring
MIPS™ 32-Bit 160-MHz Reduced Instruction Set Computer (RISC) Processor
Two IEEE Std. 802.3 Ethernet Memory Access Controllers (MACs) With One External Media Independent Interface (MII)
– IEEE Std. 802.1p/q support
– 10-Mbit/s and 100-Mbit/s (half or full-duplex)
– Hardware flow control
– Address filtering (Unicast, Multicast, Broadcast, or Promiscuous Mode)
One Integrated IEEE Std. 802.3/802.3u Ethernet PHY
– 10-Mbit/s and 100-Mbit/s (half or full-duplex)
– Autonegotiation and parallel detect capability
Two VLYNQ™ High-Speed Point-to-Point Serial Interfaces
TMS320C62x™ ADSL PHY Subsystem with Integrated Transceiver, Coder/Decoder (Codec), Line Driver, and Line Receiver
– Single-Core DSP subsystem
– Integrated power management
– Supports most common POTS and ISDN ADSL standards and signaling methods
– ITU 992.1 (G.dmt) Annex A, B, C
– ITU 992.2 (G.lite)
– ITU 992.3 ADSL2 (G.dmt.bis)
– ITU 992.4 ADSL2 (G.lite.bis)
– ANSI T1.413 issue
– Includes ADSL+, Extended-Reach ADSL, All-Digital-Loop ADSL capabilities, Reed-Solomon with S = 1/2
Ethernet MII Serial Management Interface (MDIO) Flexible Universal Serial Bus (USB) Interface Function
– USB 1.1 compliant slave interface
One Flexible Serial Interface (FSER)
– Configurable as a UART with Software Flow Control or as an Inter-Integrated Circuit (IIC) Master Interface
One Four-Channel General-Purpose Direct-Memory Access (DMA) Engine
Reset Controller
Other Peripherals
– JTAG Test Access Port Controller for IEEE Std.1149 Boundary Scan
– Emulation JTAG (EJTAG) for MIPS
– DSP JTAG interface for debug
Device Packaged in 324-Terminal Thermally-Enhanced Plastic Ball Grid Array (GDW)
Asynchronous Transfer Mode (ATM) Segmentation and Reassembly (SAR) Sublayer
– ATM Adaptation Layer 5 (AAL5) and Operations, Administration and Management (OAM)
– ATM Adaptation Layer 0 (AAL0) support in hardware
– ATM Adaptation Layer 1, 3 and 4 (AAL1, AAL3/4) support via software
ATM Quality of Service (QoS)
– Programmable cell scheduling for AAL5 SAR
– Support for Constant Bit Rate (CBR), Real-Time Variable Bit Rate (VBR-rt), Non-Real-Time Variable Bit Rate (VBR-NRT), and Unspecified Bit Rate (UBR+)
ATM Transmission Convergence
– Automated Idle Cell-Based BERT
– Support for HDLC over ADSL
