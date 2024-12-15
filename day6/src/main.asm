; Notes:
;   - I setup stack frames when I don't need to just so I don't have to think about the stack too much.
;
;   - I'm really bad at ASM, and write my logic in a very blunt way without many tricks, so this is very suboptimal.
;
;   - For part 2 I could've done the "right" thing and check only positions that part 1 covers, but I really don't
;     want to debug that and spend more time on this, so I decided to just brute force it.

[section .data]

input_file_path: db "input.txt", 0x00
input_file_mode: db "r", 0x00

part_1_string: db "Part 1: %d", 0x0A, 0x00
part_2_string: db "Part 2: %d", 0x0A, 0x00

SEEK_END: equ 2

DIRECTION_UP: equ 1
DIRECTION_RIGHT: equ 2
DIRECTION_DOWN: equ 3
DIRECTION_LEFT: equ 4

[section .bss]

input_buffer_ptr: resq 1
input_buffer_len: resq 1
results_buffer_ptr: resq 1 ; Same length as input buffer

line_length: resq 1 ; Includes final new lines
start_position: resq 1


[section .text]

global main

extern fopen
extern fseek
extern ftell
extern fread
extern fclose
extern malloc
extern calloc
extern exit
extern putchar
extern printf
extern memset

main:
    push rbp
    mov rbp, rsp

    call read_input
    call find_line_length
    call allocate_results
    call find_start_position
    call walk
    call print_results

    call count_visited_tiles
    lea rdi, [part_1_string]
    mov rsi, rax
    call printf

    call part2

    xor rdi, rdi
    call exit

