
GCCPREFIX?=mipsel-linux-gnu-

override CFLAGS	+= -mips32r2 -mno-abicalls -fno-pic -x assembler-with-cpp -EL -nostdlib -nostdinc -static -g
override LDFLAGS += -nostdlib -EL -static

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
MEMS  := $(patsubst %.s, %.mem, $(SRC))

all: xilinx altera sim $(BINS)

xilinx: $(COES)
	@echo "Generated: " $(COES)

altera: $(MIFS)
	@echo "Generated: " $(MIFS)

sim: $(MEMS)

%.mem: %.bin
	hexdump -v -e '"%08x\n"' $< >$@
	$(foreach n, $^ , spilt_word.py $@ <$(n);) 

%.coe: %.rom.bin
	bin2coe.py  32 <$^ >$@

%.mif: %.rom.bin
	bin2mif.py  32 <$^ >$@

%.rom.bin: %.rom.elf
	$(OBJCOPY) -j .text -O binary  -S $^ $@

%.rom.elf: %.o
	$(LD) $(LDFLAGS) -Ttext 0xbfc00000 -o $@ $^

%.bin: %.elf
	$(OBJCOPY) -j .text -O binary $^ $@

%.elf: %.o
	$(LD) $(LDFLAGS) -Ttext 0x80000000 -o $@ $^

%.o: %.s
	$(CC) $(CFLAGS) -x assembler-with-cpp -g -c -o $@ $^
