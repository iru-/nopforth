ASFLAGS=-ggdb
LDFLAGS=-Bdynamic
SYS != uname -s

SRC=\
	x86-64/nop.s\
	x86-64/dicts.s\
	x86-64/sysdefs.inc\
	portable/comments.ns\
	portable/base.ns\
	x86-64/base.ns\

all: nop

nop: nop.o
	${CC} -nostartfiles -nostdlib -o $@ nop.o -e boot -ldl

nop.o: ${SRC}
	${AS} ${ASFLAGS} -o $@ x86-64/nop.s

x86-64/sysdefs.inc: x86-64/sys${SYS}.s
	cp $? $@

d: all
	gdb -x cmd.gdb nop

test: nop
	nop test/fileio.ns
	@rm -f test.out
	nop test/clib.ns

.PHONY: test

clean:
	rm -f sysdefs.inc *.o nop
