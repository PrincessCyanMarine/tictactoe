; 1   2   4
; 8   16  32
; 64  128 256

section .data
    welcome: db "Welcome to assembly tictactoe!", 10, 10, 0
    welcome_length: equ $ - welcome

    draw_message: db "It's a draw...", 10, 0
    draw_message_length: equ $ - draw_message
    
    x_win_message: db "X won!!!", 10, 0
    o_win_message: db "O won!!!", 10, 0
    win_message_length: equ $ - o_win_message

    x_symbol: db " x "
    o_symbol: db " o "
    empty_symbol: db " # "
    new_line: db " ", 10, 10

    exit_string: db "0"

    pos_1:     db "7"
    pos_2:     db "8"
    pos_4:     db "9"
    pos_8:     db "4"
    pos_16:    db "5"
    pos_32:    db "6"
    pos_64:    db "1"
    pos_128:   db "2"
    pos_256:   db "3"

    ClearTerm: db   27,"[H",27,"[2J"    ; <ESC> [H <ESC> [2J
    CLEARLEN:  equ  $ - ClearTerm       ; Length of term clear string


section .bss
    input: resb 1

section .text
    global _start
    _start:
        ; mov r8, 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256
        ; mov r9, 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256
        mov r8,   0
        mov r9,   0
        main_loop:
            call _clear_terminal
            call _welcome_message
            call _print_state
            call _test_win
            call _read_input
            call _test_keys

            jmp main_loop

_read_input:
    mov         rax, 0
    mov         rdi, 0
    lea         rsi, [input]
    mov         rdx, 1
    syscall
    ret

_test_pos:
    call _compare_string
    jne skip_test_pos
        mov r10, r8
        and r10, r15
        jne skip_test_pos
            mov r10, r9
            and r10, r15
            jne skip_test_pos
                mov r10, r8
                and r10, 512
                jne o_turn
                    or r8, r15
                    jmp x_turn
                o_turn:
                    or r9, r15
                x_turn:
                stc
                ret
    skip_test_pos:
        shr r15, 1
        clc
        ret

; string compare https://stackoverflow.com/questions/70747963/trying-to-compare-two-strings-in-x86-64
_compare_string:
    ; rsi: second string
    mov rdi, input
    mov rcx, 1
    repe cmpsb
    ret

_print_state:
    mov r10w, r8w 
    mov r12w, r9w 
    mov r15, 3
    outer_loop:
        mov r14, 3
        inner_loop:
            clc
            shr r10w, 1
            jc _print_x
                clc
                shr r12w, 1
                jc _print_o
                    mov rsi, empty_symbol
                    jmp skip_1
            _print_x:
                mov rsi, x_symbol
                shr r12w, 1  ; Shift r12 pra direita pra que no proximo looop ambos estejam na mesma posição do tabuleiro
                jmp skip_1
            _print_o:
                mov rsi, o_symbol

            skip_1: call _print_symbol

            dec r14
            jnz inner_loop

        mov rsi, new_line
        call _print_symbol
        dec r15
        jnz outer_loop
    ret

    _print_symbol:
        ; rsi: input
        mov rax, 1
        mov rdi, 1
        mov rdx, 3
        syscall
        ret

_test_keys:
    mov rsi, exit_string
    call _compare_string
    je exit

    mov r15, 256

    mov rsi, pos_256
    call _test_pos
    jc _change_player

    mov rsi, pos_128
    call _test_pos
    jc _change_player

    mov rsi, pos_64
    call _test_pos
    jc _change_player

    mov rsi, pos_32
    call _test_pos
    jc _change_player

    mov rsi, pos_16
    call _test_pos
    jc _change_player

    mov rsi, pos_8
    call _test_pos
    jc _change_player

    mov rsi, pos_4
    call _test_pos
    jc _change_player

    mov rsi, pos_2
    call _test_pos
    jc _change_player

    mov rsi, pos_1
    call _test_pos
    jc _change_player

    jmp _test_keys_return

    _change_player:
        xor r8, 512
    _test_keys_return:
        ret

_welcome_message:
    mov rax, 1
    mov rdi, 1
    mov rsi, welcome
    mov rdx, welcome_length
    syscall
    ret

; https://stackoverflow.com/questions/30247644/clean-console-on-assembly
_clear_terminal:
    mov rax, 1                          ; Specify sys_write call
    mov rdi, 1                          ; Specify File Descriptor 1: Stdout
    mov rsi, ClearTerm                  ; Pass offset of terminal control string
    mov rdx, CLEARLEN                   ; Pass the length of terminal control string
    syscall
    ret

; 1   2   4
; 8   16  32
; 64  128 256
_test_win:
    mov r11w, 273 ; 1 + 16 + 256
    call _test_config

    mov r11w, 84  ; 64 + 16 + 4
    call _test_config

    mov r11w, 7   ; 1 + 2 + 4
    call _test_config

    mov r11w, 56  ; 8 + 16 + 32
    call _test_config

    mov r11w, 448 ; 64 + 128 + 256
    call _test_config

    mov r11w, 73  ; 1 + 8 + 64
    call _test_config

    mov r11w, 146 ; 2 + 16 + 128
    call _test_config

    mov r11w, 292 ; 4 + 32 + 256
    call _test_config

    mov r11w, 511 ; 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256
    mov r10w, r8w
    add r10w, r9w
    call _test_body ; Precisa do and r10w, r11w por causa do bit de jogador em r8
    jz _draw

    ret

    _test_config:
        mov r10w, r8w
        call _test_body
        jz x_win

        mov r10w, r9w
        call _test_body
        jz o_win

        ret

        _test_body:
            and r10w, r11w  ; Zera os bits que não estão sendo testados
            cmp r10w, r11w
            ret

_draw:
    mov rsi, draw_message
    mov rax, 1
    mov rdi, 1
    mov rdx, draw_message_length
    syscall
    jmp exit

o_win:
    mov rsi, o_win_message
    jmp win
x_win:
    mov rsi, x_win_message
win:
    mov rax, 1
    mov rdi, 1
    mov rdx, win_message_length
    syscall

exit:
    mov rax, 60
    mov rdi, 0
    syscall