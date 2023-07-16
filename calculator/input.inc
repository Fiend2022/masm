
i$ = -2
buffer$ = 4
currentInputFunctionPtr$ = -4


stringInput:
	push bp
	mov bp, sp
	sub sp, 6
	
	mov bx, word ptr buffer$ [bp]
	xor si, si 
	mov word ptr i$[bp], 0
	
	stringInputCycle:
		
		firstNumInput:
			mov ax, word ptr i$[bp]
			push ax
			mov ax, 6
			push ax
			mov ax, bx
			push ax
			mov ax, 0
			push ax
			call numInput
			add sp, 8
			mov word ptr i$[bp], si
			inc word ptr i$[bp]
			
		getOperand:
				mov ah, 08h
				int 21h 
				
				cmp al, 08h
				je getOpBackSpaceProccessing
				
				xor dx,dx
				mov dl, al
				push dx
				call correctOperation
				
				cmp ax, -1
				je getOperand
				
				mov ah, 02h
				int 21h
				
				mov bx, word ptr buffer$[bp]
				mov si, word ptr i$[bp]
				mov byte ptr [bx+si], dl
				inc si
				mov word ptr i$[bp], si
				jmp confirmOperand
				
								
				
				
				getOpBackSpaceProccessing:
					call backSpaceProcessing
					mov si, word ptr i$[bp]
					dec si
					mov word ptr i$[bp], si
					mov bx, word ptr buffer$[bp]
					mov byte ptr [bx + si], 0
					jmp firstNumInput
					
				
				
		confirmOperand:
				mov ah, 08
				int 21h
				
				cmp al, 08h
				je confirmOperandBackSpaceProccessing
				
				cmp al, ' '
				jne confirmOperand
				
				mov dl, al
				mov ah, 02h
				int 21h
				
				mov bx, word ptr buffer$[bp]
				mov si, word ptr i$[bp]
				mov byte ptr [bx+si], ' '
				inc si
				mov word ptr i$[bp], si
				jmp secondNumInput

			confirmOperandBackSpaceProccessing:
				call backSpaceProcessing
				mov si, word ptr i$[bp]
				dec si
				mov word ptr i$[bp], si
				mov bx, word ptr buffer$[bp]
				mov byte ptr [bx + si], 0
				jmp getOperand
			
		secondNumInput:
			mov ax, word ptr i$[bp]
			push ax
			mov ax, word ptr i$[bp]
			add ax, 6
			push ax
			mov ax, bx
			push ax
			mov ax, word ptr i$[bp]
			push ax
			call numInput
			mov word ptr i$[bp], si
			cmp ax, 0
			je confirmOperand
			
		
	mov byte ptr [bx+si],0
	mov sp, bp
	pop bp
	ret

startPosition$ = -2


numInput:
	push bp
	mov bp, sp
	sub sp, 2
	
	mov bx, word ptr [bp + 6]
	mov si, word ptr [bp + 4]
	mov word ptr startPosition$[bp], si
	mov si, word ptr [bp + 10]; currentPosition
	mov cx, word ptr [bp + 8]; maxPosition
	
	
	numInputCycle:
		mov ah, 08h
		int 21h 
		
		cmp al, 08h
		je numInputBackSpaceProcessing
		
		cmp al, ' '
		je spaceProcessing
		
		cmp al, '-'
		je signProcessing
		
		cmp al, '9'
		jg numInputCycle
		cmp al, '0'
		jl numInputCycle
		
		mov byte ptr [bx + si], al
		
		mov ah, 02h
		mov dl, byte ptr [bx + si]
		int 21h
		
		inc si
		cmp si, cx
		jl numInputCycle
		jge numConfirm
		

		signProcessing:
			cmp si, word ptr startPosition$[bp]
			jne numInputCycle
			
			mov dl, al
			mov ah, 02h
			int 21h
			
			mov byte ptr [bx + si], dl
			inc si 
			jmp numInputCycle
			
		spaceProcessing:
			cmp si, word ptr startPosition$[bp]
			je numInputCycle
			
			dec si
			mov al, byte ptr [bx + si]
			inc si
			cmp al, '-'
			je numInputCycle
			
			mov ah, 02h
			mov dl, ' '
			int 21h
			
			mov byte ptr [bx + si], ' '
			
			jmp endOfNumInput
			
		numInputBackSpaceProcessing:
			cmp si, 0
			je numInputCycle
			call backSpaceProcessing
			dec si
			mov byte ptr [bx + si], 0
			
			mov ax, 0
			cmp si, word ptr startPosition$[bp]
			jl endOfNumInput
			
			jmp numInputCycle
			
	numConfirm:
		mov ah, 08h
		int 21h
		
		cmp al, 08h
		je numInputBackSpaceProcessing
		
		cmp al, ' '
		jne numConfirm
		
		mov byte ptr [bx + si] , ' '
		
		mov ah, 02h
		mov dl, ' '
		int 21h
		
		
	
	endOfNumInput:

		mov sp, bp
		pop bp 
		ret

backSpaceProcessing:
		push bp
		mov bp,sp
		
			mov ah, 02h
			mov dl, 08h
			int 21h
		
			mov ah, 02h
			mov dl, ' '
			int 21h
		
			mov ah, 02h
			mov dl, 08h
			int 21h
			
			mov sp, bp
			pop bp
			ret

correctOperation:
	push bp
	mov bp, sp
	
	mov cx, 5
	mov di, 0
	mov bx, offset operations
	mov dx, word ptr [bp + 4]
	
	
	correctCyc:
		mov dh, byte ptr [bx + di]
		cmp dh, dl
		je correctEnder
		inc di
		cmp di, cx
		jne correctCyc
		
	
	mov ax, -1
	correctEnder:
		mov sp, bp
		pop bp 
		ret
