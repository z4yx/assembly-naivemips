.set noreorder
.set noat
.globl __start
__start:
    
    li $s0,0xbfd00400

    li $t1,0xffffffff #gpio0 all output
    sw $t1,4($s0)
    li $t1,0x0        #gpio1 all input
    sw $t1,0xc($s0)

    jal vga
    nop

    jal memtest
    nop
    beq $v0, $0, pass_mem
    nop
    li $t0, 0xec120000  #DPY="E1"
    sw $t0, 0($s0)
fail_mem:
    b fail_mem
    nop

pass_mem:
    jal flash_test
    nop
    beq $v0, $0, pass_flash
    nop
    li $t0, 0xecbc0000  #DPY="E2"
    sw $t0, 0($s0)
fail_flash:
    b fail_flash
    nop

pass_flash:
test_other:
    jal echo
    nop
    jal disp
    nop
    b test_other
    nop


memtest:
    li $t3, 0x80000400 #RAM start address
    li $t1, 0x80800000 #RAM end address
    li $t5, 1103515245
    li $t4, 0xdeadbeef
    or $t0, $0, $t3
wr_mem:
    mul $t4,$t4,$t5
    addiu $t4,$t4,12345
    sw $t4, 0($t0)
    sw $t0, 0($s0)
    addiu $t0,$t0,4
    bne $t0,$t1,wr_mem
    nop
    or $t0, $0, $t3
    li $t5, 1103515245
    li $t4, 0xdeadbeef
rd_mem:
    mul $t4,$t4,$t5
    addiu $t4,$t4,12345
    lw $t2, 0($t0)
    sw $t0, 0($s0)
    bne $t2,$t4,wrong
    nop
    addiu $t0,$t0,4
    bne $t0,$t1,rd_mem
    nop
    jr $ra
    li $v0, 0
wrong:
    jr $ra
    li $v0, 1

vga:
    li $t1, 0xbb00ea60
    li $t2, 0xbb000000
vga_loop:
    and $t3, $t2, 4
    sll $t3, $t3, 29 #shift to symbol bit
    sra $t3, $t3, 31 #fill word
    sw  $t3, 0($t2)
    addiu $t2,$t2,4
    bne $t2, $t1, vga_loop
    nop
    jr $ra
    nop

disp: 
    addiu $s3,$s3,1
    srl $t0,$s3,17
    andi $t0,$t0,1
    subu $t0,$0,$t0
    lw $t2,0x8($s0) #get DIP switch state
    xor $t2,$t2,$t0
    sw $t2,0($s0)   #set LED
    jr $ra
    nop

echo:
    or $s1,$ra,0
    jal getbyte
    nop
    beq $v1,$0,echo_ret
    nop
    jal putbyte
    or  $a0,$v0,$0
echo_ret:
    or $ra,$s1,0
    jr $ra
    nop


getbyte:
    li $t0,0xbfd003f0
chk_rx:
    lw $t1,0xc($t0) #UART status
    andi $t1,$t1,2
    beq $t1,$0,nothing
    nop
    lb $v0,0x8($t0)
    jr $ra
    li $v1,1
nothing:
    jr $ra
    li $v1,0


putbyte:
    li $t0,0xbfd003f0
chk_tx:
    lw $t1,0xc($t0)
    andi $t1,$t1,1
    beq $t1,$0,chk_tx
    nop
    jr $ra
    sb $a0,0x8($t0)

flash_test:
    or $s1,$ra,0
    li $s2, 0xbe000000

    li $t0, 0x90
    sh $t0, 0($s2)
    lhu $t1, 0($s2) #Manufacture code

    sh $t0, 0($s2)
    lhu $t1, 2($s2) #Device code

    li $t0, 0x60
    li $t1, 0xd0
    sh $t0, 0($s2)
    sh $t1, 0($s2) #Clear Lock
    jal wait_ready
    nop

    li $t0, 0x20
    li $t1, 0xd0
    sh $t0, 0($s2)
    sh $t1, 0($s2) #erase block 0
    jal wait_ready
    nop

    li $t0, 0xff
    sh $t0, 0($s2)
    lhu $t0, 0($s2)
    li $t1, 0xffff
    bne $t0, $t1, erase_fail
    nop

    li $t0, 0x40
    li $t1, 0x55aa
    sh $t0, 0($s2) 
    sh $t1, 0($s2) #byte program
    jal wait_ready
    nop

    li $t0, 0xff
    sh $t0, 0($s2)
    lhu $t0, 0($s2)
    li $t1, 0x55aa
    bne $t0, $t1, prog_fail
    nop
    or $ra,$s1,0
    jr $ra
    li $v0, 0
erase_fail:
prog_fail:
time_fail:
    or $ra,$s1,0
    jr $ra
    li $v0, 1

wait_ready:
    li $t2, 0xfffff
    li $t3, 1
wait_loop:
    beq $t2, $0, time_fail
    li $t0, 0x70
    sh $t0, 0($s2)
    lhu $t1, 0($s2)
    andi $t1,$t1,0x80
    beq $t1,$0,wait_loop
    sub $t2, $t2, $t3
    jr $ra
    nop