part2: ; (Can you tell I'm sick of ASM lol, not even trying to do things cleanly)
    push rbp
    mov rbp, rsp

    ; Brute force: Replace each space with a blockade one by one and see which ones create a cycle.
    mov rcx, [input_buffer_len]
    mov rsi, [input_buffer_ptr]
    xor r9, r9

.loop:
    ; Store old value, and replace it with a blockade
    dec rcx
    mov r8b, [rsi+rcx]
    mov byte [rsi+rcx], '#'

    ; See if we loop
    push rcx
    push rsi
    push r8
    push r9
    
    call clear_results
    call walk
    push rax

    ; mov rdi, 0x0A
    ; call putchar
    ; call print_results

    pop rax
    pop r9
    pop r8
    pop rsi
    pop rcx

    add r9, rax

    ; Restore old value
    mov [rsi+rcx], r8b

    inc rcx
    loop .loop

    lea rdi, [part_2_string]
    mov rsi, r9
    call printf

    leave
    ret

read_input:
    push rbp
    mov rbp, rsp

    ; Open the input file
    lea rdi, [input_file_path]
    lea rsi, [input_file_mode]
    call fopen
        cmp rax, 0
        jnz .fopen_ok
        
        leave
        mov rax, 1
        ret
    .fopen_ok:
    mov r15, rax

    ; Find file size
    mov rdi, r15
    xor rsi, rsi
    mov rdx, SEEK_END
    call fseek
        cmp rax, 0
        jz .fseek_ok
        
        leave
        mov rax, 1
        ret
    .fseek_ok:

    mov rdi, r15
    call ftell
    mov [input_buffer_len], rax
    mov r14, rax

    ; Reset cursor
    mov rdi, r15
    xor rsi, rsi
    xor rdx, rdx
    call fseek

    ; Allocate memory for the input
    mov rdi, r14
    call malloc
        cmp rax, 0
        jnz .malloc_ok
        
        leave
        mov rax, 1
        ret
    .malloc_ok:
    mov [input_buffer_ptr], rax
    mov r13, rax

    ; Read the input
    mov rdi, r13
    mov rsi, 1
    mov rdx, r14
    mov rcx, r15
    call fread
        cmp rax, r14
        je .fread_ok
        
        leave
        mov rax, 1
        ret
    .fread_ok:

    ; Close the file
    mov rdi, r15
    call fclose

    leave
    ret

find_line_length:
    push rbp
    mov rbp, rsp

    ; Advance pointer until we find the first new line
    mov al, 0x0A
    mov rdi, [input_buffer_ptr]
    mov rcx, [input_buffer_len]
    repne scasb

    ; Compare the read pointer and original pointer to find the length
    mov rax, [input_buffer_ptr]
    sub rdi, rax

    mov [line_length], rdi

    leave
    ret

allocate_results:
    push rbp
    mov rbp, rsp

    ; One byte per tile just so it's easier to eye ball things when debugging, rather than bitmapping things
    mov rdi, [input_buffer_len]
    mov rsi, 1
    call calloc
        cmp rax, 0
        jnz .calloc_ok
        
        mov rdi, 1
        call exit
    .calloc_ok:
    mov [results_buffer_ptr], rax

    leave
    ret

find_start_position:
    push rbp
    mov rbp, rsp

    ; Advance pointer until we find the ^
    mov al, '^'
    mov rdi, [input_buffer_ptr]
    mov rcx, [input_buffer_len]
    repne scasb

    ; Compare the read pointer and original pointer to find the length
    mov rax, [input_buffer_ptr]
    sub rdi, rax
    dec rdi ; repne scasb is always one over, which we don't want in this case

    mov [start_position], rdi

    leave
    ret

; The stack isn't strictly needed for this function, but I'm using it since it's way easier than keeping track of registers.
struc walk_stack
    .x: resb 1
    .y: resb 1
    .direction: resb 1

    .maxX: resb 1
    .maxY: resb 1
endstruc

; Returns:
;   rax = 0 if there's no cycle, 1 if there's a cycle.
walk:
    %define local(field) rbp - walk_stack_size + walk_stack. %+ field
    
    push rbp
    mov rbp, rsp
    sub rsp, walk_stack_size

    ; Setup local variable defaults
    mov byte [local(x)], 0
    mov byte [local(y)], 0
    mov byte [local(direction)], DIRECTION_UP
    mov byte [local(maxX)], 0
    mov byte [local(maxY)], 0

    ; Convert start position to coordinates
    mov rax, [start_position]
    xor rdx, rdx
    mov rsi, [line_length]
    div rsi
    mov byte [local(x)], dl ; Remainder
    mov byte [local(y)], al

    ; Setup max boundaries
    mov rax, [line_length]
    dec rax ; Don't include the new line
    mov byte [local(maxX)], al
    mov rax, [input_buffer_len]
    xor rdx, rdx
    mov rsi, [line_length]
    div rsi
    inc al ; Since it's not an exact divide, we need to round up
    mov byte [local(maxY)], al

.loop:
    ; Convert the current coordinates into an index
    xor rax, rax
    mov al, [local(y)]
    mov rsi, [line_length]
    xor rdx, rdx
    mul rsi
    mov rsi, rax
    xor rax, rax
    mov al, [local(x)]
    add rsi, rax

    ; Ensure the tile is marked as visited
    mov rdi, [results_buffer_ptr]
    mov dl, [rsi+rdi]
    or dl, 1
    mov [rsi+rdi], dl

    ; Check if we have a loop by looking at the direction flag
    mov dl, [rsi+rdi]
    mov cl, [local(direction)]
    mov al, 0x08
    shl al, cl
    and dl, al
    jz .no_cycle
    mov rax, 1
    leave
    ret
.no_cycle:
    mov dl, [rsi+rdi]
    or dl, al
    mov [rsi+rdi], dl

    ; Move in the next direction
    mov al, [local(direction)]
    cmp al, DIRECTION_UP
    je .up
    cmp al, DIRECTION_RIGHT
    je .right
    cmp al, DIRECTION_DOWN
    je .down
    cmp al, DIRECTION_LEFT
    jmp .left
    hlt

.up:
    mov rdi, -1
    call vertical_scan

    ; If we're at the end, exit the loop
    cmp rax, 0
    je .loop_end

    ; Otherwise position ourselves just under the blockade, and change direction
    inc r9
    mov byte [local(x)], r8b
    mov byte [local(y)], r9b
    mov byte [local(direction)], DIRECTION_RIGHT
    jmp .loop

.down:
    mov rdi, 1
    call vertical_scan

    ; If we're at the end, exit the loop
    cmp rax, 0
    je .loop_end

    ; Otherwise position ourselves just above the blockade, and change direction
    dec r9
    mov byte [local(x)], r8b
    mov byte [local(y)], r9b
    mov byte [local(direction)], DIRECTION_LEFT
    jmp .loop

.right:
    mov rdi, 1
    call horizontal_scan

    ; If we're at the end, exit the loop
    cmp rax, 0
    je .loop_end

    ; Otherwise position ourselves just left of the blockade, and change direction
    dec r8
    mov byte [local(x)], r8b
    mov byte [local(y)], r9b
    mov byte [local(direction)], DIRECTION_DOWN
    jmp .loop

.left:
    mov rdi, -1
    call horizontal_scan

    ; If we're at the end, exit the loop
    cmp rax, 0
    je .loop_end

    ; Otherwise position ourselves just right of the blockade, and change direction
    inc r8
    mov byte [local(x)], r8b
    mov byte [local(y)], r9b
    mov byte [local(direction)], DIRECTION_UP
    jmp .loop

.loop_end:
    xor rax, rax
    leave
    ret

; Must only be called by `walk`
;
; Params:
;   rdi = Y step
;
; Returns:
;   r8  = X of blockade
;   r9  = Y of blockade
;   rax = 0 if we went out of bounds, 1 if we're still in bounds
vertical_scan:
    xor r8, r8
    xor r9, r9
    mov r8b, [local(x)]
    mov r9b, [local(y)]

.loop:
    add r9, rdi
    js .out_of_area ; If the step makes the Y coordinate negative

    xor rdx, rdx
    mov dl, [local(maxY)]
    cmp r9, rdx
    je .out_of_area ; If the step makes the Y == the max Y

    ; Convert the coordinates into an index
    mov rax, r9
    mov rsi, [line_length]
    xor rdx, rdx
    mul rsi
    add rax, r8

    ; Check what's in the tile
    mov rsi, [input_buffer_ptr]
    mov dl, [rsi+rax]
    cmp dl, '#'
    je .in_area

    ; It's an empty space/the start position, so mark it
    mov rsi, [results_buffer_ptr]
    mov dl, [rsi+rax]
    or dl, 1
    mov [rsi+rax], dl
    jmp .loop

.out_of_area:
    xor rax, rax
    ret

.in_area:
    mov rax, 1
    ret

; Must only be called by `walk`
;
; Params:
;   rdi = X step
;
; Returns:
;   r8  = X of blockade
;   r9  = Y of blockade
;   rax = 0 if we went out of bounds, 1 if we're still in bounds
horizontal_scan:
    xor r8, r8
    xor r9, r9
    mov r8b, [local(x)]
    mov r9b, [local(y)]

.loop:
    add r8, rdi
    js .out_of_area ; If the step makes the X coordinate negative

    xor rdx, rdx
    mov dl, [local(maxX)]
    cmp r8, rdx
    je .out_of_area ; If the step makes the X == the max X

    ; Convert the coordinates into an index
    mov rax, r9
    mov rsi, [line_length]
    xor rdx, rdx
    mul rsi
    add rax, r8

    ; Check what's in the tile
    mov rsi, [input_buffer_ptr]
    mov dl, [rsi+rax]
    cmp dl, '#'
    je .in_area

    ; It's an empty space/the start position, so mark it
    mov rsi, [results_buffer_ptr]
    mov dl, [rsi+rax]
    or dl, 1
    mov [rsi+rax], dl
    jmp .loop

.out_of_area:
    xor rax, rax
    ret

.in_area:
    mov rax, 1
    ret

count_visited_tiles:
    push rbp
    mov rbp, rsp

    ; Load pointer & counter
    mov rsi, [results_buffer_ptr]
    mov rdi, [input_buffer_len]
    xor rcx, rcx ; i
    xor rax, rax ; result
    xor rdx, rdx ; Temp store from memory

.loop:
    cmp rcx, rdi
    je .loop_end

    mov dl, [rsi+rcx]
    and dl, 0x0F ; Upper bits are used as flags
    add rax, rdx

    inc rcx
    jmp .loop

.loop_end:
    leave
    ret

clear_results:
    push rbp
    mov rbp, rsp

    mov rdi, [results_buffer_ptr]
    mov rsi, 0
    mov rdx, [input_buffer_len]
    call memset

    leave
    ret

print_results:
    push rbp
    mov rbp, rsp

    ; Load pointer & counter
    mov rbx, [results_buffer_ptr]
    mov r13, [input_buffer_len]
    xor r14, r14 ; i
    xor r12, r12 ; Counter until new line
    
.loop:
    cmp r14, r13
    je .loop_end

.same_line:
    xor rdx, rdx
    mov dl, [rbx+r14]
    cmp dl, 0
    je .not_marked

    mov rdi, 'X'
    call putchar
    jmp .continue

.not_marked:
    mov rsi, [input_buffer_ptr]
    xor rdx, rdx
    mov dl, [rsi+r14]
    mov rdi, rdx
    call putchar
    jmp .continue

.continue:
    inc r14
    inc r12
    jmp .loop

.loop_end:
    leave
    ret