model small
.stack 100h
.data
a dw 1
b dw 2
c dw 3
d dw 4
.code

start:
 MOV AX, @data
 MOV DS, AX

 MOV AX, a
 MOV BX, b
 MOV CX, c
 MOV DX, d

 XOR AX, BX       ; AX = a ^ b
 ADD CX, DX       ; BX = c + d
 CMP AX, CX       ; if a ^ b == c + d
 JE aXORb
                  ; false
 MOV AX, a
 AND AX, BX       ; AX = a & b

 MOV CX, c
 ADD CX, DX       ; CX = c + d
 CMP AX, CX       ; if a & b == c + d
 JE aANDb
                  ; false
 MOV AX, a
 MOV CX, c

 OR AX, BX        ; AX = a | b
 OR AX, CX        ; AX = AX | c
 OR AX, DX        ; AX = AX | d
JMP Finish
aXORb:
 MOV CX, c
 MOV AX, a
 AND AX, CX       ; AX = a & c
 OR BX, DX        ; BX = b | d
 ADD AX, BX
JMP Finish
aANDb:
 MOV AX, a
 MOV CX, c
 XOR AX, BX       ; AX = a ^ b
 XOR AX, CX       ; AX = AX ^ c
 XOR AX, DX       ; AX = AX ^ d
Finish:

 MOV AH, 4Ch
 INT 21h
end start




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

