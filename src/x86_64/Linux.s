# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2024 Iruatã Martins dos Santos Souza

.equ MAP_ANONYMOUS, 0x20
errnoaddr = __errno_location

.text
.include "x86_64/boot.s"
.include "x86_64/sysv.s"

.data
.include "dicts.s"

_kernbuf:
.incbin "comments.ns"
.incbin "x86_64/arch.ns"
.incbin "flowcontrol.ns"
.incbin "interactive.ns"
.incbin "dictionary.ns"
.incbin "memory.ns"
.incbin "string.ns"
.incbin "pictured.ns"
.incbin "interpreter.ns"
.incbin "../lib/nop/clib/x86_64.ns"
.incbin "../lib/nop/clib/elf-extension.ns"
.incbin "../lib/nop/clib.ns"
.incbin "file.ns"
.incbin "shell.ns"
.incbin "loadpaths.ns"
.incbin "go.ns"
_kerntot = . - _kernbuf
