.include "arm64/boot.s"

.data
_kernbuf:
.incbin "comments.ns"
_kerntot = . - _kernbuf
