.set noreorder
.set noat
.globl __start
.text
__start:
    li $s0, 0x80100000
    li $s1, 0
    li $s2, 1
    lw $a1, 4($s0) # selection
t_clo:
    andi $t0, $a1, 1
    beq $t0, $0, t_clz
    nop
t_clz:
    andi $t0, $a1, 2
    beq $t0, $0, t_lbu
    nop
t_lbu:
    andi $t0, $a1, 4
    beq $t0, $0, t_lh
    nop
t_lh:
    andi $t0, $a1, 8
    beq $t0, $0, t_movn
    nop
t_movn:
    andi $t0, $a1, 16
    beq $t0, $0, t_movz
    nop
t_movz:
    andi $t0, $a1, 32
    beq $t0, $0, t_nor
    nop
t_nor:
    andi $t0, $a1, 64
    beq $t0, $0, t_sra
    nop
t_sra:
    andi $t0, $a1, 128
    beq $t0, $0, t_srlv
    nop
t_srlv:
    andi $t0, $a1, 256
    beq $t0, $0, t_subu
    nop
t_subu:
    andi $t0, $a1, 512
    beq $t0, $0, tret
    nop
tret:
    lw $a2, 8($s0)
    lui $v0, 0xfeed
    or $v0, $v0, $s1
    xor $v0, $v0, $a2
    sw $v0, 0($s0)
end:
    j  end
    nop
