   .set noat
   .set noreorder
   .global __start
__start:
    li $s1,0xbfd00400

    li $t1,0xffffffff #gpio0 all output
    sw $t1,4($s1)
    li $t1,0x0        #gpio1 all input
    sw $t1,0xc($s1)

    li  $s0,0x80010000
    li  $a0,0x12345678

    sw $a0,0($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop
    lbu $t0,0($s0)
    jal show_and_wait
    nop
    lbu $t0,1($s0)
    jal show_and_wait
    nop
    lbu $t0,2($s0)
    jal show_and_wait
    nop
    lbu $t0,3($s0)
    jal show_and_wait
    nop
    lh $t0,0($s0)
    jal show_and_wait
    nop
    lh $t0,2($s0)
    jal show_and_wait
    nop

    li $a0,0x9a
    sw $0,0($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop
    sb $a0,0($s0)
    addi $a0,$a0,1
    sb $a0,1($s0)
    addi $a0,$a0,1
    sb $a0,2($s0)
    addi $a0,$a0,1
    sb $a0,3($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop

    addi $a0,$a0,1
    sb $a0,0($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop
    addi $a0,$a0,1
    sb $a0,1($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop
    addi $a0,$a0,1
    sb $a0,2($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop
    addi $a0,$a0,1
    sb $a0,3($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop

    li $a0,0xbcde
    sh $a0,0($s0)
    li $a0,0xf012
    sh $a0,2($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop

    li $a0,0xface
    sh $a0,0($s0)
    lw $t0,0($s0)
    li $a0,0xdead
    sh $a0,2($s0)
    lw $t0,0($s0)
    jal show_and_wait
    nop

    _loop:
    b _loop
    nop

show_and_wait: 
    lw $t5,0x8($s1) #get DIP switch state
    sw $t0,0($s1)   #set LED
wait_:
    lw $t6,0x8($s1) #get DIP switch state
    beq $t5,$t6,wait_
    nop
    jr $ra
    nop
