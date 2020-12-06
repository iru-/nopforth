# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

.text
.include "boot.s"
.include "linux/boot.s"
.include "linux/os.s"

.data
.include "dicts.s"

_kernbuf:
.incbin "comments.ns"
.incbin "arch.ns"
.incbin "flowcontrol.ns"
.incbin "interactive.ns"
.incbin "dictionary.ns"
.incbin "memory.ns"
.incbin "string.ns"
.incbin "pictured.ns"
.incbin "interpreter.ns"
.incbin "file.ns"
.incbin "shell.ns"
.incbin "loadpaths.ns"
.incbin "go.ns"
_kerntot = . - _kernbuf
