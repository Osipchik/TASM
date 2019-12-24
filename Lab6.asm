.model tiny                     ; чтобы компилить в com
.code
.startup                        ; создает код запуска проги
.386
jmp start
    flag1 db 0                  ; используем в прерывании ( по калашникову )
    old_int9h_offset dw ?
    old_int9h_segment dw ?
        NumberRemainder dw 0    ; сдвиг для цифр
        LetterRemainder dw 0    ; сдвиг для букв
    ten dw 10                   ; кол-во цифр
    ABC dw 26                   ; кол-во букв
    shift dw 0                  ; введенный сдвиг

EnterLetterProc proc            ; собираем сдвиг
                                ; лепим числа
    mov dx,0
    nextletter:
        mov ah,01h
        int 21h

        CMP al,0Dh              ; сравнение с enter
        jz strend

        CMP al,20h              ; сравнение с spaсe
        jz space

            sub al,30h          ; -0
            push ax
            mov ax,dx
            mul ten
            mov dx,ax

            pop ax
            add dl,al


    jmp nextletter
    space:
    strend:
    mov shift,dx                ; заносим в сдвиг DX
    ret
EnterLetterProc endp

CountRemainders proc
        push ax
        push bx
        push cx
        push dx

        mov ax,shift            ; сдвиг в AX
        xor dx,dx
         div ten
        mov NumberRemainder,dx  ; заносим сдвиг в переменню для сдвига цифр
        xor dx,dx
        mov ax,shift
        div ABC
        mov LetterRemainder,dx  ; заносим сдвиг в переменную для букв


        pop dx
        pop cx
        pop bx
        pop ax

ret
CountRemainders endp


    ; функция прерывания (из калашникова)
    new_int9h proc far ; для дальнего вызова
        pusha
        push es
        push ds
        push cs
        pop ds
        pushf

        mov bx,0
        mov dx,0


        call dword ptr cs:[old_int9h_offset]
        mov ax,40h
        mov es,ax
        mov bx,es:[1ch]
        cmp bl,30
        jne continue
        mov bl,60
    continue:
        sub bl,2
        mov ax,es:[bx]
        jmp KEYPRESS
    decide_step1:
        pop ax
        cmp flag1,1
        jne check

        mov es:[1ch],bx
        jmp intend
    check:
        mov di,bx
        sub di,2
        jmp intend
    ;==========================

    KEYPRESS:

        mov dx,ax
        push ax
        xor ah,ah

        cmp dl,27               ; escape
        je zero

    	cmp dl,123              ; конец маленьких букв
        jge withoutREM

        cmp dl,97               ; начало маленьких букв
        jge BigLetter

		cmp dl,91               ; конец больших букв
        jge withoutREM

        cmp dl,65               ; начало больших букв
        jge LittleLet

		cmp dl,58               ; конец цифр
        jge withoutREM

        cmp dl,48               ; начало цифр
        jge CASENUMBER

		cmp dl,32               ; пробел
        jge withoutREM

    BIGLETTER:
        add ax,LEtterRemainder
        cmp ax,123
        jl withoutREM       ; если не выходит из промежутка

        sub ax,123          ; переносим в промежуток
        add ax,97           ;


    withoutREM:

        jmp ending
    LittleLet:
        mov al,dl
        add ax,LEtterRemainder
        cmp  al,91
        jl withoutREM2
        sub al,91
        add al,65
        withoutREM2:

    jmp ending
    CASENUMBER:
        mov al,dl
        add ax,NUMBERREMAINDER
        cmp  al,58
        jl ending

        sub al,58
        add al,48
        ending:                     ; выводим этот же символ
        mov es:[bx],ax
        mov flag1,0
        jmp decide_step1
zero:                               ; убиравем сдвиг
    mov LEtterRemainder,0
    mov NUmberRemainder,0
lable:
    mov flag1,1
    jmp decide_step1


    intend:
    pop ds
    pop es
    popa
    iret
new_int9h endp


start:
    mov ax,3509h                    ; получение старого вектора прерывания
    int 21h
    call EnterLetterProc
    call CountRemainders

                                    ; обработка прерывания
    push es
    mov ax, ds:[2Ch]
    mov es, ax
    mov ah, 49h
    int 21h
    pop es
    mov cs:old_int9h_offset, bx    ; заносим смещение прерывания
    mov cs:old_int9h_segment, es   ; заносим сегмент прерывания
    mov ax, 2509h                  ; устанавливаем вектор прерывания
    mov dx, offset new_int9h       ; вызываем прерывание
    int 21h

    mov dx, offset start
    int 27h                        ; оставляем прогру резедентной в памяти (фоновой)
    ; exit:
    ; push es
    ; push ds
    ; mov dx, es:old_int9h_offset
    ; mov ds, es:old_int9h_segment
    ; mov ax, 2509h
    ; int 21h
    ; pop ds
    ; pop es
    ; mov ah, 49h
    ; int 21h
    ; int 20h
end
