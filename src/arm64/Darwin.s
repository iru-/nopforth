.text
#include "arm64/boot.s"

.data
_kernbuf:
.incbin "comments.ns"
.incbin "arm64/arch.ns"
.incbin "flowcontrol.ns"
.incbin "interactive.ns"
_kerntot = . - _kernbuf
