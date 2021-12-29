# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

SYS=$(shell uname -s)
ARCH=$(shell uname -m)

ASFLAGS += -Isrc

SRC=\
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
	src/dicts.s\
	src/${ARCH}/arch.ns\
	src/${ARCH}/boot.s\
	src/${ARCH}/${SYS}.s\

all: ${SYS} test_bootstrap

Linux:
	LDFLAGS=-ldl make bin/nop

OpenBSD:
	LDFLAGS=-Wl,-z,wxneeded make bin/nop

NetBSD: bin/nop
	paxctl +m bin/nop

FreeBSD: bin/nop
Darwin: bin/nop

bin/nop: bin/nop.o
	${CC} -ggdb -o bin/nop bin/nop.o ${LDFLAGS}

test_bootstrap:
	@echo -n | bin/nop   # test the bootstrap

bin/nop.o: ${SRC}
	mkdir -p bin
	${CC} -ggdb ${ASFLAGS} -c -o $@ src/${ARCH}/${SYS}.s

d: debug-${ARCH}

debug-x86_64: bin/nop
	gdb -x cmd.gdb bin/nop

debug-arm64: bin/nop
	lldb --local-lldbinit

test: all
	bin/nop test/logic.ns
	bin/nop test/fileio.ns && rm -f test.out
	bin/nop test/clib.ns
	bin/nop test/endian.ns

.PHONY: test

clean:
	rm -f bin/*.o bin/nop
