.globl _start
.section .text
_start:
                            // .long 0x100000e3
    beq zero, zero, rv_begin// MIPS32: Jump to mips_begin
                            // RISC-V: Jump to rv_begin
    nop

    .org 0x390
mips_begin:

    .org 0x900
rv_begin:
    li   s0, 0x80010000
    lw   a0, 0(s0)      // Load the random number at 0x8001
    li   t1, 0xFFFC
    and  a0, a0, t1
    or   a0, a0, s0     // a0=(*s0 & 0xFFFC)|s0
                        // 0x80010000 <= a0 <= 0x8001FFFC
    ori  t0, zero, 0x22 // magic number
    sw   t0, 0(a0)
lwpc_1:
    // lwpc t0, sw_1     // t0=0x00752223
    .long 0x3022ab
lwpc_2:
    // lwpc t1, lwpc_1   // t1=0x003022ab
    .long 0xfff0232b
lwpc_3:
    // lwpc t2, lwpc_3   // t2=0x000023ab
    .long 0x23ab
sw_1:
    sw   t2, 0x4(a0)
    // Test other instructions
    xor  t1, t1, a0
    srli t1, t1, 4
    sw   t1, 0x8(a0)
    add  t0, t0, a0
    slli t0, t0, 1
    sw   t0, 0xc(a0)
rv_end:
    beq  zero, zero, rv_end

    // .org 0x10000
    // .long 0x55555555