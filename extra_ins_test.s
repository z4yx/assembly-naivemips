.set noreorder
.set noat
.globl __start
.text
__start:
    li $s0, 0x80100000
    li $s1, 0
    li $s2, 1
    lw $a1, 4($s0) # selection
    lw $a2, 8($s0) # random
    addi $v1, $s0, 0x10 # v1 = s0 + 0x10
t_clo:
    andi $t0, $a1, 1
    beq $t0, $0, t_clz # skip test
    nop
    lui $t1, 0xFFF0
    clo $t1, $t1
    li  $t2, 12
    bne $t1, $t2, t_clz
    nop
    li  $t1, 0x7
    clo $t2, $t1
    bne $t2, $0, t_clz
    nop
    lui $t1, 0xFFFF
    xor $t1, $a2, $t1
    clo $t1, $t1
    sw $t1, 0($v1) # *v1 = clo(a2^0xFFFF0000)
    addi $v1, $v1, 4
    ori $s1, $s1, 1
t_clz:
    andi $t0, $a1, 2
    beq $t0, $0, t_lbu # skip test
    nop
    lui $t1, 0x0001
    clz $t1, $t1
    li  $t2, 15
    bne $t1, $t2, t_lbu
    nop
    li  $t1, 32
    clz $t2, $0
    bne $t2, $t1, t_lbu
    nop
    clz $t1, $a2
    sw $t1, 0($v1) # *v1 = clz(a2)
    addi $v1, $v1, 4
    ori $s1, $s1, 2
t_lbu:
    andi $t0, $a1, 4
    beq $t0, $0, t_lh # skip test
    nop
    li  $t1, 0xa1b2c3d4
    sw  $t1, 0x100($s0)
    lbu $t1, 0x100($s0)
    li  $t2, 0xd4
    bne $t1, $t2, t_lh
    nop
    lbu $t1, 0x101($s0)
    li  $t2, 0xc3
    bne $t1, $t2, t_lh
    nop
    lbu $t1, 0x102($s0)
    li  $t2, 0xb2
    bne $t1, $t2, t_lh
    nop
    lbu $t1, 0x103($s0)
    li  $t2, 0xa1
    bne $t1, $t2, t_lh
    nop

    lbu $t1, 9($s0)
    sw $t1, 0($v1)
    addi $v1, $v1, 4
    ori $s1, $s1, 4
t_lh:
    andi $t0, $a1, 8
    beq $t0, $0, t_movn # skip test
    nop
    li  $t1, 0x01b283d4
    sw  $t1, 0x100($s0)
    lh $t1, 0x102($s0)
    li  $t2, 0x01b2
    bne $t1, $t2, t_movn
    nop
    lh $t1, 0x100($s0)
    li  $t2, 0xFFFF83d4
    bne $t1, $t2, t_movn
    nop
    lh $t1, 0xa($s0)
    sw $t1, 0($v1)
    addi $v1, $v1, 4
    ori $s1, $s1, 8
t_movn:
    andi $t0, $a1, 16
    beq $t0, $0, t_movz # skip test
    nop
    li $t1, 2
    li $t2, 2
    movn $t2, $0, $0
    bne $t1, $t2, t_movz
    nop
    movn $t2, $0, $t2
    bne $0, $t2, t_movz
    nop
    xori $t1, $a2, 0x5555
    andi $t2, $a2, 1
    movn $t1, $a2, $t2
    sw $t1, 0($v1) # *v1 = a2 & 1 ? a2 : a2^0x5555
    addi $v1, $v1, 4
    ori $s1, $s1, 16
t_movz:
    andi $t0, $a1, 32
    beq $t0, $0, t_nor # skip test
    nop
    li $t1, 2
    li $t2, 2
    movz $t2, $0, $t2
    beq $0, $t2, t_nor
    nop
    movz $t2, $0, $0
    beq $t1, $t2, t_nor
    nop
    xori $t1, $a2, 0xAAAA
    andi $t2, $a2, 1
    movz $t1, $a2, $t2
    sw $t1, 0($v1) # *v1 = a2 & 1 ? a2^0xAAAA : a2
    addi $v1, $v1, 4
    ori $s1, $s1, 32
t_nor:
    andi $t0, $a1, 64
    beq $t0, $0, t_sra # skip test
    nop
    li $t2, 0xFFFFFFFF
    nor $t1, $0, $0
    bne $t1, $t2, t_sra
    nop
    nor $t1, $t1, $0
    bne $t1, $0, t_sra
    nop

    li $t1, 0xAAA0055F
    nor $t1, $a2, $t1
    sw $t1, 0($v1) # *v1 = ~(a2 | 0xAAA0055F)
    addi $v1, $v1, 4
    ori $s1, $s1, 64
t_sra:
    andi $t0, $a1, 128
    beq $t0, $0, t_srlv # skip test
    nop
    li  $t2, 0x80000000
    lui $t3, 0xFFFF
    sra $t1, $t2, 0
    bne $t1, $t2, t_srlv
    nop
    sra $t1, $t2, 15
    bne $t1, $t3, t_srlv
    nop
    sra $t1, $t2, 31
    sra $t3, $t3, 16
    bne $t1, $t3, t_srlv
    nop
    lui $t3, 0x7FFF
    li  $t1, 0x7FFF
    sra $t3, $t3, 16
    bne $t1, $t3, t_srlv
    nop

    li $t2, 0x80000000
    or $t2, $a2, $t2
    sra $t1, $t2, 16
    sw $t1, 0($v1) # *v1 = (a2 | 0x80000000) >> 16
    addi $v1, $v1, 4
    ori $s1, $s1, 128
t_srlv:
    andi $t0, $a1, 256
    beq $t0, $0, t_subu # skip test
    nop
    li $t2, 0x80000000
    li $t1, 0x1004
    srlv $t1, $t2, $t1
    li $t2, 0x08000000
    bne $t1, $t2, t_subu
    nop
    li $t1, 32 # tricky
    srlv $t3, $t2, $t1
    bne $t3, $t2, t_subu
    nop

    srlv $t1, $a2, $a2
    sw $t1, 0($v1) # *v1 = a2 >>> (a2 & 31)
    addi $v1, $v1, 4
    ori $s1, $s1, 256
t_subu:
    andi $t0, $a1, 512
    beq $t0, $0, tret # skip test
    nop
    li $t2, 0x80000000
    li $t1, 0x10000
    subu $t3, $t2, $t1
    li $t1, 0x7FFF0000
    bne $t1, $t3, tret
    nop
    li $t2, 0xFFFFFFFF
    addi $t3, $t1, 1
    subu $t1, $t1, $t2
    bne $t1, $t3, tret
    nop

    li $t2, 0x5555
    subu $t1, $a2, $t2
    sw $t1, 0($v1) # *v1 = a2 - 0x5555
    addi $v1, $v1, 4
    ori $s1, $s1, 512
tret:
    lui $v0, 0xfeed
    or $v0, $v0, $s1
    xor $v0, $v0, $a2
    sw $v0, 0($s0)
    sw $v1, 0xc($s0) # *(s0+0xc) = v1
end:
    j  end
    nop
    #.org 0x100000
    #.long 0x55555555
    #.long 0x3ff
    #.long 0x12345678
