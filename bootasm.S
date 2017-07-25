/* 
  Bootloader for MIPS32S
  Chen Yuheng
  2012/07/16
 */

/* start address of program payload in spi flash */
#define FLASH_START 0xBA800000
#define ELF_MAGIC 0x464C457F

/* off = offset from s0 */
/* load a 32bit word from Flash, 
 * off is byte-addressed */
#define LOAD_WORD_I(dst, off) \
  la $t7, off; \
  addu $t7, $s0, $t7; \
  lw dst, 0($t7);

#define LOAD_WORD_R(dst, off, base) \
  addiu $t7, base, off;\
  addu $t7, $s0, $t7; \
  lw dst, 0($t7);
   
#assume file base == FLASH_START



load_elf:
  #addr of elfheader, s0
  la $s0, FLASH_START
  LOAD_WORD_I($t1, 0) #dummy read
  LOAD_WORD_I($t1, 0) #dummy read
  LOAD_WORD_I($t1, 0) #dummy read
  #e_magic
  LOAD_WORD_I($t1, 0)
  la $t0, ELF_MAGIC
  beq $t0, $t1, 1f
  nop
  b bad
  nop
1:
  #e_phoff
  LOAD_WORD_I($s1, 28)
  #e_phnum
  LOAD_WORD_I($s2, 44)
  andi $s2, $s2, 0xFFFF

  #e_entry
  LOAD_WORD_I($s3, 24)

next_sec:
  #s1, addr proghdr
  #s4, p_va
  LOAD_WORD_R($s4, 8, $s1)
  #s5, p_filesz
  LOAD_WORD_R($s5, 16, $s1)
  #s6, p_offset
  LOAD_WORD_R($s6, 4, $s1)

  srl  $t0, $s4, 31
  beq  $t0, $zero, 3f #check if MSB is 1
  nop
  beq  $s5, $zero, 3f
  nop

  lui  $t0, 0xa000
  or   $s4, $s4, $t0

#copy from file_base+p_offset to p_va
copy_sec:
  LOAD_WORD_R($t0, 0, $s6)
  sw $t0, 0($s4)
  addiu $s6, $s6, 4
  addiu $s4, $s4, 4
  addiu $s5, $s5, -4
  bgtz  $s5, copy_sec
  nop

3:
  addiu $s1, $s1, 32
  addiu $s2, $s2, -1
  bgtz  $s2, next_sec
  nop

done:
#jump to kernel
  jr $s3
  nop
  b .
  nop

bad:
  b bad 
  nop

