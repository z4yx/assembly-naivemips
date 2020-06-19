.set noreorder
.set noat

#define BOARD_THINROUTER

.globl __start
__start:
    
    li $k0, 0
    li $s0,0xbfd00400

    li $t1,0xffffffff #gpio0 all output
    sw $t1,4($s0)
    li $t1,0x0        #gpio1 all input
    sw $t1,0xc($s0)

    jal memtest
    or  $v0, $0, $0 #default success
    beq $v0, $0, pass_mem
    nop
    ori $k0, $k0, 1
#     li $t0, 0xec120000  #DPY="E1"
#     sw $t0, 0($s0)
# fail_mem:
#     b fail_mem
#     nop

pass_mem:
    jal flash_test
    or  $v0, $0, $0 #default success
    beq $v0, $0, pass_flash
    nop
    ori $k0, $k0, 2
#     li $t0, 0xecbc0000  #DPY="E2"
#     sw $t0, 0($s0)
# fail_flash:
#     b fail_flash
#     nop

pass_flash:
    jal eth_test
    or  $v0, $0, $0 #default success
    beq $v0, $0, pass_eth
    nop
    ori $k0, $k0, 4
#     li $t0, 0xecb60000  #DPY="E3"
#     sw $t0, 0($s0)
# fail_eth:
#     b fail_eth
#     nop

pass_eth:
    jal usb_test
    or  $v0, $0, $0 #default success
    beq $v0, $0, pass_usb
    nop
    ori $k0, $k0, 8
#     li $t0, 0xecd20000  #DPY="E4"
#     sw $t0, 0($s0)
# fail_usb:
#     b fail_usb
#     nop

pass_usb:
    bne $k0,$0,show_error
    li $t0, 0x7e7e0000  #DPY="00"
    b test_other
    sw $t0, 0($s0)
show_error:
    li $t0, 0xecec0000  #DPY="EE"
    or $t0,$k0,$t0
    sll $k0,$k0,8
    xori $k0,$k0,0xff00
    or $t0,$k0,$t0
    sw $t0, 0($s0)
#    b show_error
#    nop

test_other:
    jal vga
    nop

    lw $s3,0x8($s0) #get initial DIP switch state
test_other_loop:
    jal echo
    nop
    jal disp
    nop
    b test_other_loop
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
    lw $t2,0x8($s0) #get DIP switch state
    beq $s3,$t2,disp_ret #do not update display until switch changed
    nop
    sw $t2,0($s0)   #set LED
    or $s3,$0,$t2
disp_ret:
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

#ifdef BOARD_THINROUTER
usb_test:
    li $s2, 0xbc020200 # SPI Ctl
    or $s1,$ra,$zero
    li $t0, 1
    sw $t0, 4($s2) # Chip Select
    
    li $t0, 0x8006
    jal delay_1500ns
    sw $t0, 0($s2)
    
    li $t0, 0x8057
    jal delay_1500ns
    sw $t0, 0($s2)
    
    li $t0, 0x80FF
    sw $t0, 0($s2)
usb_wait_spi:
    lw $t0, 0($s2)
    andi $t1, $t0, 0x4000 # Busy bit
    bne $zero, $t1, usb_wait_spi
    nop

    sw $t0, 0($s0)
    xori $t0, $t0, 0xA8
    li $v0, 1
    movz $v0, $zero, $t0

    sw $zero, 4($s2) # Chip Select
    or $ra,$s1,$zero
    jr $ra
    nop
delay_1500ns:
    li $t1, 50
    li $t2, 1
dly_repeat:
    bne $zero, $t1, dly_repeat
    subu $t1, $t1, $t2
    jr $ra
    nop

eth_test:
    li $s2, 0xbc020200 # SPI Ctl
    or $s1,$ra,$zero
    li $t0, 2
    sw $t0, 4($s2) # Chip Select
    
    li $t0, 0x8050
    jal eth_wait_spi
    sw $t0, 0($s2)
    
    li $t0, 0x8000
    jal eth_wait_spi
    sw $t0, 0($s2)

    li $t0, 0x80FF
    jal eth_wait_spi
    sw $t0, 0($s2)

    lw $t1, 0($s2)
    xori $t1, $t1, 0x87
    li $v0, 1
    movz $v0, $zero, $t1

    sw $zero, 4($s2) # Chip Select
    or $ra,$s1,$zero
    jr $ra
    nop
eth_wait_spi:
    lw $t0, 0($s2)
    andi $t1, $t0, 0x4000 # Busy bit
    bne $zero, $t1, eth_wait_spi
    nop
    jr $ra
    nop
#else
usb_test:
    li $s2, 0xbc020000

    li $t0, 0x0e
    sb $t0, 0($s2)
    lbu $t1, 4($s2) #Rev

    li $t2, 0x20
    beq $t2,$t1,usb_correct
    nop
    jr $ra
    li $v0, 1

usb_correct:
    jr $ra
    li $v0, 0


eth_test:
    li $s2, 0xbc020100

    li $t0, 0x29
    sb $t0, 0($s2)
    lbu $t1, 4($s2) #VIDH
    sll $t1, $t1, 8
    li $t0, 0x28
    sb $t0, 0($s2)
    lbu $t2, 4($s2) #VIDL
    or  $t1, $t1, $t2
    sll $t1, $t1, 8
    li $t0, 0x2b
    sb $t0, 0($s2)
    lbu $t2, 4($s2) #PIDH
    or  $t1, $t1, $t2
    sll $t1, $t1, 8
    li $t0, 0x2a
    sb $t0, 0($s2)
    lbu $t2, 4($s2) #PIDL
    or  $t1, $t1, $t2

    li $t2, 0x0a469000
    beq $t2,$t1,eth_correct
    nop
    jr $ra
    li $v0, 1

eth_correct:
    jr $ra
    li $v0, 0
#endif

flash_test:
    or $s1,$ra,0
    li $s2, 0xbe000000

    li $t0, 0x90
    sh $t0, 0($s2)
    lhu $t1, 0($s2) #Manufacture code
    li $t2, 0x89
    bne $t2, $t1, wrong_maf_code
    nop

    sh $t0, 0($s2)
    lhu $t1, 2($s2) #Device code
    li $t2, 0x17
    bne $t2, $t1, wrong_dev_code
    nop

#    li $t0, 0x60
#    li $t1, 0xd0
#    sh $t0, 0($s2)
#    sh $t1, 0($s2) #Clear Lock
#    jal wait_ready
#    nop

#    li $t0, 0x20
#    li $t1, 0xd0
#    sh $t0, 0($s2)
#    sh $t1, 0($s2) #erase block 0
#    jal wait_ready
#    nop

#    li $t0, 0xff
#    sh $t0, 0($s2)
#    lhu $t0, 0($s2)
#    li $t1, 0xffff
#    bne $t0, $t1, erase_fail
#    nop

#    li $t0, 0x40
#    li $t1, 0x55aa
#    sh $t0, 0($s2) 
#    sh $t1, 0($s2) #byte program
#    jal wait_ready
#    nop

    li $t0, 0xff
    sh $t0, 0($s2)
#    lhu $t0, 0($s2)
#    li $t1, 0x55aa
#    bne $t0, $t1, prog_fail
#    nop
    or $ra,$s1,0
    jr $ra
    li $v0, 0
wrong_dev_code:
wrong_maf_code:
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
