model small
.stack 100h
.data
inputString db 101 dup ('$')
stringlength dw 0
halfLength dw 0
i dw 1
j dw 0
.code

;---------------------
output_AX PROC
 PUSH AX
 PUSH BX
 PUSH CX
 PUSH DX

 MOV BX, 10
 XOR CX, CX

cycleDiv:                ; цикл сохранения последней цифры в стек
 XOR DX, DX
 DIV BX
 ADD DL, '0'
 PUSH DX
 INC CX
 CMP AX, 0
 JNZ cycleDiv

                        ; цикл печати символов, занесенных в стек
 MOV AH, 2              ; команда вывода символа
cyclePrint:
 POP DX
 INT 21h
 LOOP cyclePrint

 POP DX
 POP CX
 POP BX
 POP AX
 RET
output_AX ENDP
;---------------------

start:
 MOV AX, @data
 MOV DS, AX
 MOV ES, AX

 LEA DI, inputString               ; вычисляет эффективный адрес inputString и помещает его в DI
 CLD                               ; сброс флага направления DF = 0

input:
 MOV AH, 01h                       ; ввод одного символа
 INT 21h
 CMP AL, 10
 JZ inputEnd

 CMP AL, 13
 JZ inputEnd

 STOSB                             ; сохранить AL по адресу ES:(E)DI
 INC stringlength                  ; ++
 JMP input

inputEnd:
 MOV AX, stringlength              ; AX: 00AL = stringlength
 SHR AX, 1                         ; сдвиг битов вправо, AL /= 2
 MOV halfLength, AX
 MOV AX, stringlength              ; AL = stringlength


externalCycle:
 MOV j, 0
compare:
 MOV SI, j
 ADD SI, i
 CMP SI, stringlength
 JZ endInternalCycle               ; SI == stringlength
    MOV SI, j
    MOV CH, inputString[SI]        ; CH = inputString[j]
    ADD SI, i
    MOV CL, inputString[SI]
    CMP CH, CL                     ; inputString[j] != inputString[j + i]
    JNZ endInternalCycle
        INC j                      ; j++
        JMP compare

endInternalCycle:
 XOR DX, DX
 MOV AX, stringlength
 MOV BX, 2
 DIV BX
 CMP DX, 1
 JNZ crutch
    MOV AX, stringlength
    MOV SI, stringlength
    SUB SI, 2                      ; SI = SI - 2
    MOV CH, inputString[SI]
    INC SI                         ; SI++
    MOV CL, inputString[SI];

    CMP CH, CL
    JNZ endExternalCycle

crutch:
 MOV CX, stringlength
 SUB CX, i                         ; CX = CX - i
 CMP j, CX
 JZ period
    INC i                          ; i++
    MOV BX, i
    CMP BX, halfLength
    JA endExternalCycle            ; BX >
    JMP externalCycle

period:
 MOV AX, i

endExternalCycle:
 CALL output_AX

 MOV AH, 4Ch
 INT 21h
end start
