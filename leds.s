.set noreorder
.set noat
.globl __start
__start:
  #register tests
  li $1,1
  li $2,2
  li $3,3
  li $4,4
  li $5,5
  li $6,6
  li $7,7
  li $8,8
  li $9,9
  li $10,10
  li $11,11
  li $12,12
  li $13,13
  li $14,14
  li $15,15
  li $16,16
  li $17,17
  li $18,18
  li $19,19
  li $20,20
  li $21,21
  li $22,22
  li $23,23
  li $24,24
  li $25,25
  li $26,26
  li $27,27
  li $28,28
  li $29,29
  li $30,30
  li $31,31
  #end of register tests

  li $a0,0xbfd00400

  li $a1,0xffffffff #gpio0 all output
  sw $a1,4($a0)
  li $a2,1
loop:
  sw $a2,0($a0)
  sll $a2,$a2,1
  andi $a2,$a2,0xffff
  bne $a2,$0,delay
  nop
  li $a2,1

delay:
  li $t0,0
  li $t1,0xffff
delay_1:
  addi $t0,$t0,1
  bne $t0,$t1,delay_1
  nop
  b loop
  nop

