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

    mov bh, 0
    mov dx, word ptr [bp + arg1]
    mov cx, word ptr [bp + arg2]
    mov ax, word ptr [bp + arg3]
    mov ah, 0ch
    int 10h
	
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

_drawLine proc near
    push bp
    mov bp, sp
	sub sp, 12

	mov ax, word ptr x0$[bp]
	mov bx, word ptr x1$[bp]
	
	cmp bx, ax
	jge _drawLine_s1
	xchg ax, bx
_drawLine_s1:	
	sub bx, ax

	mov word ptr _dx$[bp], bx
	
	mov ax, word ptr x0$[bp]
	cmp ax, word ptr x1$[bp]
	jge _drawLine_sx_false
		mov word ptr _sx$[bp], 1
		jmp _drawLine_sx_skip
	
_drawLine_sx_false:
		mov word ptr _sx$[bp], -1

_drawLine_sx_skip:
	
	
	mov ax, word ptr y0$[bp]
	mov bx, word ptr y1$[bp]
	
	cmp bx, ax
	jge _drawLine_s2
	xchg ax, bx
_drawLine_s2:	
	sub bx, ax

	neg bx
	mov word ptr _dy$[bp], bx
	
	mov ax, word ptr y0$[bp]
	cmp ax, word ptr y1$[bp]
	jge _drawLine_sy_false
		mov word ptr _sy$[bp], 1
		jmp _drawLine_sy_skip
	
_drawLine_sy_false:
		mov word ptr _sy$[bp], -1

_drawLine_sy_skip:
	
	mov ax, word ptr _dx$[bp]
	add ax, word ptr _dy$[bp]
	mov word ptr _error$[bp], ax
	
	
	
_drawLine_while_true:
		mov ax, word ptr color$[bp]
		push ax
		
		mov ax, word ptr x0$[bp]
		mov bx, word ptr y0$[bp]
		
		push ax
		push bx

		call _drawpixel
		add sp, 6
		
		mov ax, word ptr x0$[bp]
		mov bx, word ptr y0$[bp]
		
			cmp ax, word ptr x1$[bp]
			jne _drawLine_while_cont
			cmp bx, word ptr y1$[bp]
			jne _drawLine_while_cont
			jmp _drawLine_while_true_end
		
_drawLine_while_cont:	
		mov ax, word ptr _error$[bp]
		mov cx, 2
		imul cx
		mov word ptr _e2$[bp], ax
		mov ax, word ptr _e2$[bp]
		cmp ax, word ptr _dy$[bp]
		jl _drawLine_while_else_if
			mov ax, word ptr x0$[bp]
			cmp ax, word ptr x1$[bp]
			jne _drawLine_while_changeX
			jmp _drawLine_while_true_end
			
		_drawLine_while_changeX:
		
		
				mov ax, word ptr _error$[bp]
				add ax, word ptr _dy$[bp]
				mov word ptr _error$[bp], ax
				
				mov ax, word ptr x0$[bp]
				add ax, word ptr _sx$[bp]
				mov word ptr x0$[bp], ax
				
				jmp _drawLine_while_else_if
		
_drawLine_while_else_if:
		
		mov ax, word ptr _e2$[bp]
		mov bx, word ptr _dx$[bp]
		cmp ax, bx
		jg _drawLine_while_true_itt
			mov ax, word ptr y0$[bp]
			cmp ax, word ptr y1$[bp]
			jne _drawLine_while_changeY
			jmp _drawLine_while_true_end
			
		_drawLine_while_changeY:
				
				mov ax, word ptr _error$[bp]
				add ax, word ptr _dx$[bp]
				mov word ptr _error$[bp], ax
				mov ax, word ptr y0$[bp]
				add ax, word ptr _sy$[bp]
				mov word ptr y0$[bp], ax
				
				jmp _drawLine_while_true_itt
		
		
		
_drawLine_while_true_itt:	
	jmp _drawLine_while_true
	
_drawLine_while_true_end:
	
    mov sp, bp
    pop bp
    ret
_drawLine endp


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
		
		mov ax, word ptr color$[bp]
		push ax

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
	sub ax, 60
	push ax
	
	
	
	mov ax, word ptr y0$[bp] ; y0
	add ax, 50
	push ax
	
	mov ax, word ptr x0$[bp] ; x0 
	sub ax, 40
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