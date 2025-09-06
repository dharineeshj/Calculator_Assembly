section .data 
    formatNumPrintf: db '%d',10,0
    formatStringScanf: db '%s',0
    ErrorMsg: db "Error",10,0
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

    repeat:
        mov rdi,msg
        xor rax,rax
        call printf

        mov rdi,formatStringScanf
        mov rsi,equation
        xor rax,rax
        call scanf
        call calculate

        jmp repeat

    xor rax,rax
    leave
    ret

calculate:
    push rbp
    mov rbp,rsp
    sub rsp,32

    mov rdi,equation
    mov rsi,-1
    mov rcx,-1
    mov r9,-1
    mov DWORD [rbp-4],-1
    
loop:
    mov al, BYTE [rdi]
    add rdi,1
    cmp al,0
    je _done

    number:
        _first_condition:
            cmp al,'0'
            jge _second_check
            jmp symbol

        _second_check:
            cmp al,'9'
            jle _add_number
            jmp symbol

        _add_number:
            mov ebx,DWORD [rbp-4]
            cmp ebx,-1
            jne _not_first_digit
            mov ebx,0

        _not_first_digit:
            imul ebx,10
            movzx eax, al       
            sub eax,'0'
            add ebx,eax
            mov DWORD [rbp-4],ebx

            jmp loop
            
    symbol:
        mov bl,al                   

        cmp DWORD [rbp-4],-1
        je _condition1
        
        mov eax,DWORD [rbp-4]
        add rsi,1
        mov DWORD [num+rsi*4],eax
        mov DWORD [rbp-4],-1

    
        _condition1:
            cmp bl,'('
            je _push

            cmp rcx,-1
            je _push

            mov dl, BYTE [stack+rcx]
            
            cmp bl,')'
            je _braces_op

            cmp bl,'+'
            je .curr_addsub
            cmp bl,'-'
            je .curr_addsub
            cmp bl,'*'
            je .curr_muldiv
            cmp bl,'/'
            je .curr_muldiv

            jmp _error

        .curr_addsub:
            cmp dl,'('
            je _push
            cmp dl,'+'
            je _pop
            cmp dl,'-'
            je _pop
            cmp dl,'*'
            je _pop
            cmp dl,'/'
            je _pop
            jmp _push

        .curr_muldiv:

            cmp dl,'('
            je _push
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
            cmp bl,'+'
            je _continue
            cmp bl,'-'
            je _continue
            cmp bl,'*'
            je _continue
            cmp bl,'/'
            je _continue
            cmp bl,'('
            je _continue
            jmp _error

            _continue:
                add rcx,1
                mov BYTE [stack+rcx],bl

                jmp loop

        _braces_op:
            cmp BYTE [stack+rcx],'('
            je _braces_pop

            cmp rcx,-1
            je _end

            mov ebx,DWORD [num+rsi*4]    
            sub rsi,1
            mov eax,DWORD [num+rsi*4]    

            mov dl,BYTE [stack+rcx]      
            call eval
            mov DWORD [num+rsi*4],eax

            sub rcx,1
            jmp _braces_op
        
        _braces_pop:
            sub rcx,1
            jmp loop

_done:
    cmp DWORD [rbp-4],-1
    je _no_last_push
    add rsi,1
    mov eax,DWORD [rbp-4]
    mov DWORD [num+rsi*4],eax
_no_last_push:
    _loop:
        cmp rsi,0
        je _completed

        mov ebx,DWORD [num+rsi*4]
        sub rsi,1
        mov eax,DWORD [num+rsi*4]

        
        mov dl,BYTE [stack+rcx]
        cmp dl,'('
        je _break

        call eval
        mov DWORD [num+rsi*4],eax
    _break:
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
        je _error

        cdq              
        idiv ebx         
        jmp _end

    _error:
        
        mov rdi,ErrorMsg
        xor eax,eax
        call printf

        jmp repeat
_end:
    leave
    ret
