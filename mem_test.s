.set noreorder
.set noat
.globl __start
__start:
  li $a0,0xbfd00400
  li $a1,0xffffffff #gpio0 all output
  sw $a1,4($a0)
  sw $0,0($a0)
  li $s0, 0x80000200 #start, skip space of program itself
  li $s1, 0x80800000 #end
  li $s2, 0x4 #stride
re:
  or $t0,$s0,$0
  li $t3,0xdeadbeef
  li $t4,1103515245
wr_mem:
  sw $t3, 0($t0)
  mul $t3,$t3,$t4
  addiu $t3,$t3,12345
  addu $t0,$t0,$s2
  bne $t0,$s1,wr_mem
  nop

  or $t0,$s0,$0
  li $t3,0xdeadbeef
  li $t4,1103515245
rd_mem:
  lw $t2, 0($t0)
  bne $t2,$t3,wrong
  nop
  mul $t3,$t3,$t4
  addiu $t3,$t3,12345
  addu $t0,$t0,$s2
  bne $t0,$s1,rd_mem
  nop
  li $t0,0xffffffff
wrong:
  li $a0,0xbfd00400
  sw $t0,0($a0)
  b wrong
  nop