section .data
    buffer_size equ 100

section .bss
    buffer resb 100

section .text
    global _start

_start:
    endbr64

    ; Read the command line arguments
    ; Possibly make sure there's only one?
    mov rsi, [rsp + 16] ; ChatGPT

    call open_file ; Calls to open_file | ChatGPT switched this from a jmp to a call
    call check_for_more_bytes ; Calls read_file | ChatGPT switched this from a jmp to a call

    call exit       ; ChatGPT

open_file:
    ; Opens the file specified in the call
    mov rax, 2   ; Open file number
    mov rdi, rsi
    xor rsi, rsi ; Sets rsi to 0, telling the CPU to use the flag 0, or O_RDONLY
    syscall      ; Calls the system
    cmp rax, -0  ; Compares rax to -1
    js error     ; If rax and -1 are the same, jmp to error

    mov rbx, rax ; Store rax (now the file descriptor) in rbx

    ret          ; Returns from the function | ChatGPT helped fix this line

check_for_more_bytes:
    call read_file
    cmp rax, 0
    jz exit
    call print
    jmp check_for_more_bytes

read_file:
    ; Reads the file, and stores it in a buffer
    mov rax, 0
    mov rdi, rbx
    mov rsi, buffer
    mov rdx, buffer_size
    syscall
    cmp rax, 0
    js error

    ret

print:
    ; Prints the file to the console then jmps to read again
    push rax
    mov rax, 1           ; Write number
    mov rdi, 1           ; stdout file descriptor
    mov rsi, buffer      ; Tells the CPU where the text to print is stored
    mov rdx, buffer_size
    syscall   ; Calls the system
    cmp rax, 0

    pop rax

    ret                  ; Returns from the function | ChatGPT added this line

print_and_exit:
    call print           ; ChatGPT

    call close_file      ; Calls close_file | ChatGPT switched this from a jmp to a call
    call exit

close_file:
    ; Closes the file that was opened in open_file
    mov rax, 3   ; Close file number
    mov rdi, rbx ; Moves rbx into rdi
    syscall      ; Calls the system
    cmp rax, -1  ; Compares rax and -1
    je error     ; If rax and -1 are the same, jmp to error

    ret          ; ChatGPT

exit:
    ; Exits the program
    mov rax, 60  ; Exit number
    xor rdi, rdi ; Exit status (0 for ok)
    syscall      ; Calls the system

error:
    ; Exits the program with an error
    mov rax, 60  ; Exit number
    mov rdi, 100  ; Exit status (-1 for error)
    syscall      ; Calls the system
