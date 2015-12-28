.set noreorder
.set noat
.globl __start
__start:
  li $s0, 0x80000000
  sb $0, 1($s0)
  li $s0, 0xbe000000
  li $t0, 0x90
  sw $t0, 0($s0)
  lw $t1, 0($s0) #Manufacture code

  sw $t0, 0($s0)
  lw $t1, 4($s0) #Device code

  li $t0, 0x20
  li $t1, 0xd0
  sw $t0, 0($s0)
  sw $t1, 0($s0)

  jal wait_ready
  nop
  li $t3, 0xbeef

  li $t0, 0xff
  sw $t0, 0($s0)
  lw $t0, 0($s0)
stop:
  b stop
  nop

wait_ready:
  li $t0, 0x70
  sw $t0, 0($s0)
  lw $t1, 0($s0)
  andi $t1,$t1,0x80
  beq $t1,$0,wait_ready
  nop
  jr $ra
  nop