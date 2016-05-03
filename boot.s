.set noreorder
.set noat
.globl __start
__start:
#ifdef MACH_QEMU
  li $s0,0xbfd003F8
  sb $0,2($s0)      #Turn off FIFO
  li $t1,0x80
  sb $t1,3($s0)      #DLAB=1

  li $t1,1
  sb $t1,0($s0)      #DLL=1
  sb $0,1($s0)       #DLM=0

  li $t1,3
  sb $t1,3($s0)      #DLAB=0,8N1 Mode

  sb $0,1($s0)       #IER=0
  sb $0,4($s0)       #MCR=0
#endif

  li $s0,0xbfd00400

  li $t1,0xffffffff #gpio0 all output
  sw $t1,4($s0)
  li $t1,0x0        #gpio1 all input
  sw $t1,0xc($s0)

#ifndef MACH_QEMU
  lw $t2,0x8($s0) #read DIP switch
  li $t1,1
  and $t2,$t2,$t1
  beq $t1,$t2,flash2ram  #SW0 is high, FlashToRam mode
  nop
#endif

uart_cmd:
  li $t0,0x80000
  sw $t0,0($s0) #LED indicates wait state
  #get cmd
  jal getbyte
  nop

  or $s1,$v0,$zero
  #check cmd
  slti $t1,$s1,0x30
  bne $t1,$zero,bad_cmd
  li $t1,0x35
  slt $t1,$t1,$s1
  bne $t1,$zero,bad_cmd
  nop
  li $a0,0x7e
  jal putbyte
  nop

  li $t0,0x35
  beq $s1,$t0,uart2uart
  nop

  #get start address
  jal getword
  nop
  or $s2,$v0,$zero

  #cmd: run
  li $t0,0x34
  beq $s1,$t0,run
  nop

  #get word count
  jal getword
  nop
  beq $v0,$zero,uart_cmd #nothing to do
  or $s3,$v0,$zero

  li $t0,0x30
  beq $s1,$t0,uart2ram
  nop
  li $t0,0x31
  beq $s1,$t0,ram2uart
  nop
  li $t0,0x32
  beq $s1,$t0,uart2flash
  nop
  # li $t0,0x33
  # beq $s1,$t0,flash2uart
  # nop
bad_cmd:
  li $t0,0x80000000
  sw $t0,0($s0) #LED indicates unknown command
stop:
  b stop
  nop

run:
  jr $s2
  nop

flash2ram:
  b load_elf  #implemented in bootasm.S
  nop

uart2uart:
  jal getword
  nop
  or $a0,$zero,$v0
  sw $v0,0($s0) #LED indicates data
  jal putword
  nop
  b uart2uart
  nop

uart2ram:
  sll $s3,$s3,2
  addu $s3,$s3,$s2
uart2ram_next:
  sw $s2,0($s0) #LED indicates current address
  jal getword
  nop
  sw $v0,0($s2)
  addiu $s2,$s2,4
  bne $s3,$s2,uart2ram_next
  nop
  b uart_cmd
  nop

ram2uart:
  sll $s3,$s3,2
  addu $s3,$s3,$s2
ram2uart_next:
  sw $s2,0($s0) #LED indicates current address
  lw $a0,0($s2)
  jal putword
  nop
  addiu $s2,$s2,4
  bne $s3,$s2,ram2uart_next
  nop
  b uart_cmd
  nop

uart2flash:
  sll $s3,$s3,2
  addu $s3,$s3,$s2
uart2flash_next:
  sw $s2,0($s0) #LED indicates current address
  jal getword
  nop
  li $t0,0x40
  sw $t0,0($s2)
  nop
  sw $v0,0($s2)

  li $t0,0x70
wait_write:
  sw $t0,0($s2) #Command: read status
  nop
  lw $t1,0($s2)
  andi $t1,$t1,0x80
  beq $t1,$zero,wait_write
  nop
  addiu $s2,$s2,4
  bne $s3,$s2,uart2flash_next
  nop
  b uart_cmd
  nop

# flash2uart:
#   b uart_cmd
#   nop

getbyte:
  li $t0,0xbfd003f0
chk_rx:
#ifdef MACH_QEMU
  lb $t1,13($t0)  #LSR
  andi $t1,$t1,1
#else
  lw $t1,0xc($t0) #UART status
  andi $t1,$t1,2
#endif
  beq $t1,$0,chk_rx
  nop
  lb $v0,0x8($t0)
  jr $ra
  # sw $t1,0xc($t0) #clear received
  nop

putbyte:
  li $t0,0xbfd003f0
chk_tx:
#ifdef MACH_QEMU
  lb $t1,13($t0)
  andi $t1,$t1,0x20
#else
  lw $t1,0xc($t0)
  andi $t1,$t1,1
#endif
  beq $t1,$0,chk_tx
  nop
  jr $ra
  sb $a0,0x8($t0)

getword:
  li $t4,8
  li $t0,0xbfd003f0
chk_rx_w:
#ifdef MACH_QEMU
  lb $t1,13($t0)  #LSR
  andi $t1,$t1,1
#else
  lw $t1,0xc($t0) #UART status
  andi $t1,$t1,2
#endif
  beq $t1,$0,chk_rx_w
  nop
  lb $t2,0x8($t0)
  # sw $t1,0xc($t0) #clear received

  sll $t2,$t2,24
  srl $v0,$v0,8
  or $v0,$v0,$t2

  srl $t4,$t4,1
  bne $t4,$zero,chk_rx_w
  nop

  jr $ra
  nop

putword:
  li $t4,8
  li $t0,0xbfd003f0
chk_tx_w:
#ifdef MACH_QEMU
  lb $t1,13($t0)
  andi $t1,$t1,0x20
#else
  lw $t1,0xc($t0)
  andi $t1,$t1,1
#endif
  beq $t1,$0,chk_tx_w
  nop
  sb $a0,0x8($t0)
  srl $a0,$a0,8
  srl $t4,$t4,1
  bne $t4,$zero,chk_tx_w
  nop

  jr $ra
  nop

#include "bootasm.S"
