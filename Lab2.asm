model small
.stack 100h
.data
a dw 14
b dw 7
c dw 10
d dw 9
ErrorOutput db 'Bad input$'
.code

start:
 MOV AX, @data
 MOV DS, AX

 CALL ReadString
 MOV a, AX
 CALL ReadString
 MOV b, AX
 CALL ReadString
 MOV c, AX
 CALL ReadString
 MOV d, AX


 MOV BX, b
 MOV AX, a
 CMP BX, AX
 JB more
    MOV AX, a
    ADD AX, b
    MOV CX, c
    ADD CX, d
    CMP AX, CX
    JB less
        MOV CX, a
        ADD CX, d
        MOV AX, c
        AND AX, CX
        JMP toNextLine
   less:
    MOV CX, c
    XOR CX, a
    MOV AX, b
    OR AX, CX
    JMP toNextLine
 more:
  MOV AX, c
  XOR AX, d
  OR AX, a

 toNextLine:
 XOR CX, CX
 MOV BX, 10

 delenie:
 XOR DX, DX
 DIV BX
 ADD DX, '0'
 PUSH DX
 INC CX
 TEST AX, AX
 JNZ delenie

 output:
 POP DX
 MOV AH, 02h
 INT 21h
 LOOP output
 JMP programEnd

;----------------------------
 ReadString PROC
 XOR BX,BX
input:
 MOV AH, 01h     ; ввод одного символа
 INT 21h
 CMP AL, 10      ; 13 - Enter
 JZ inputEnd

 ;-------------  только на эту лабу
    CMP AL, 8
 JZ backspace
    CMP AL,'0'
 JL error
    CMP AL,'9'
 JG error
 ;-------------

    MOV AH, 0
    SUB AL, '0'   ; отнимаем код нуля, чтобы получить введенную цифру

    MOV CX, 10    ; 13
    PUSH AX       ; сохраняем значение AX в стек
    MOV AX, BX
    MUL CX
    POP BX        ; возвращаем AX в BX
    ADD AX, BX
    MOV BX, AX
 JMP input

backspace:
 MOV AX, BX
 MOV CX, 10       ; 13
 DIV CX
 MOV DX, 0
 MOV BX, AX
 JMP input

error:
 LEA DX, ErrorOutput
 MOV AH, 09h
 INT 21h
 JMP programEnd

inputEnd:
 MOV AX, BX
 RET              ; возвращяет IP в точку вызова
ReadString ENDP
;----------------------------

programEnd:

 MOV AH, 4Ch
 INT 21h
end start
