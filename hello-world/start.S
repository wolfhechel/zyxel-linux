#include <asm/asm.h>
#include <asm/regdef.h>

.text
.global _start

_start:
    j loop

loop:
    li t0,0x3030

    lui v1,0x2E2E
    li v1,0x2E2E
    li v0, 0x0000
    lui v0,0xa861
    ori v0,v0,0xe00
    sw v1,(v0)

    j loop
