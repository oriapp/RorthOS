; ==============================
;     ~Wellcome~
;     RorthOS | v 0.0.3
;
; Implemented:
; - Print subroutine
; - Disable and Enable interrupts while booting
; - Read from hard disk
; ==============================


ORG 0
BITS 16

_start:
    jmp short start
    nop ;             NO OPERATION

;                     BIOS parameter block
times 33 db 0

start:
    jmp 0x7c0: step2 ;Code segment address "0x7c0" and then do...


;  --------------------------------------------------------------
;   # Interrupt                                                 ;
handle_zero:                                                    ;
    mov ah, 0eh                                                 ;
    mov al, 'A'                                                 ;
    mov bx, 0x00                                                ;
    int 0x10                                                    ;
    iret    ;   Return from interrupt                           ;
;   #                                                           ;
handle_one:                                                     ;
    mov ah, 0eh                                                 ;
    mov al, 'V'                                                 ;
    mov bx, 0x01                                                ;
    int 0x10                                                    ;
    iret                                                        ;
;  --------------------------------------------------------------

step2:
    cli     ;      Disable interrupts


;  --------------------------------------------------------------
;             Read from hard disk                               ;
;                                                               ;
    mov ah, 2   ; Read sector coammnd                           ;
    mov al, 1   ; One sector to read                            ;
    mov ch, 0   ; Cylinder low eight bits                       ;
    mov cl, 2   ; Read  sector two                              ;
    mov dh, 0   ; Head number                                   ;
    mov bx, buffer                                              ;
    int 0x13    ; invoke read command                           ;    
;                                                               ;
    jc error    ; Jump carry                                    ;    
;                                                               ;
    mov si, buffer                                              ;  
    call print                                                  ;
;  --------------------------------------------------------------

    mov ax, 0x7c0
    mov ds, ax  ;   Set data segment with 0x7c0
    mov es, ax  ;   Set extra segment with 0x7c0

    mov ax, 0x00
    mov ss, ax      ; Stack segment set to 0
    mov sp, 0x7c00  ; Stack pointer address set to 0x7c00

    sti     ;      Enables interrupts

;  --------------------------------------------------------------
    mov word[ss:0x00], handle_zero  ; Stack segment.            ;
    ;   If not specified it'll use data segment "0x00" address  ;
    mov word[ss:0x02], 0x7c0        ; Our segment               ;
;                                                               ;
    mov word[ss:0x04], handle_one                               ;
    mov word[ss:0x06], 0x7c0        ; Our segment               ;
                                                                ;
;  --------------------------------------------------------------


    mov si, message     ; Source index set to message
    call print
    jmp $

error:
    mov si, error_message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

message: db 13, 10, 'Hello RorthOS!', 13, 10, 'v 0.0.3', 13, 10, 0

error_message: db 'Failed to load sector', 0

times 510- ($ - $$) db 0
dw 0xAA55

buffer:

;           nasm -f bin boot.asm -o boot.bin
;           qemu-system-x86_64 -hda boot.bin