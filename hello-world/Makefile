#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

PROG := hello-world

OBJS := start.o

CROSS_COMPILE = mips-linux-musl-

CFLAGS :=

CC =       $(CROSS_COMPILE)gcc
LD =       $(CROSS_COMPILE)ld
OBJDUMP =  $(CROSS_COMPILE)objdump
OBJCOPY = $(CROSS_COMPILE)objcopy -O binary -R .reginfo -R .note -R .comment -R .mdebug -S

all: $(PROG)

.S.o:
	$(CC) $(CFLAGS) -c $< -o $*.o

$(PROG).elf: $(OBJS)
	$(LD) -s -Tlinker.lds -o $@ $^

$(PROG): $(PROG).elf
	$(OBJCOPY) $< $@

clean:
	rm -f *.o $(PROG)

.INTERMEDIATE: $(PROG).elf
