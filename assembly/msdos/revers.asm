		.model small
		.stack

BUFSIZ  EQU 256

		.data

hello   db  'Reverse program - MSDOS',0dh,0ah,'$'
prompt  db          'Enter a text line:  ','$'
inver   db  0dh,0ah,'Inverted line:      ','$'
bye    db  0dh,0ah,'Finished'
crlf    db  0dh,0ah,'$'
buffin  db  255
numch   db  0
bufchr  db  BUFSIZ dup(' ')
bufout  db  BUFSIZ dup(' ')

		.code

main    proc
		mov ax, seg hello       ; Setup data segment (DS and ES)
		mov ds, ax
		mov es, ax

		lea dx, hello           ; Show welcome message
		mov ah, 09h
		int 21h

getlin: lea dx, prompt      		; Show prompt
		mov ah, 09h
		int 21h

		lea dx, buffin          ; Input text line
		mov ah, 0ch             ; Clear STDIN buffer
		mov al, 0ah             ; Buffered read DOS function
		int 21h
		mov al, byte ptr [numch]; AL: Number of characters
		cmp al, 0               ; Is the buffer empty?
		je  final               ; Yes: finish

		lea dx,inver		; Display "Inverted..." text 
		mov ah,09h
		int 21h

		lea ax,bufchr           ; AX => Start of input buffer
		sub cx,cx               ; CX => Zero
		mov cl,byte ptr [numch] ; CX => Number of bytes in buffer
		add ax,cx               ; AX => End of input text + 1
		dec ax                  ; AX => End of input text
		mov si,ax               ; SI => End of input text
		lea di,bufout           ; DI => Start of output buffer

theloop:
		std                     ; change direction: decrement
		lodsb                   ; Load byte from DS:SI, decrement SI
		cld                     ; change direction: increment
		stosb                   ; Store byte at ES:DI, increment DI
		loop theloop            ; Check CX and loop if not zero
		mov cx,3                ; Prepare to move 3 more bytes (CR,LF,'$')
		lea si,crlf             ; DS:SI => CR+LF+'$'
		rep movsb               ; Move to ES:DS (append to output buffer)

		lea dx, bufout          ; Display output buffer (inverted text)
		mov ah, 09h
		int 21h

		lea dx,crlf             ; New line...
		mov ah, 09h
		int 21h

		jmp getlin              ; Get one more line to process


final:  	lea dx, bye		; Display goodbye message
		mov ah, 09h
		int 21h

		mov ax, 4C00h		; End program, code=00 (ah=4Ch, al=00h)
		int 21h

		ret
main    endp

		end main
