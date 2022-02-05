# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2022 Iruatã Martins dos Santos Souza

.text
.include "boot.s"
.include "cygwin/boot.s"
.include "cygwin/os.s"

.data
.include "dicts.s"

_kernbuf:
.incbin "comments.ns"
.incbin "arch.ns"
.incbin "kern.ns"
_kerntot = . - _kernbuf
