; Assembly program for calculating b - c + a
; 
; Usage:
;   nasm -f bin calc.asm -o calc.com     (for DOSBox)

; DOSBox version
org 0x100               ; COM file format

    ; Jump over data to start of code
    jmp start

; Variables
a db 5                  ; a = 5
b db 3                  ; b = 3  
c db 2                  ; c = 2

; String constants
header db '=================', 13, 10
       db 'Calculation: b - c + a:', 13, 10, '$'
       
step1  db '3 - c = ', '$'
step2  db ' + a = ', '$'  
step3  db ' = ', '$'
footer db 13, 10, '=================', 13, 10, '$'

start:
    ; Display header
    mov dx, header
    mov ah, 09h
    int 21h

    ; Calculate b - c + a step by step
    mov al, [b]             ; Load b = 3
    
    ; Display "3 - c = "
    mov dx, step1
    mov ah, 09h
    int 21h
    
    sub al, [c]             ; al = b - c = 3 - 2 = 1
    
    ; Display intermediate result
    add al, '0'             ; Convert to ASCII
    mov dl, al
    mov ah, 02h
    int 21h
    sub al, '0'             ; Convert back
    
    ; Display " + a = "
    mov dx, step2
    mov ah, 09h
    int 21h
    
    add al, [a]             ; al = (b - c) + a = 1 + 5 = 6
    
    ; Display intermediate result  
    add al, '0'             ; Convert to ASCII
    mov dl, al
    mov ah, 02h
    int 21h
    sub al, '0'             ; Convert back
    
    ; Display " = "
    mov dx, step3
    mov ah, 09h
    int 21h
    
    ; Display final result
    add al, '0'             ; Convert to ASCII
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Display footer
    mov dx, footer
    mov ah, 09h
    int 21h

    ; Exit program
    mov ax, 4c00h           ; DOS exit function
    int 21h                 ; DOS interrupt

%endif
