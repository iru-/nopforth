ASFLAGS=-ggdb
LDFLAGS=-static
SYS=$(shell uname -s)

all: nop

nop: nop.o
	$(LD) $(LDFLAGS) -e boot -o $@ nop.o

nop.o: dicts.s sysdefs.inc nop.s
	$(AS) $(ASFLAGS) -o $@ nop.s

sysdefs.inc: sys$(SYS).s
	cp $< $@

d: all
	gdb -x cmd.gdb nop

clean:
	rm -f sysdefs.inc *.o nop
