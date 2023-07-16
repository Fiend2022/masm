; Функции для ввода-вывода строк/символов (используется соглашение cdecl)
; void putchar(int c)
; выводит символ на экран (младший байт переданного аргумента)
_putchar proc near
    push bp
    mov bp, sp
    
    mov dx, word ptr [bp + 4]
    mov ah, 02h
    int 21h
    
    mov sp, bp
    pop bp
    ret
_putchar endp    
    
; int getchar()
; читает символ с клавиатуры и возвращает его (считанный символ - младший байт (al) регистра ax)
_getchar proc near
    push bp
    mov bp, sp
    
    mov ah, 01h
    int 21h
    
    mov sp, bp
    pop bp
    ret
_getchar endp

; int strlen(const char *str)
; находит длинну строки (до завершающего нуля), адрес которой является аргументом
_strlen proc near
    push bp
    mov bp, sp
    
    mov bx, word ptr [bp + 4] 
    xor ax, ax ; счётчик (ax)

lencyc:    
    cmp byte ptr [bx], 0
    je lenret
    inc ax
    inc bx
    jmp lencyc
    
lenret:    
    mov sp, bp
    pop bp
    ret
_strlen endp

strsrc$ = 4h ; 1 arg
result$ = -2 ; 1 local
isNegative$ = -4;
base$ = -6;
ten$ = -8;
len$ = -10;
atoi proc

	push bp
	mov bp, sp
	sub sp, 10
	
	mov word ptr isNegative$[bp], 1
	mov word ptr result$[bp], 0
	mov word ptr base$[bp], 1
	mov word ptr ten$[bp], 10
	mov word ptr len$[bp], 0
	mov bx, word ptr strsrc$[bp]

	push bx
	call _strlen
	
	cmp ax, 0
	je errorf
	
	mov word ptr len$[bp], ax
	
	mov bx, word ptr strsrc$[bp]
	
	xor si, si
	cmp byte ptr[bx], '-'
	jne check
	inc bx
	dec word ptr len$[bp]
	
	cmp word ptr len$[bp], 6
	jg errorf
	
	neg word ptr isNegative$[bp]
	
	
check:
		
		xor ax, ax
		mov al, byte ptr [bx + si]
		sub al, '0'
		
		cmp ax, 0
		jb errorf
		cmp ax, 9
		jg errorf
		
		inc si
		;cmp si, word ptr len$[bp]
		cmp si, word ptr len$[bp]
		jl check

		
	mov si, word ptr len$[bp]
	dec si
	
for_i:
		xor ax, ax
		mov al, byte ptr [bx + si]
	
		sub al, '0'
		mul word ptr base$[bp]
		add word ptr result$[bp], ax
		cmp word ptr result$[bp], 32768
		jb atoiCont

		cmp word ptr result$[bp], 32768
		ja errorf
		
		cmp word ptr isNegative$[bp], -1
		jne errorf
		



		
	atoiCont:
		
		mov ax, word ptr base$[bp]
		mul word ptr ten$[bp]
		
		mov word ptr base$[bp], ax
		
		dec si
		cmp si, 0
		jge for_i
	
	mov ax, word ptr result$[bp]
	
	mul word ptr isNegative$[bp]
	
	clc
	
	mov sp, bp
	pop bp
	ret

errorf:
	mov ax, 0
	stc
	mov sp, bp
	pop bp
	ret

atoi endp

    
; void putstr(const char *str)
; выводит строку на экран (до завершающего нуля), адрес которой передан в качестве аргумента
_putstr proc near
    push bp
    mov bp, sp
    
    ; находим длину строки
    push word ptr [bp + 4] 
    call _strlen
    add sp, 2
    
    ; выводим строку
    mov cx, ax
    mov dx, word ptr [bp + 4]
    mov ah, 40h
    mov bx, 1
    int 21h
    
    mov sp, bp
    pop bp
    ret
_putstr endp
    
; void getstr(const char *str, int max_len)
; читает строку с клавиатуры (либо max_len - 1 байт, либо до перевода строки) и сохраняет её в память, 
; при этом дописывает в конец строки завершающий 0
_getstr proc near
    push bp
    mov bp, sp
    
    dec word ptr [bp + 6] ; уменьшаем требуемую длину на 1 (max_len - 1)
    mov bx, word ptr [bp + 4] ; адрес начала строки
    mov si, 0 ; счётчик
 
getscyc: 
    cmp si, word ptr [bp + 6]
    je getsret
    
    call _getchar
    
    cmp al, 10
    je getsret
    cmp al, 13
    je getsret
    
    mov byte ptr [bx], al
    inc bx
    inc si
    jmp getscyc
    
getsret:
    mov byte ptr [bx], 0
    call _putnewline
    mov sp, bp
    pop bp
    ret
_getstr endp

; void putnewline()
; выводит на экран возврат каретки (\r) и перевод строки (\n), т.е. переводит вывод на новую строку
_putnewline proc near
    push bp
    mov bp, sp
    
    mov dx, 10
    push dx
    call _putchar
    add sp, 2
    
    mov dx, 13
    push dx
    call _putchar
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
_putnewline endp

; void exit(int code)
; завершает работу программы с кодом, переданным в качетве аргумента (кодом является младший байт аргумента)  
_exit proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + 4]
    mov ah, 4ch
	int 21h
    
    mov sp, bp
    pop bp
    ret
_exit endp
    
; void exit0()
; завершает работу программы с кодом 0 
_exit0 proc near
    push bp
    mov bp, sp
    
    mov dx, 0
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
_exit0 endp


