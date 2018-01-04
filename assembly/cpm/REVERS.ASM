	  TITLE REVERS - Reverse a String in Z80 ASM for CP/M

	  PUBLIC start

bdos	equ  	0005h		; Address of BDOS gate
printf	equ 	9		; Print string to console BDOS service
reads	equ 	10		; Get string from console BDOS service
BUFSIZE	equ	80		; Buffer size

	;; Literals
hello:	db	'String reverser, CP/M version',13,10,'$'
prompt:	db	'Enter a line:   ','$'
inver:	db	'Inverted line:  ','$'
bye:	db	'Finished',13,10,'$'
crlf:	db	13
lf:	db	10,'$'
	;; Input buffer, in the format expected by BDOS function 10
buffer:	db	BUFSIZE
numch:	db	0
bufchr:	ds	BUFSIZE
	;; Buffer to build the inverted string
bufinv:	ds	BUFSIZE

	
start:	ld   	de,hello	; Display welcome message
        call 	putstr
	
getlin:	ld	de,prompt	; Display prompt
	call	putstr

	ld	de,buffer	; Read string from console
	ld	c,reads
	call	bdos
	ld	de,lf		; ... and put a linefeed
	call	putstr
	
	ld	a,(numch)	; a: Number of characters read
	cp	0		; Have we got anything?
	jr	z,final		; No: finish

	ld	b,a		; b: Number of chars (used as counter)
	ld	d,0		; de: number of chars (to add to hl)
	ld	e,a	
	ld	hl,bufchr	; hl: @beginning of input buffer
	add	hl,de		; hl: @last character + 1
	dec	hl		; h1: @last character in buffer
	ld	de,bufinv	; dw: @Beginning of output buffer
loop:	ld	a,(hl)		; get character pointed by hl
	ld	(de),a		; ... and save it in output buffer
	dec	hl		; Decrement pointer to input string
	inc	de		; Increment pointer to output string
	djnz	loop		; Use b as control counter, decrement/loop
	
	ld	a,'$'		; Add the '$' terminator to the output buffer
	ld	(de),a		; (de still points to the correct address)
	
	ld	de,inver	; Display the "inverted..." text
	call	putstr
	ld	de,bufinv	; Display the actual inverted text
	call	putstr
	ld	de,crlf		; Terminate it with CR+LF
	call 	putstr
	jr	getlin		; Go get another line

	
final:	ld	de,bye		; Displau the goodbye message
	ld	c,printf
	call	bdos
	
	ret          		; Return to BDOS

	;; -------------------------------------------------------------
	;; putstr - Display a '$' terminated string pointed by DE
	;; -------------------------------------------------------------
	;; Destroys c
putstr:	ld	c,printf
	call	bdos
	ret
	
        end start

        
