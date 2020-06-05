.set noreorder
.set noat
.globl __start
.text
__start:
                            // .long 0x100000e3
    beq $0, $0, mips_begin  // MIPS32: Jump to mips_begin
                            // RISC-V: Jump to rv_begin
    nop

    // ======= MIPS32 ASM Begin =======
    .org 0x390
mips_begin:
    lui  $s0, 0x8001
    lw   $a0, 0($s0)      // Load the random number at 0x8001
    andi $a0, $a0, 0xFFFC
    or   $a0, $a0, $s0    // a0=(*s0 & 0xFFFC)|s0
                          // 0x80010000 <= a0 <= 0x8001FFFC
    ori  $t0, $0, 0x11    // magic number
    sw   $t0, 0($a0)
lwpc_1:
    lwpc $t0, sw_1        // t0=0xac8a0004
lwpc_2:
    lwpc $t1, lwpc_1      // t1=0xed080003
lwpc_3:
    lwpc $t2, lwpc_3      // t2=0xed480000
sw_1:
    sw   $t2, 0x4($a0)
    // Test other instructions
    xor  $t1, $t1, $a0
    srl  $t1, $t1, 4
    sw   $t1, 0x8($a0)
    addu $t0, $t0, $a0
    sll  $t0, $t0, 1
    sw   $t0, 0xc($a0)
mips_end:
    beq  $0, $0, mips_end
    nop
    // ======= MIPS32 ASM End =======

    // ======= RISC-V ASM Begin =======
    .org 0x900
rv_begin:
    .incbin "riscv_begin.bin"
/*
    li   s0, 0x80010000
    lw   a0, 0(s0)      // Load the random number at 0x8001
    li   t1, 0xFFFC
    and  a0, a0, t1
    or   a0, a0, s0     // a0=(*s0 & 0xFFFC)|s0
                        // 0x80010000 <= a0 <= 0x8001FFFC
    ori  t0, zero, 0x22 // magic number
    sw   t0, 0(a0)
lwpc_1:
    lwpc t0, sw_1     // t0=0x00752223
lwpc_2:
    lwpc t1, lwpc_1   // t1=0x003022ab
lwpc_3:
    lwpc t2, lwpc_3   // t2=0x000023ab
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
*/
    // ======= RISC-V ASM End =======

    // .org 0x10000
    // .long 0x55555555
