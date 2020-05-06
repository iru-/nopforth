    .text

sysread:
    mov %rax, %rdi
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    call read@plt
    ret

syswrite:
    mov %rax, %rdi
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    call write@plt
    ret

sysexit:
    mov %rax, %rdi
    call exit@plt

sysopen:
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call open@plt
    ret

syscreate:
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call creat@plt
    ret

sysclose:
    mov %rax, %rdi
    call close@plt
    ret

sysseek:
    mov %rax, %rdi
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    call lseek@plt
    ret

sysmmap:
    mov %rax, %r9
    drop_
    mov %rax, %r8
    drop_
    mov %rax, %rcx
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call mmap@plt
    ret

sysmunmap:
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call munmap@plt
    ret

sys6:
    mov %rax, %r9
    drop_
sys5:
    mov %rax, %r8
    drop_
sys4:
    mov %rax, %r10
    drop_
sys3:
    mov %rax, %rdx
    drop_
sys2:
    mov %rax, %rsi
    drop_
sys1:
    mov %rax, %rdi
    pop %rax
    syscall
    ret

syscall6:  push %rax; drop_; jmp sys6
syscall5:  push %rax; drop_; jmp sys5
syscall4:  push %rax; drop_; jmp sys4
syscall3:  push %rax; drop_; jmp sys3
syscall2:  push %rax; drop_; jmp sys2
syscall1:  push %rax; drop_; jmp sys1

_dlopen:
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call dlopen@plt
    ret

_dlsym:
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call dlsym@plt
    ret

_dlclose:
    mov %rax, %rdi
    call dlclose@plt
    ret

_dlerror:
    call dlerror@plt
    ret

_getenv:
    mov %rax, %rdi
    call getenv@plt
    ret
