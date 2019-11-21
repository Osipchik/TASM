model small
.stack 100h
.data
arraySize dw ?
containerSize dw 2
initialArray dw 100 dup(0)
resultingArray dw 100 dup(0)
rowLength dw ?
tempRow dw ?
tempCol dw ?
tempVal dw ?
newRow dw ?
newCol dw ?
row dw ?
col dw ?
.code
;-------------------------------------
input PROC
 XOR BX, BX
 inputCycle:
    MOV AH, 01h
    INT 21h
    MOV AH, 0
    CMP AL, 10
        JZ cycleBreak
    CMP AL, ' '
        JZ cycleBreak

    SUB AL, '0'
    PUSH AX                     ; помещаем цифру в стек
    MOV CX, 10
    MOV AX, BX
    MUL CX                      ; увеличиваем разряд числа в AX
    POP BX                      ; возвращаем цифру из стека
    ADD AX, BX                  ; получаем число из AX и BX
    MOV BX, AX
 JMP inputCycle
 cycleBreak:
  MOV AX, BX
  RET
input ENDP
;-------------------------------------
inputMatrix PROC
 XOR SI, SI
 matrixInputCycle:
    CALL input
    MOV initialArray[SI], AX
    ADD SI, 2
    DEC arraySize
    CMP arraySize, 0
 JNZ matrixInputCycle
inputMatrix ENDP
;-------------------------------------
rotateMatrix PROC
 XOR SI, SI
 MOV AX, rowLength
 MUL rowLength
 MOV CX, AX
 cycleRotate:
    PUSH CX
    MOV AX, SI
    DIV containerSize           ; делим на 2 т.к размерность dw
    DIV rowLength
    MOV tempRow, AX             ; сохранили частное
    MOV tempCol, DX             ; сохранили остаток
    XOR AX, AX
    XOR DX, DX
    MOV DX, initialArray[SI]    ; сохраняем цифру
    MOV tempVal, DX
    MOV AX, rowLength
    SUB AX, tempRow
    DEC AX
    MOV newCol, AX              ; newCol = rowLength - tempRow - 1

    MOV AX, tempCol
    MOV newRow, AX
    XOR AX, AX

    MOV AX, newRow
    MUL rowLength
    ADD AX, newCol
    MUL containerSize           ; умножаем на 2 т.к размерность dw
    MOV BX, AX

    MOV AX, tempVal
    MOV resultingArray[BX], AX  ; вставляем число в нужную позицию

    SUB SI, containerSize
    POP CX
 LOOP cycleRotate
 RET
rotateMatrix ENDP
;-------------------------------------
printRow PROC
 XOR CX,CX
 setRowValueCycle:
    XOR DX, DX
    MOV BX, 10
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
 JNZ setRowValueCycle
 printValueCycle:
    POP DX
    ADD DX, '0'
    MOV AH, 02h
    INT 21h
 LOOP printValueCycle
 RET
printRow ENDP
;-------------------------------------
printMatrix PROC
 XOR SI, SI
 MOV CX, rowLength
 MOV col, CX
 MOV row, CX
 XOR CX, CX
 matrixPrintingCycle:
    MOV AX, resultingArray[SI]
    CALL printRow
    MOV DL, ' '
    MOV AH, 02h
    INT 21h

    ADD SI, 2

    DEC col
    CMP col, 0
    JNZ matrixPrintingCycle
        MOV CX, rowLength
        MOV col, CX
        MOV DL, 10
        MOV AH, 02h
        INT 21h
        XOR DH, DH
        MOV DL, 13
        MOV AH, 02h
        INT 21h
        DEC row
        CMP row, 0
 JNZ matrixPrintingCycle
 RET
printMatrix ENDP
;-------------------------------------
start:
 MOV AX, @data
 MOV DS, AX

 CALL input
 MOV rowLength, AX
 MUL rowLength
 MOV arraySize, AX

 CALL inputMatrix
 CALL rotateMatrix
 CALL printMatrix

 MOV AH, 4Ch
 INT 21h
end start
