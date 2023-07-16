stack segment para stack 
db 65535 dup(?)
stack ends

data segment para public


data ends



code segment para public

assume ds:data, ss:stack, cs:code
include strings.inc

setmode proc near
	push bp
	mov bp,sp
	
	mov al, byte ptr [bp + 4]
	mov ah, 00h
	int 10h
	
	mov sp, bp
	pop bp
	ret
setmode endp 

drawpixel proc near
    push bp
    mov bp, sp
    
    mov bh, 0
    mov dx, word ptr [bp + 4]
    mov cx, word ptr [bp + 6]
    mov ax, word ptr [bp + 8]
    mov ah, 0ch
    int 10h
    
    mov sp, bp
    pop bp
    ret
drawpixel endp  

end_y$ = 10
start_y$ = 6
start_x$ = 4
end_x$ = 8
short_distance$ = -4
diagonal_y_increment$= -2
straight_x_increment$ = -6
straight_y_increment$ = -8
straight_count$ = -10
diagonal_count$ = -12
diagonal_x_increment$ = -14
drawLine:
	push bp
	mov bp, sp
	sub sp, 14

	mov cx, 1 ;инкремент для оси x
	mov dx, 1 ;инкремент для оси y

	;вычисление вертикальной дистанции
	mov di,  word ptr end_x$[bp] ;вычитаем координату начальной
	sub di,  word ptr start_x$[bp] ;точки из координаты конечной
	jge keep_y ;вперед если наклон < 0

	neg dx ;иначе инкремент равен -1
	neg di ;а дистанция должна быть > 0

keep_y: 
	mov  word ptr diagonal_y_increment$[bp], dx
	;вычисление горизонтальной дистанции
	mov si,  word ptr end_y$[bp] ;вычитаем координату начальной
	sub si,  word ptr start_y$[bp] ;точки из координаты конечной
	jge keep_x ;вперед если наклон < 0
	neg cx ;иначе инкремент равен -1
	neg si ;а дистанция должна быть > 0

keep_x: 
	mov  word ptr diagonal_x_increment$[bp], cx
	
	;определяем горизонтальны или вертикальны прямые сегменты
	cmp si, di ;горизонтальные длиннее?
	jge horz_seg ;если да, то вперед
	mov cx, 0 ;иначе для прямых x не меняется
	xchg si, di ;помещаем большее в cx
	jmp save_values;сохраняем значения

horz_seg: 
	mov dx,0 ;теперь для прямых не меняется y
save_values: 
	
	mov  word ptr short_distance$[bp], di ;меньшее расстояние
	mov  word ptr straight_x_increment$[bp], cx ;один из них 0,
	mov  word ptr straight_y_increment$[bp], dx ;а другой - 1.
	;вычисляем выравнивающий фактор
	mov ax, word ptr short_distance$[bp] ;меньшее расстояние в ax
	shl ax, 1 ;удваиваем его
	mov word ptr straight_count$[bp], ax ;запоминаем его
	sub ax, si ;2*меньшее - большее
	mov bx, ax ;запоминаем как счетчик цикла
	sub ax, si ;2*меньшее - 2*большее
	mov word ptr diagonal_count$[bp], ax ;запоминаем
	;подготовка к выводу линии
	mov dx, word ptr start_x$[bp] ;начальная координата x
	mov cx, word ptr start_y$[bp] ;начальная координата y
	inc si ;прибавляем 1 для конца
	mov al, word ptr [bp + 12] ;берем код цвета
	
	;теперь выводим линию
mainloop: 
	dec si ;счетчик для большего расстояния
	jz line_finished ;выход после последней точки
	
	mov ah,12 ;функция вывода точки
	int 10h ;выводим точку
	
	cmp bx,0 ;если bx < 0, то прямой сегмент
	jge diagonal_line ;иначе диагональный сегмент
	;выводим прямые сегменты
	add cx,  word ptr straight_x_increment$[bp] ;определяем инкре-
	add dx,  word ptr straight_y_increment$[bp] ;менты по осям
	add bx,  word ptr straight_count$[bp] ;фактор выравнивания
	jmp mainloop ;на следующую точку
	
	;выводим диагональные сегменты
diagonal_line: 
	add cx,  word ptr diagonal_x_increment$[bp] ;определяем инкре-
	add dx,  word ptr diagonal_y_increment$[bp] ;менты по осям
	add bx,  word ptr diagonal_count$[bp] ;фактор выравнивания
	jmp mainloop ;на следующую точку

line_finished:
	
	mov sp, bp
	pop bp
	ret

start:

	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov ax, 04h
	push ax
	call setmode
	add sp, 2
	
	mov ax, 2h
	push ax
	mov ax, 78
	push ax
	mov ax, 13
	push ax
	mov ax, 13
	push ax
	mov ax, 13
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 78
	push ax
	mov ax, 13
	push ax
	mov ax, 78
	push ax
	mov ax, 78
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 78
	push ax
	mov ax, 78
	push ax
	mov ax, 13
	push ax
	mov ax, 13
	push ax
	call drawLine
	add sp,10
	
	
	mov ax, 2h
	push ax
	mov ax, 78
	push ax
	mov ax, 13
	push ax
	mov ax, 13
	push ax
	mov ax, 13
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 78
	push ax
	mov ax, 13
	push ax
	mov ax, 78
	push ax
	mov ax, 78
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 50
	push ax
	mov ax, 32
	push ax
	mov ax, 50
	push ax
	mov ax, 12
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 75
	push ax
	mov ax, 20
	push ax
	mov ax, 50
	push ax
	mov ax, 12
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 75
	push ax
	mov ax, 20
	push ax
	mov ax, 50
	push ax
	mov ax, 32
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 175
	push ax
	mov ax, 180
	push ax
	mov ax, 5
	push ax
	mov ax, 180
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 90
	push ax
	mov ax, 165
	push ax
	mov ax, 5
	push ax
	mov ax, 180
	push ax
	call drawLine
	add sp,10
	
	mov ax, 2h
	push ax
	mov ax, 175
	push ax
	mov ax, 180
	push ax
	mov ax, 90
	push ax
	mov ax, 165
	push ax
	call drawLine
	add sp,10
	
	call _getchar
  
	mov dx, 02h
    push dx
    call setmode
    add sp, 2
	
	mov ax, 4c00h
	int 21h

code ends
end start