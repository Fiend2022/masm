arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

stack segment para stack
db 65530 dup(?)
stack ends

data segment para public
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

include strings.inc
    
; void setmode(int mode)
; установка видеорежима (номер режима в младшем байте аргумента)    
_setmode proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg1]
    mov ah, 00h
    int 10h
    
    mov sp, bp
    pop bp
    ret
_setmode endp 

; void drawpixel(int row, int column, int color)
; рисование пикселя (код цвета в младшем байте аргумента)    
_drawpixel proc near
    push bp
    mov bp, sp
	
	push ax
	push bx
	push cx
	push dx
	
	;push cx
	;xor ax, ax
	;mov ax, 0eh
	;push ax
	;call _setmode
	;add sp, 2
	
    mov bh, 0
    mov dx, word ptr [bp + arg1]
    mov cx, word ptr [bp + arg2]
    mov ax, word ptr [bp + arg3]
    mov ah, 0ch
    int 10h
	
	;xor ax, ax
	;mov ax, 3
	;push ax
	;call _setmode
    ;add sp, 2
    ;pop cx
	
	pop dx
	pop cx
	pop bx
	pop ax
	
    mov sp, bp
    pop bp
    ret
_drawpixel endp  


color$ = 12
y1$ = 10
x1$ = 8
y0$ = 6
x0$ = 4

_dx$ = -2
_dy$ = -4
_sx$ = -6
_sy$ = -8
_error$ = -10
_e2$ = -12

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
_drawLine:
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


color$ = 12
y1$ = 10
x1$ = 8
y0$ = 6
x0$ = 4

_i$ = -2
_drawRectangle proc

	push bp
	mov bp, sp
	sub sp, 2

	mov ax, word ptr y0$[bp]
	mov bx, word ptr y1$[bp]
	
	cmp ax, bx
	jl _drawRectangle_s1
	xchg ax, bx
_drawRectangle_s1:	

	mov word ptr y0$[bp], ax
	mov word ptr y1$[bp], bx

	mov ax, word ptr y0$[bp]
	mov word ptr _i$[bp], ax
	
_drawRectangle_fori:
		
		; drawline(int x0, int y0, int x1, int y1, int color)
		
		mov ax, word ptr color$[bp]
		push ax
		
		;mov ax, word ptr y1$[bp]
		;push ax
		mov ax, word ptr _i$[bp]
		push ax
		
		mov ax, word ptr x1$[bp]
		push ax
		
		mov ax, word ptr _i$[bp]
		push ax
		
		mov ax, word ptr x0$[bp]
		push ax
		
		call _drawLine
		add sp, 10
	
	inc word ptr _i$[bp]
	mov ax, word ptr _i$[bp]
	cmp ax, word ptr y1$[bp]
	jl _drawRectangle_fori


	mov sp, bp
    pop bp
    ret
_drawRectangle endp




seconds$ = -2
x0$ = -4
y0$ = -6
R$ = -8
x1$ = -10
y1$ = -12
Y$ = -14 ; arr[12]
X$ = -38 ; arr[12]
index$ = -64
_radar proc near
    push bp
    mov bp, sp
	sub sp, 70
	
	xor ax, ax
	int 1ah
	mov word ptr seconds$[bp], dx
	
	
	
	mov word ptr index$[bp], 0
	mov word ptr x0$[bp], 300
	mov word ptr y0$[bp], 100
	mov word ptr R$[bp],  60
	
	; cos
	mov word ptr [bp + Y$], 40
	
	mov word ptr [bp + Y$ - 2], 49
	mov word ptr [bp + Y$ - 4], 70
	mov word ptr [bp + Y$ - 6], 100 
	
	mov word ptr [bp + Y$ - 8], 130
	mov word ptr [bp + Y$ - 10], 151
	mov word ptr [bp + Y$ - 12], 160
	mov word ptr [bp + Y$ - 14], 151
	mov word ptr [bp + Y$ - 16], 130
	mov word ptr [bp + Y$ - 18], 100
	mov word ptr [bp + Y$ - 20], 70
	mov word ptr [bp + Y$ - 22], 49
	
	
	; sin
	mov word ptr [bp + X$], 300
	
	mov word ptr [bp + X$ - 2], 330
	mov word ptr [bp + X$ - 4], 351
	mov word ptr [bp + X$ - 6], 360
	mov word ptr [bp + X$ - 8], 351 
	mov word ptr [bp + X$ - 10], 330
	
	mov word ptr [bp + X$ - 12], 300 
	
	mov word ptr [bp + X$ - 14], 270 
	mov word ptr [bp + X$ - 16], 249 
	mov word ptr [bp + X$ - 18], 240 
	mov word ptr [bp + X$ - 20], 249 
	mov word ptr [bp + X$ - 22], 270 
