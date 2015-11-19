.set noreorder
.set noat
.globl __start
__start:
  li $a0,0x1fd00400

  # li $a1,0xffff0000
  # sw $a1,4($a0)
  # li $a1,0x12345678
  # sw $a1,0($a0)
  # lw $a1,0($a0)
  # nop
  # lw $a2,8($a0)
  # lw $a2,0xc($a0)
  li $a1,0xffffffff #gpio0 all output
  sw $a1,4($a0)
  li $a1,0x0
  sw $a1,0xc($a0)

loop:
  lw $a2,8($a0)
  sw $a2,0($a0)
  b loop
  nop
