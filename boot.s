.set noreorder
.set noat
.globl __start
__start:
  li $s0,0xbfd03000
  sw $0,8($s0)       #Turn off FIFO
  li $t1,0x80
  sw $t1,0xc($s0)      #DLAB=1

  li $t1,54
  sw $t1,0($s0)      #DLL=54, 100000000/(16*115200)
  sw $0,4($s0)       #DLM=0

  li $t1,3
  sw $t1,0xc($s0)      #DLAB=0,8N1 Mode

  sw $0,4($s0)       #IER=0
  sw $0,0x10($s0)       #MCR=0

  li $s0,0xbfd01000

  li $t1,0xffffffff #gpio0 all output
  sw $t1,4($s0)
  li $t1,0x0        #gpio1 all input
  sw $t1,0xc($s0)

  lw $t2,0x8($s0) #read DIP switch
  li $t1,1
  and $t2,$t2,$t1
  beq $t1,$t2,flash2ram  #SW0 is high, FlashToRam mode
  nop

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
  li $t0,0x33
  beq $s1,$t0,flash2uart
  nop
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
  sll $s3,$s3,1
  addu $s3,$s3,$s2
uart2flash_next:
  sw $s2,0($s0) #LED indicates current address
  jal getword
  nop
  li $t0,0x40
  sh $t0,0($s2)
  nop
  sh $v0,0($s2)

  li $t0,0x70
wait_write:
  sh $t0,0($s2) #Command: read status
  nop
  lhu $t1,0($s2)
  andi $t1,$t1,0x80
  beq $t1,$zero,wait_write
  nop
  addiu $s2,$s2,2
  bne $s3,$s2,uart2flash_next
  nop
  b uart_cmd
  nop


flash2uart:
  li  $t0, 0xff
  sh  $t0, 0($s2)
  sll $s3,$s3,2
  addu $s3,$s3,$s2
flash2uart_next:
  sw $s2,0($s0) # LED indicates current address
  lhu $a0,0($s2) # 16-bit instruction is required for flash read
  lhu $t0,2($s2)
  sll $t0, $t0, 16
  or $a0, $a0, $t0
  jal putword
  nop
  addiu $s2,$s2,4
  bne $s3,$s2,flash2uart_next
  nop
  b uart_cmd
  nop

getbyte:
chk_rx:
  li $t0,0xbfd03000
  lw $t1,0x14($t0)  #LSR
  andi $t1,$t1,1
  beq $t1,$0,chk_rx
  nop
  lw $v0,0x0($t0)
  jr $ra
  # sw $t1,0xc($t0) #clear received
  nop

putbyte:
  li $t0,0xbfd03000
chk_tx:
  lw $t1,0x14($t0)  #LSR
  andi $t1,$t1,0x20
  beq $t1,$0,chk_tx
  nop
  jr $ra
  sw $a0,0x0($t0)

getword:
  li $t4,8
  li $t0,0xbfd03000
chk_rx_w:
  lw $t1,0x14($t0)  #LSR
  andi $t1,$t1,1
  beq $t1,$0,chk_rx_w
  nop
  lw $t2,0x0($t0)
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
  li $t0,0xbfd03000
chk_tx_w:
  lw $t1,0x14($t0)  #LSR
  andi $t1,$t1,0x20
  beq $t1,$0,chk_tx_w
  nop
  sw $a0,0x0($t0)
  srl $a0,$a0,8
  srl $t4,$t4,1
  bne $t4,$zero,chk_tx_w
  nop

  jr $ra
  nop

#include "bootasm.S"
