;; Use "fasm web.asm" command to assemble.

format ELF64 executable

include 'defs.asm'
include 'struct.asm'
include 'macro.asm'

segment readable executable
entry main
main:
    write STDOUT, start, start.size

    ;; Create a socket
    write STDOUT, socket_trace_msg, socket_trace_msg.size
    socket AF_INET, SOCK_STREAM, 0
    check_error

    mov qword [sockfd], rax

    ;; Bind socket
    write STDOUT, bind_trace_msg, bind_trace_msg.size
    mov word [servaddr.sin_family], AF_INET
    mov word [servaddr.sin_port], 14619
    mov dword [servaddr.sin_addr], INADDR_ANY
    bind [sockfd], servaddr.sin_family, sizeof_servaddr
    check_error

    ;; Listen socket
    write STDOUT, listen_trace_msg, listen_trace_msg.size
    listen [sockfd], MAX_CONN
    check_error

    ;; Accept client connections with a loop
next_request:
    write STDOUT, accept_trace_msg, accept_trace_msg.size
    accept [sockfd], cliaddr.sin_family, cliaddr_len
    check_error

    mov qword [connfd], rax

    write [connfd], response, response_len

    jmp next_request

    write STDOUT, ok_msg, ok_msg.size
    close [connfd]
    close [sockfd]
    exit EXIT_SUCCESS

    ;; Error handling
error:
    write STDERR, error_msg, error_msg.size
    close [connfd]
    close [sockfd]
    exit EXIT_FAILURE

segment readable writeable

sockfd dq -1
connfd dq -1

servaddr servaddr_in
sizeof_servaddr = $ - servaddr.sin_family

cliaddr servaddr_in
cliaddr_len dd sizeof_servaddr

response db "HTTP/1.1 200 OK", 13, 10
         db "Content-Type: text/html", 13, 10
         db "Connection: close", 13, 10
         db 13, 10
         db "<html><body style=""display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;"">", 13, 10
         db "<div style=""text-align: center;""><h1>That visitor has no idea what he's looking at.</h1>", 13, 10
         db "<img src=""https://i1.sndcdn.com/artworks-DpOeuNBfyUErwo6j-HidoVA-t500x500.jpg"" style=""max-width: 80%; height: auto;""></div></body></html>", 13, 10
response_len = $ - response

start db "INFO: Starting Web Server!", 10
socket_trace_msg db "INFO: Creating a socket...", 10
bind_trace_msg db "INFO: Binding the socket...", 10
listen_trace_msg db "INFO: Listening to the socket...", 10
accept_trace_msg db "INFO: Waiting for client connections...", 10
ok_msg db "INFO: OK!", 10
error_msg db "ERROR!", 10
