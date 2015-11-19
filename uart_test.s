.set noreorder
.set noat
.globl __start
__start:
  li $a0,0x1fd003f0
chk_rx:
  lb $a1,0xc($a0)
  andi $a1,$a1,2
  beq $a1,$0,chk_rx
  nop
  lw $a2,0x4($a0)
  sw $a1,0xc($a0) #clear received
chk_tx:
  lb $a1,0xc($a0)
  andi $a1,$a1,1
  beq $a1,$0,chk_tx
  nop
#   li $a2,1
#   li $a1,1000000
# delay:
#   sub $a1,$a2
#   bne $a1,$0,delay
  nop
  nor $a1,$0,$a2
  sb $a1,0x8($a0)
  b __start
  nop