.set noreorder
.set noat
.globl __start
__start:
  li $a0,0xbfd00400
  li $a1,0xffffffff #gpio0 all output
  sw $a1,4($a0)
  sw $0,0($a0)
  li $s0, 0x80000400 #start
  li $s1, 0x80040000 #end
  li $s2, 0x4 #stride
re:
  or $t0,$s0,$0
wr_mem:
  sw $t0, 0($t0)
  addu $t0,$t0,$s2
  bne $t0,$s1,wr_mem
  nop
  b re
  nop
  or $t0,$s0,$0
rd_mem:
  lw $t2, 0($t0)
  bne $t2,$t0,wrong
  nop
  addu $t0,$t0,$s2
  bne $t0,$s1,rd_mem
  nop
  li $t0,0xffffffff
wrong:
  li $a0,0xbfd00400
  sw $t0,0($a0)
  b wrong
  nop