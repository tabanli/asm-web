macro syscall1 number, a
{
    mov rax, number
    mov rdi, a
    syscall
}

macro syscall2 number, a, b
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    syscall
}

macro syscall3 number, a, b, c
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    mov rdx, c
    syscall
}

macro write fd, buf, count
{
    syscall3 SYS_write, fd, buf, count
}

macro socket domain, type, protocol
{
    syscall3 SYS_socket, domain, type, protocol
}

macro bind sockfd, addr, addrlen
{
    syscall3 SYS_bind, sockfd, addr, addrlen
}

macro close fd
{
    syscall1 SYS_close, fd
}

macro listen sockfd, backlog
{
    syscall2 SYS_listen, sockfd, backlog
}

macro accept sockfd, addr, addrlen
{
    syscall3 SYS_accept, sockfd, addr, addrlen
}

macro exit code
{
    syscall1 SYS_exit, code
}

macro check_error
{
    cmp rax, 0
    jl error
}
