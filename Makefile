ASFLAGS=-ggdb
LDFLAGS=-Bdynamic
SYS=$(shell uname -s)

all: nop

nop: nop.o
	gcc -nostartfiles -nostdlib -o $@ nop.o -e boot -ldl

nop.o: dicts.s sysdefs.inc nop.s base.nf
	$(AS) $(ASFLAGS) -o $@ nop.s

sysdefs.inc: sys$(SYS).s
	cp $< $@

d: all
	gdb -x cmd.gdb nop

clean:
	rm -f sysdefs.inc *.o nop
