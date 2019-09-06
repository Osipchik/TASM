model small
.stack 100h
.data
a dw 5
b dw 6
c dw 7
d dw 2
.code

start:
 MOV AX, @data
 MOV DS, AX

 MOV AX, a
 MOV BX, b
 MOV CX, c

 MUL AX           ; AX = a * a
 XOR BX, CX

 MOV DX, d
 XOR BX, DX

 CMP AX, BX
 JE IsEqual
;OK
 MOV BX, b

 AND CX, BX       ; CX = c & b

 MOV AX, a

 ADD AX, CX       ; AX = CX + a
 JMP Finish
IsEqual:
 MOV CX, c
 ADD CX, 101b     ; CX = c + 5
 MOV AX, a
 CMP CX, AX       ; c + 5 == a
 JE IsTrue

 MOV CX, c
 AND AX, CX       ; AX = a & c
 OR AX, DX        ; AX = AX | d

 JMP Finish
IsTrue:
 MOV AX, a
 MOV BX, b
 MUL BX           ; DX:AX = a * b, DX = NULL
 XOR CX, 100b     ; CX = c ^ 4
 ADD AX, CX       ; AX = a * b + CX
Finish:

 MOV AH, 4Ch
 INT 21h
end start
