format ELF64 executable

SYS_write equ 1
SYS_close equ 3
SYS_socket equ 41
SYS_accept equ 43
SYS_bind equ 49
SYS_listen equ 50
SYS_exit equ 60

AF_INET equ 2
SOCK_STREAM equ 1
INADDR_ANY equ 0

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

MAX_CONN equ 5

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
    mov rax, SYS_write
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro socket domain, type, protocol
{
    mov rax, SYS_socket
    mov rdi, domain
    mov rsi, type
    mov rdx, protocol
    syscall
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
    mov rax, SYS_exit
    mov rdi, code
    syscall
}

struc db [data]
{
    common
	. db data
	.size = $ - .
}

segment readable executable
entry main
main:
    write STDOUT, start, start.size

    write STDOUT, socket_trace_msg, socket_trace_msg.size
    socket AF_INET, SOCK_STREAM, 0
    cmp rax, 0
    jl error
    mov qword [sockfd], rax

    write STDOUT, bind_trace_msg, bind_trace_msg.size
    mov word [servaddr.sin_family], AF_INET
    mov word [servaddr.sin_port], 14619
    mov dword [servaddr.sin_addr], INADDR_ANY
    bind [sockfd], servaddr.sin_family, sizeof_servaddr
    cmp rax, 0
    jl error

    write STDOUT, listen_trace_msg, listen_trace_msg.size
    listen [sockfd], MAX_CONN
    cmp rax, 0
    jl error

next_request:
    write STDOUT, accept_trace_msg, accept_trace_msg.size
    accept [sockfd], cliaddr.sin_family, cliaddr_len
    cmp rax, 0
    jl error

    mov qword [connfd], rax

    write [connfd], response, response_len

    jmp next_request

    write STDOUT, ok_msg, ok_msg.size
    close [connfd]
    close [sockfd]
    exit EXIT_SUCCESS

error:
    write STDERR, error_msg, error_msg.size
    close [connfd]
    close [sockfd]
    exit EXIT_FAILURE

segment readable writeable


struc servaddr_in
{
    .sin_family dw 0
    .sin_port   dw 0
    .sin_addr   dd 0
    .sin_zero   dq 0
}

sockfd dq -1
connfd dq -1
servaddr servaddr_in
sizeof_servaddr = $ - servaddr.sin_family
cliaddr servaddr_in
cliaddr_len dd sizeof_servaddr

response db "HTTP/1.1 200 OK", 13, 10
	 db "Content-Type: text/html; charset=UTF-8", 13, 10
	 db "Connection: close", 13, 10
	 db 13, 10
	 db "<h1>Hello from fasm!</h1>", 13, 10
response_len = $ - response

start db "INFO: Starting Web Server!", 10
socket_trace_msg db "INFO: Creating a socket...", 10
bind_trace_msg db "INFO: Binding the socket...", 10
listen_trace_msg db "INFO: Listening to the socket...", 10
accept_trace_msg db "INFO: Waiting for client connections...", 10
ok_msg db "INFO: OK!", 10
error_msg db "ERROR!", 10
