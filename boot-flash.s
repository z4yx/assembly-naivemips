.set noreorder
.set noat
.globl __start
__start:
  b load_elf  #implemented in bootasm.S
  nop
#include "bootasm.S"
