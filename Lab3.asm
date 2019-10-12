model small
.stack 100h
.data
a dw -1
b dw 0
c dw 0
d dw 0
NegativeValue dw 1
ErrorOutput db 'Bad input$'
ZeroDivision db 'Zero division$'
.code

start:
 MOV AX, @data
 MOV DS, AX

 MOV DI, NegativeValue

 CALL ReadString
 MOV a, AX
 CALL ReadString
 MOV b, AX
 CALL ReadString
 MOV c, AX
 CALL ReadString
 MOV d, AX

 MOV AX, a
 MOV CX, c
 ADD AX, CX

 MOV BX, b
 MOV DX, d
 SUB BX, DX

 CMP AX, BX
 JNE else1
     MOV AX, a
     MOV BX, b
     ADD AX, BX
     SUB AX, CX
     SUB AX, DX
     JMP toNextLine
 else1:
  ADD BX, DX
  ADD BX, DX
  CMP AX, BX
  JNE else2
      MOV AX, a
      MOV BX, d
      CWD                 ;  CWD копирует значение АH на все биты регистра DX
      IMUL BX
      PUSH AX

      MOV AX, c
      MOV BX, d
      MOV CX, 0
      CMP BX, CX
      JZ zero_division

      XOR DX, DX
      CWD
      IDIV BX
      ADD DX, BX
      CWD
      IDIV BX

      POP AX
      MOV BX, DX
      SUB AX, BX
      JMP toNextLine
 else2:
  MOV CX, a
  MOV BX, d
  ADD CX, BX
  PUSH CX

  MOV AX, b
  MOV CX, c
  MOV DX, 0
  CMP CX, DX
  JZ zero_division

  XOR DX, DX
  CWD
  IDIV CX
  ADD DX, CX
  MOV AX, DX

  XOR DX, DX
  CWD
  IDIV CX
  MOV BX, b
  SUB BX, DX
  MOV AX, BX

  XOR DX, DX
  CWD
  IDIV CX

  POP CX
  SUB CX, AX
  MOV AX, CX
  JMP toNextLine

 zero_division:
  LEA DX, ZeroDivision
  MOV AH, 09h
  INT 21h
  JMP programEnd

 toNextLine:
  XOR CX, CX
  MOV BX, 10
  SAHF              ; изменит флаг знака (помещает AH)
  JNS division      ; переход если SF 0
      PUSH AX

      MOV DL, '-'
      MOV AH, 02h
      INT 21h

      POP AX
      NEG AX


 division:
  XOR DX, DX
  DIV BX
  ADD DX, '0'
  PUSH DX
  INC CX
  TEST AX, AX
  JNZ division

 output:
  POP DX
  MOV AH, 02h
  INT 21h
  LOOP output     ; итерируется по CX пока CX > 0
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
     CMP AL, '-'
  JZ makeSiNegative
     CMP AL, 8
  JZ backspace
     CMP AL, '0'
  JL error
     CMP AL, '9'
  JG error
 ;-------------

  MOV AH, 0
  SUB AL, '0'      ; отнимаем код нуля, чтобы получить введенную цифру

  MOV CX, 10
  PUSH AX          ; сохраняем значение AX в стек
  MOV AX, BX
  MUL CX           ; увеличиваем разряд AX
  POP BX           ; возвращаем AX в BX
  ADD AX, BX
  MOV BX, AX
  JMP input

 makeSiNegative:
  CMP SI, DI
  JZ error

  XOR AX, AX
  MOV SI, NegativeValue
  JMP input

 backspace:
  MOV AX, BX
  MOV CX, 10       ; удаляем последний символ в AX
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
  CMP SI, DI
  JNZ procEnd
      NEG AX
      XOR SI, SI

 procEnd:
  RET              ; возвращяет IP в точку вызова
 ReadString ENDP
 ;----------------------------


programEnd:
 MOV AL, 0
 MOV AH, 4Ch
 INT 21h
end start
