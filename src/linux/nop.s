.text
.include "boot.s"
.include "linux/boot.s"
.include "linux/os.s"

.data
.include "dicts.s"

_kernbuf:
.incbin "comments.ns"
.incbin "arch.ns"
.incbin "kern.ns"
_kerntot = . - _kernbuf