strstr:
	push bp
	mov bp, sp
	sub sp, 8
	
	mov ax, word ptr [bp + 4]
	push ax
	call _strlen
	mov word ptr [bp - 6], ax ; len of main string
	mov ax, word ptr [bp + 6]
	push ax
	call _strlen
	add sp,2
	mov word ptr [bp - 8], ax ;len of searching string
	mov word ptr [bp - 2], 0 ;i counter
	mov word ptr [bp - 4],0; j counter
	mov ax, -1
	strstr_for_i:
		mov si, word ptr [bp + 4]
		mov bx, word ptr [bp - 2]
		mov dh, byte ptr [bx + si]
		
		mov si, word ptr [bp + 6]
		mov bx, 0
		mov dl, byte ptr [bx + si]
		
		cmp dh, dl
		jne strstr_for_i_iterationEnder
		mov cx, word ptr [bp - 2]
		strstr_for_j:
			mov bx, word ptr [bp - 6]
			cmp word ptr [bp - 2], bx
			je strstr_for_j_notFoundEnder
			mov bx, word ptr [bp - 8]
			dec bx
			cmp word ptr [bp -4] , bx
			je goodSyms
			
			inc word ptr [bp - 4]
			inc word ptr [bp - 2]
			
			mov si, word ptr [bp + 4]
			mov bx, word ptr [bp - 2]
			mov dh, byte ptr [bx + si]
		
			mov si, word ptr [bp + 6]
			mov bx, word ptr [bp - 4]
			mov dl, byte ptr [bx + si]
			
			cmp dh, dl
			je goodSyms
			jne badSyms
			
			goodSyms:
				mov bx, word ptr [bp - 8]
				dec bx
				cmp word ptr [bp - 4], bx
				jne strstr_for_j
				mov bx, cx
				mov si, word ptr [bp + 4]
				lea ax, word ptr [bx+si]
				jmp strstrEnder
				
			badSyms:
				mov word ptr [bp - 4], 0
				mov ax, -1
				jmp strstr_for_i_iterationEnder
				
			strstr_for_j_notFoundEnder:
				mov ax, -1
				jmp strstrEnder
			
		
		strstr_for_i_iterationEnder:
			inc word ptr [bp - 2]
			mov bx, word ptr [bp - 6]
			cmp word ptr [bp - 2], bx
			jne strstr_for_i
	
	strstrEnder:		
		mov sp, bp
		pop bp
		ret

strcpy:
	push bp
	mov bp, sp
	sub sp,4
	
	mov ax, word ptr [bp + 6]
	push ax
	call _strlen
	add sp, 2
	mov word ptr [bp - 2], ax; size
	mov word ptr [bp -4], 0; i
	strcpy_for_i:
		mov bx, word ptr [bp  - 4]
		mov si, word ptr [bp +  6]
		mov dl, byte ptr [bx + si]
		
		mov si, word ptr [bp + 4]
		mov byte ptr [bx + si], dl
		
		inc word ptr [bp -4]
		cmp dl, 0
		jne strcpy_for_i
	
	mov si, word ptr [bp + 4]
	lea ax,word ptr [si]	
	mov sp, bp
	pop bp
	ret


strcmp:
	push bp
	mov bp,sp
	sub sp, 6
	
	mov word ptr [bp - 2], 0
	mov ax, word ptr [bp +4]
	push ax
	call _strlen
	add sp, 2
	mov word ptr [bp - 4], ax
	mov ax, word ptr [bp +6]
	push ax
	call _strlen 
	add sp,2
	mov word ptr [bp -6], ax
	mov bx, word ptr [bp -4]
	cmp bx, word ptr [bp -6]
	jg fgs
	jl fls
	strcmp_for_i:
		mov si, word ptr [bp + 4]
		mov bx, word ptr [bp - 2]
		mov dh, byte ptr [bx+si]
		
		mov si, word ptr [bp + 6]
		mov dl, byte ptr [bx + si]
		
		inc word ptr [bp -2]
		cmp dh, dl
		jg fgs
		jl fls
		
		cmp dh, 0
		jne strcmp_for_i
		
		mov ax, 0
		jmp strcmp_ender
		
		fgs:
			mov ax, 1
			jmp strcmp_ender
		fls:
			mov ax, -1
			jmp strcmp_ender
	
	strcmp_ender:
	
	mov sp, bp
	pop bp
	ret

strchr:
	push bp
	mov bp, sp
	sub sp, 4
	
	mov ax, word ptr [bp + 4]
	push ax
	call _strlen
	add sp, 2
	mov word ptr [bp - 4], ax
	mov word ptr [bp -2], 0; i
	strchr_for_i:
		
		mov bx, word ptr [bp - 2]
		mov si, word ptr [bp + 4]
		xor dx, dx
		mov dl, byte ptr [bx + si]
		mov cx, word ptr [bp - 2]
		inc word ptr [bp - 2]
		cmp dx, 0
		je strchr_ender
		cmp dx, word ptr [bp + 6]
		jne strchr_for_i
		
		mov bx, cx
		mov si, word ptr [bp + 4]
		lea ax, word ptr [bx + si]
		
		
		
		
	strchr_ender:
	mov sp, bp
	pop bp
	ret
	
strcat:
	push bp
	mov bp, sp
	sub sp, 4
	
	mov ax, word ptr [bp + 4]
	push ax
	call _strlen
	add sp, 2
	mov word ptr [bp - 4], ax
	mov ax, word ptr [bp + 8]
	push ax
	mov ax, word ptr [bp + 4]
	push ax
	call strcpy
	add sp, 4
	mov bx, word ptr [bp - 4]
	dec bx
	mov si, word ptr [bp + 8]
	lea ax, word ptr [bx + si]
	push ax
	mov ax, word ptr [bp + 6]
	push ax
	call strcpy
	add sp, 4
	mov ax, word ptr [bp + 8]

		

	mov sp, bp
	pop bp
	ret