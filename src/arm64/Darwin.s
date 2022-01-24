.text
#include "arm64/boot.s"

.data
_kernbuf:
.incbin "comments.ns"
.incbin "arm64/arch.ns"
.incbin "flowcontrol.ns"
.incbin "interactive.ns"
.incbin "dictionary.ns"
.incbin "memory.ns"
.incbin "string.ns"
_kerntot = . - _kernbuf
