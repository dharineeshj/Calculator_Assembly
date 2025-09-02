section .data 
    formatNumPrintf: db '%d',10,0
    formatStringScanf: db '%s',0
    divByZeroError: db "Division by zero error",10,0
    msg: db "Enter the equation:",0

section .bss
    equation resb 50
    num resd 10
    stack resb 50

section .text 
    global _start
    extern printf
    extern scanf

_start:
    call main
    mov rax, 60        
    xor rdi, rdi       
    syscall

main:
    push rbp
    mov rbp,rsp
    sub rsp,32

    repeate:
        mov rdi,msg
        xor rax,rax
        call printf

        mov rdi,formatStringScanf
        mov rsi,equation
        xor rax,rax
        call scanf
        call caculate

        jmp repeate

    xor rax,rax
    leave
    ret

caculate:
    push rbp
    mov rbp,rsp
    sub rsp,32

    mov rdi,equation
    mov rsi,-1
    mov rcx,-1
    mov r9,-1
    mov DWORD [rbp-4],0
    
loop:
    mov al, BYTE [rdi]
    add rdi,1
    cmp al,0
    je _done

    number:
        _first_conditon:
            cmp al,'0'
            jge _second_check
            jmp symbol

        _second_check:
            cmp al,'9'
            jle _add_number
            jmp symbol

        _add_number:
            mov ebx,DWORD [rbp-4]
            imul ebx,10
            movzx eax, al       
            sub eax,'0'
            add ebx,eax
            mov DWORD [rbp-4],ebx

            jmp loop
            
    symbol:
        mov bl,al                   
        add rsi,1
        mov eax,DWORD [rbp-4]
        mov DWORD [num+rsi*4],eax
        xor eax,eax
        mov DWORD [rbp-4],eax

    
        _condition1:
            cmp rcx,-1
            je _push

            mov dl, BYTE [stack+rcx]
            
            cmp bl,'*'
            je .curr_muldiv
            cmp bl,'/'
            je .curr_muldiv

            jmp _pop

        .curr_muldiv:

            cmp dl,'*'
            je _pop
            cmp dl,'/'
            je _pop
            jmp _push

        _pop:
            mov r8,rbx
            mov ebx,DWORD [num+rsi*4]    
            sub rsi,1
            mov eax,DWORD [num+rsi*4]    

            mov dl,BYTE [stack+rcx]      
            call eval
            mov DWORD [num+rsi*4],eax

            sub rcx,1
            mov rbx,r8
            jmp _condition1

        _push:
            add rcx,1
            mov BYTE [stack+rcx],bl

            jmp loop

_done:
    add rsi,1
    mov eax,DWORD [rbp-4]
    mov DWORD [num+rsi*4],eax

    _loop:
        cmp rsi,0
        je _completed

        mov ebx,DWORD [num+rsi*4]
        sub rsi,1
        mov eax,DWORD [num+rsi*4]

        
        mov dl,BYTE [stack+rcx]
        call eval
        mov DWORD [num+rsi*4],eax

        sub rcx,1
        jmp _loop

_completed:
    mov eax,DWORD [num+rsi*4]

    mov edi,formatNumPrintf
    mov esi,eax
    xor eax,eax
    call printf

    leave
    ret

eval:
    push rbp
    mov rbp,rsp

    cmp dl,'+'
    je _add

    cmp dl,'-'
    je _sub

    cmp dl,'*'
    je _mul

    cmp dl,'/'
    je _div

    jmp _end

    _add:
        add eax,ebx
        jmp _end

    _sub:
        sub eax,ebx
        jmp _end

    _mul:
        imul eax, ebx
        jmp _end

    _div:
        cmp ebx, 0
        je _div_by_zero

        cdq              
        idiv ebx         
        jmp _end

    _div_by_zero:
        
        mov rdi,divByZeroError
        xor eax,eax
        call printf

        mov rax, 60        
        xor rdi, rdi       
        syscall

_end:
    leave
    ret
