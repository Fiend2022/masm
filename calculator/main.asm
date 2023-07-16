stack segment para stack 
db 65535 dup(?)
stack ends

data segment para public

newLine db 0ah,0dh,"$"


operations db "+-*/%"

string db 16 dup(0)

firstNum dw 0
firstNumSign dw 1

secondNum dw 0
secondNumSign dw 1

opperand db ?

resultSign dw 1

string1 dw ?
string2 dw ?
string3 dw ?

ERR  db "Error: too much big number","$"
ERRZERODIV db "Error: you can't div on zero!","$"

data ends


code segment para public 

assume ds: data, ss:stack, cs:code

include input.inc
include strings.inc

oneStringCut:
	push bp
	mov bp,sp
	
	mov ax, word ptr [bp + 4]
	push ax
	call _strlen
	mov si, ax
	dec si
	mov bx, word ptr [bp + 4]
	cutCycle:
		dec si
		cmp byte ptr [bx + si], ' '
		jne cutCycle
		mov byte ptr [bx + si], 0
		lea ax, [bx + si + 1]
		jmp cutEnd
		
			
	cutEnd:
	mov sp, bp
	pop bp
	ret
	

function:
	push bp
	mov bp, sp
	
	xor bx,bx
	xor ax, ax
	xor cx, cx
	xor dx, dx
		cmp byte ptr [bp + 8], '-'
		jne plus
		mov ax, word ptr [bp + 6]
		mov bx, word ptr [bp + 12]
		neg bx
		neg word ptr [bp + 10]
		jmp sum
	
	plus:
		cmp byte ptr [bp + 8], '+'
		jne multiply
		mov ax, word ptr [bp + 6]
		mov bx, word ptr [bp + 12]
		sum:
		add ax, bx
		mov cx, word ptr [bp + 4]
		mov bx, word ptr [bp + 10]
		cmp cx,bx
		jne plusNotEqSigns
		cmp cl, 1
		je plusEnd
		mov word ptr [resultSign], -1
		jmp plusEnd
		
		plusNotEqSigns:
		mov bx, word ptr [bp + 12]
		cmp ax, bx
		ja firstGr
		mov bx, word ptr [bp + 10]
		mov word ptr [resultSign], bx
		jmp plusEnd
		firstGr:
			mov bx, word ptr [bp + 4]
			mov word ptr [resultSign], bx
			jmp plusEnd
		plusEnd:
		jmp functions_end
	
	multiply:
		cmp byte ptr [bp + 8], '*'
		jne division
		
		mov ax, word ptr [bp + 6]
		mov bx, word ptr [bp + 12]
		imul bx
		
		mov cl, byte ptr [bp + 4]
		mov ch, byte ptr [bp + 10]
		cmp cl,ch
		je mulEnd
		mov byte ptr [resultSign], -1
		mulEnd:
		jmp functions_end
	division:
		cmp byte ptr [bp + 8], '/'
		jne  module
		cmp word ptr [bp + 4], -1
		jne divi
		mov dx, 0FFFFh
		divi:
		mov ax, word ptr [bp+6]
		mov bx, word ptr [bp + 12]
		idiv bx
		mov cl, byte ptr [bp + 4]
		mov ch, byte ptr [bp + 10]
		cmp cl,ch
		je divEnd
		mov byte ptr [resultSign], -1
		divEnd:
		
		xor dx, dx
		jmp functions_end
	module:
		mov ax, word ptr [bp + 6]
		mov bx, word ptr [bp + 12]
		xor dx, dx
		cmp word ptr [bp + 4], -1
		jne modCont
		mov dx, 0FFFFh
		modCont:
		idiv bx
		mov ax, dx
		xor dx, dx
		cmp word ptr [bp + 4], -1
		jne functions_end
		neg ax
		mov bx, word ptr [bp + 12]
		cmp word ptr [bp + 10], -1
		jne posSecNum
		neg bx
		posSecNum:
		sub bx, ax
		mov ax, bx
		xor dx, dx
		
		
		
		
	functions_end:
	mov sp, bp
	pop bp
	ret
	
	
getSign:
	push bp
	mov bp, sp
	
	mov bx, word ptr [bp + 4]
	mov al, byte ptr [bx]
	cmp al, '-'
	jne positive
	
	mov ax, -1
	jmp getSignEnd
	
	positive:
		mov ax, 1
		jmp getSignEnd
		
		
	getSignEnd:
		mov sp, bp
		pop bp
		ret 
	

outputOfNum:
	push bp
	mov bp, sp

	xor cx,cx   
    mov bx,10 
	
	cycle:    
		mov si,ax   
		mov ax,dx  
		xor dx,dx
		div bx      
		mov di,ax   
		mov ax,si   
		div bx      
		push dx     
		inc cx      
		mov dx,di
		or ax,0     
    jnz cycle
output: 
	
	dec cx
	pop dx      ;Восстановим цифру из стека.
    or dl,30h   ;Преобразуем в ASCII.
    
	mov ah, 02h
	int 21h

	cmp cx, 0
	jne output

	

	
	mov sp, bp
	pop bp
	ret
	
errorExit:
	mov ah, 09h
	mov dx, offset ERR
	int 21h 
	
	jmp exit
	

	
start:

	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
	mov ax, offset string
	push ax
	call stringInput
	add sp, 2
	
	mov ah, 09h
	mov dx, offset newLine
	int 21h
	
	mov ax, offset string
	push ax
	call oneStringCut
	add sp, 2
	
	mov word ptr [string3], ax
	
	mov ax, offset string
	push ax
	call oneStringCut
	add sp, 2
	mov bx, ax
	mov al, byte ptr [bx]
	
	mov byte ptr [opperand], al
	
	
	mov bx, offset string
	lea ax, word ptr [bx]
	mov word ptr [string1], ax
	
	
	mov ax, word ptr [string1]
	push ax
	call atoi
	jc errorExit
	add sp, 2
	
	mov word ptr [firstNum], ax
	
	mov ax, word ptr [string3]
	push ax
	call atoi
	jc errorExit
	add sp, 2


	
	mov word ptr [secondNum], ax
	
	lea ax, word ptr [string]
	push ax
	call getSign
	add sp, 2
	
	mov word ptr [firstNumSign], ax
	
	
	mov ax, word ptr [string3]
	push ax
	call getSign
	add sp, 2
	
	mov word ptr [secondNumSign], ax

	xor ax, ax
	mov ax, word ptr [secondNum]
	push ax
	mov ax, word ptr [secondNumSign]
	push ax
	xor ax, ax
	mov al, byte ptr [opperand]
	push ax
	mov ax, word ptr [firstNum]
	push ax
	mov ax, word ptr [firstNumSign]
	push ax
	call function
	add sp, 10
	
	cmp byte ptr [resultSign], -1
	jne otp
	neg ax
	neg dx
	cmp dx, 0
	je cnt
	dec dx
	cnt:
	mov bx, dx
	mov cx, ax
	mov ah, 02h
	mov dl, '-'
	int 21h
	mov ax, cx
	mov dx, bx
	
	otp:
		call outputOfNum
	
	exit:
		mov ax, 4c00h
		int 21h

code ends
end start