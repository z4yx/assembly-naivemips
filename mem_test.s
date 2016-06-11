.set noreorder
.set noat
.globl __start
#define GPIO0_BASE    0xbfd00400
#define START_ADDRESS 0x80000000
#define END_ADDRESS   0x8000001c
__start:
  li $s0,GPIO0_BASE
  nor $t1,$zero,$zero
  sw $t1, 4($s0)     #gpio0 all output

  li $t7, 0xfaceface
  li $t0, START_ADDRESS
  li $t1, END_ADDRESS
wr_mem:
  sw $t0, 0($t0)
  sw $t0, 0($s0)
  addiu $t0,$t0,4
  bne $t0,$t1,wr_mem
  nop
  li $t0, START_ADDRESS
rd_mem:
  lw $t2, 0($t0)
  sw $t0, 0($s0)
  bne $t2,$t0,wrong
  nop
  addiu $t0,$t0,4
  bne $t0,$t1,rd_mem
  nop
  b __start
  nop

wrong:
  li $t7, 0xdeaddead
  # sw $t7, 0($s0)
  b wrong
  nop