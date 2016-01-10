.set noreorder
.set noat
.globl __start
__start:
  li $t7, 0xfaceface
  li $t1, 0xa0000100
  sw $t7, 0($t1)
  lw $t7, 0($t1)
  li $t0, 0x80000100
  li $t1, 0x80002000
wr_mem:
  sw $t0, 0($t0)
  addiu $t0,$t0,4
  bne $t0,$t1,wr_mem
  nop
  li $t0, 0
rd_mem:
  lw $t2, 0($t0)
  bne $t2,$t0,wrong
  nop
  addiu $t0,$t0,4
  bne $t0,$t1,rd_mem
  nop
  b __start
  nop

wrong:
  li $t7, 0xdeaddead
  b wrong
  nop