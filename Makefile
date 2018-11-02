ASFLAGS=-ggdb
LDFLAGS=-static
SYS=$(shell uname -s)

all: nop

nop: nop.o
	$(LD) $(LDFLAGS) -e boot -o $@ nop.o

%.o: %.s sysdefs.inc dicts.s
	$(AS) $(ASFLAGS) -o $@ $<

sysdefs.inc: sys$(SYS).s
	cp $< $@

d: all
	gdb -x cmd.gdb nop

clean:
	rm -f sysdefs.inc *.o nop
