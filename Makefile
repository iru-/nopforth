NOPSYS != ./getsys.sh

ASFLAGS += -Isrc

SRC=\
	src/boot.s\
	src/dicts.s\
	src/comments.ns\
	src/arch.ns\
	src/kern.ns\
	src/${NOPSYS}/boot.s\
	src/${NOPSYS}/os.s\
	src/${NOPSYS}/nop.s\

all: bindir nop

bindir:
	mkdir -p bin

nop: nop.o
	${CC} -o bin/$@ bin/$^ -ldl
	@bin/nop /dev/null   # test the bootstrap

nop.o: ${SRC}
	${AS} ${ASFLAGS} -o bin/$@ src/${NOPSYS}/nop.s

d: all
	gdb -x cmd.gdb bin/nop

test: nop
	bin/nop test/logic.ns
	bin/nop test/str.ns
	bin/nop test/fileio.ns && rm -f test.out
	bin/nop test/clib.ns
	bin/nop test/endian.ns

.PHONY: test

clean:
	rm -f bin/*.o bin/nop
