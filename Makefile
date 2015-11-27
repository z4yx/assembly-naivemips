
GCCPREFIX:=mips-sde-elf-

CFLAGS	:=  -fno-builtin -nostdlib  -nostdinc -g  -EL -G0 -Wformat -O2 -mno-float
LDFLAGS	+= -nostdlib 

CC :=$(GCCPREFIX)gcc
LD      := $(GCCPREFIX)ld
AS      := $(GCCPREFIX)as -EL -g -mips32
AR      := $(GCCPREFIX)ar
OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

SRC   := $(wildcard *.s)
COES  := $(patsubst %.s, %.coe, $(SRC))
MIFS  := $(patsubst %.s, %.mif, $(SRC))
BINS  := $(patsubst %.s, %.bin, $(SRC))

all: xilinx altera $(BINS)

xilinx: $(COES)
	@echo "Generated: " $(COES)

altera: $(MIFS)
	@echo "Generated: " $(MIFS)

%.coe: %.rom.bin
	bin2coe.py  32 <$^ >$@

%.mif: %.rom.bin
	bin2mif.py  32 <$^ >$@

%.rom.bin: %.rom.elf
	$(OBJCOPY) -O binary  -S $^ $@

%.rom.elf: %.o
	$(LD) -EL -n -G0 -Ttext 0xbfc00000 -o $@ $^

%.bin: %.elf
	$(OBJCOPY) -O binary  -S $^ $@

%.elf: %.o
	$(LD) -EL -n -G0 -Ttext 0x00000000 -o $@ $^

%.o: %.s
	$(CC) $(CFLAGS) -g -c -o $@ $^
