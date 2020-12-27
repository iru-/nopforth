# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

NOPSYS != ./getsys.sh

ASFLAGS += -Isrc

SRC=\
	src/arch.ns\
	src/comments.ns\
	src/dictionary.ns\
	src/file.ns\
	src/flowcontrol.ns\
	src/go.ns\
	src/interactive.ns\
	src/interpreter.ns\
	src/loadpaths.ns\
	src/memory.ns\
	src/pictured.ns\
	src/shell.ns\
	src/string.ns\
	src/boot.s\
	src/dicts.s\
	src/${NOPSYS}.s\

all: ${NOPSYS} test_bootstrap

Linux:
	LDFLAGS=-ldl make bin/nop

OpenBSD:
	LDFLAGS=-Wl,-z,wxneeded make bin/nop

NetBSD: bin/nop
	paxctl +m bin/nop

FreeBSD: bin/nop

bin/nop: bin/nop.o
	${CC} -ggdb -o bin/nop bin/nop.o ${LDFLAGS}

test_bootstrap:
	@echo -n | bin/nop   # test the bootstrap

bin/nop.o: ${SRC}
	mkdir -p bin
	${AS} -ggdb ${ASFLAGS} -o $@ src/${NOPSYS}.s

d: all
	gdb -x cmd.gdb bin/nop

test: all
	bin/nop test/logic.ns
	bin/nop test/fileio.ns && rm -f test.out
	bin/nop test/clib.ns
	bin/nop test/endian.ns

.PHONY: test

clean:
	rm -f bin/*.o bin/nop
