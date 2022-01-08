.text
#include "arm64/boot.s"

.data
_kernbuf:
.incbin "comments.ns"
.incbin "arm64/arch.ns"
.incbin "flowcontrol.ns"
_kerntot = . - _kernbuf