_radarWhile:	
	
	xor ax, ax
	int 1ah
	
	mov ax, dx
	
	sub ax, word ptr seconds$[bp]
	cmp ax, 9
	jl _radarWhile
	
	mov word ptr seconds$[bp], dx
	
	xor ax, ax
	mov ax, 0eh
	push ax
	call _setmode
	add sp, 2

	cmp word ptr index$[bp], 2
	jne _radar_rect2_s
	mov ax, 04h 
	push ax 
	
	mov ax, word ptr y0$[bp] ; y1
	sub ax, 20
	push ax
	
	mov ax, word ptr x0$[bp] ; x1
	add ax, 40
	push ax
	
	mov ax, word ptr y0$[bp] ; y0
	sub ax, 10
	push ax
	
	mov ax, word ptr x0$[bp] ; x0 
	add ax, 20
	push ax
	
	call _drawRectangle
	add sp, 10
	
_radar_rect2_s:
	
	cmp word ptr index$[bp], 9
	jne _radar_rect3_s
	mov ax, 04h 
	push ax 
	
	mov ax, word ptr y0$[bp] ; y1
	add ax, 5
	push ax
	
	mov ax, word ptr x0$[bp] ; x1
	sub ax, 40
	push ax
	
	
	
	mov ax, word ptr y0$[bp] ; y0
	sub ax, 5
	push ax
	
	mov ax, word ptr x0$[bp] ; x0 
	sub ax, 20
	push ax
	
	call _drawRectangle
	add sp, 10
	
	
_radar_rect3_s:

	cmp word ptr index$[bp], 7
	jne _radar_line_s
	mov ax, 04h 
	push ax 
	
	mov ax, word ptr y0$[bp] ; y1
	add ax, 40
	push ax
	
	mov ax, word ptr x0$[bp] ; x1
	sub ax, 40
	push ax
	
	
	
	mov ax, word ptr y0$[bp] ; y0
	add ax, 50
	push ax
	
	mov ax, word ptr x0$[bp] ; x0 
	sub ax, 20
	push ax
	
	call _drawRectangle
	add sp, 10
	
_radar_line_s:
	mov ax, 02h
	push ax

	lea bx, word ptr Y$[bp]
	
	mov ax, 2
	mov cx, word ptr index$[bp]
	mul cx
	sub bx, ax
	
	mov ax, word ptr ss:[bx]
	push ax
	
	
	lea bx, word ptr X$[bp]
	mov ax, 2 ; sizeof
	mov cx, word ptr index$[bp]
	mul cx
	sub bx, ax
	
	mov ax, word ptr ss:[bx]
	push ax
	
	mov ax, word ptr y0$[bp] ; y0
	push ax
	mov ax, word ptr x0$[bp] ; x0 
	push ax
	call _drawLine
	add sp, 10
	
	inc word ptr index$[bp]
	cmp word ptr index$[bp], 12
	jl indexsubskip
	sub word ptr index$[bp], 12
indexsubskip:
	
	mov ah, 01h
	int 16h
	jnz _radarWhile_lj_s
	jmp far ptr _radarWhile
_radarWhile_lj_s:	
	
	mov ax, 3
	push ax
	call _setmode
    add sp, 2
	
_radar_end:
	
    mov sp, bp
    pop bp
    ret
_radar endp
    
start: ; вызов функции radar (модифицировать главную функцию программы не требуется)
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
    call _radar
    
    call _exit0
code ends
end start