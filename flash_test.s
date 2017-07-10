.set noreorder
.set noat
.globl __start
__start:
  li $s1, 0xbfd00400
  li $s0, 0xbe000000

  li $t0,0xffffffff #gpio0 all output
  sw $t0,4($s1)

  li $t0, 0x90
  sh $t0, 0($s0)
  lhu $t1, 0($s0) #Manufacture code

  sh $t0, 0($s0)
  lhu $t1, 4($s0) #Device code

  or $a0, $0, $s0
  li $a1, 262144
  sll $a2,$a1,6
  addu $a2,$a2,$s0
erase_next:
  li $t0, 0x20
  li $t1, 0xd0
  sh $t0, 0($a0)
  sh $t1, 0($a0)
  sh $a0, 0($s1)
  jal wait_ready
  addu $a0,$a0,$a1
  bne $a0,$a2,erase_next
  nop
  li $t3, 0xbeef

  li $t0, 0xff
  sh $t0, 0($s0)
  lhu $t0, 0($s0)
stop:
  b stop
  nop

wait_ready:
  li $t0, 0x70
  sh $t0, 0($s0)
  lhu $t1, 0($s0)
  andi $t1,$t1,0x80
  beq $t1,$0,wait_ready
  nop
  jr $ra
  nop