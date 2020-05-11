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

all: bin/nop

bin/nop: bin/nop.o
	${CC} -ggdb -o $@ $^ -ldl
	@bin/nop /dev/null   # test the bootstrap

bin/nop.o: ${SRC}
	mkdir -p bin
	${AS} -ggdb ${ASFLAGS} -o $@ src/${NOPSYS}/nop.s

d: all
	gdb -x cmd.gdb bin/nop

test: bin/nop
	bin/nop test/logic.ns
	bin/nop test/str.ns
	bin/nop test/fileio.ns && rm -f test.out
	bin/nop test/clib.ns
	bin/nop test/endian.ns

.PHONY: test

clean:
	rm -f bin/*.o bin/nop
