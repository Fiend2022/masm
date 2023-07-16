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

drawLineX proc near
	push bp
	mov bp,sp
	sub sp, 2
	
	mov cx, word ptr [bp + 8]
	mov word ptr [bp - 2], cx
	
	drawXCyc:
		xor ax, ax
		mov ax, word ptr [bp + 10]
		push ax
		mov ax, word ptr [bp + 4]
		push ax
		mov ax, word ptr [bp + 6]
		push ax
		call drawpixel
		add sp, 6
		dec word ptr [bp -2]
		inc word ptr [bp + 4]
		cmp word ptr [bp -2], 0
		jne drawxCyc
	
	
	
	
	mov sp, bp
	pop bp
	ret

drawLineX endp 

drawLineY proc near
	push bp
	mov bp,sp
	sub sp, 2
	
	mov cx, word ptr [bp + 8]
	mov word ptr [bp - 2], cx
	
	drawYCyc:
		xor ax, ax
		mov ax, word ptr [bp + 10]
		push ax
		mov ax, word ptr [bp + 4]
		push ax
		mov ax, word ptr [bp + 6]
		push ax
		call drawpixel
		add sp, 6
		dec word ptr [bp -2]
		inc word ptr [bp + 6]
		cmp word ptr [bp -2], 0
	jne drawYCyc
	
	mov sp, bp
	pop bp
	ret

drawLineY endp 

start:

	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov ax, 0dh
	push ax
	call setmode
	add sp, 2
	
	mov ax, 6h
	push ax
	mov ax, 150
	push ax
	mov ax, 13
	push ax
	mov ax, 0
	push ax
	call drawLineX
	add sp, 8
	
	mov ax, 3h
	push ax
	mov ax, 79
	push ax
	mov ax, 28
	push ax
	mov ax, 16
	push ax
	call drawLineY
	add sp, 8 
	
	call _getchar
  
    ; Переходим в текстовый режим 80х25
    mov dx, 02h
    push dx
    call setmode
    add sp, 2
	
	
	
	
	mov ax, 4c00h
	int 21h

code ends
end start