
model small
.stack 100h
.data
a dw 6
b dw 8
c dw 10
d dw 4
.code

start:
 MOV AX, @data
 MOV DS, AX
;<readABCD>
 MOV AX, a
 MOV BX, b
 MOV CX, c

 AND AX, d        ; AX = a & d
 OR CX, d         ; CX = c | d
 CMP AX, CX       ; if a & d == c | d
 JE aXORb
                  ; false
 MOV AX, a
 AND BX, d        ; BX = b & d
 ADD BX, AX       ; BX = BX + a
 CMP AX, c        ; if a + b & d == c
 JE aANDb
                  ; false
 MOV AX, a
 MOV CX, c

 XOR AX, b        ; AX = a ^ b
 AND CX, d        ; CX = c & d
 OR AX, CX        ; AX = AX | CX
JMP Finish
aXORb:
 MOV AX, a
 AND AX, c        ; AX = a & c
 AND BX, d        ; BX = b & d
 ADD AX, BX       ; AX = AX + BX
JMP Finish
aANDb:
 MOV AX, a
 MOV CX, c
 OR AX, b         ; AX = a | b
 AND CX, d        ; CX = c & d
 OR AX, CX        ; AX = AX | CX
Finish:

;<print>
 MOV AH, 4Ch
 INT 21h
end start
