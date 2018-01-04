	.list off
	.include "c64.inc"
	.list on
	
	.code

	;; Constants
	CR     	= $0D		; Carriage return literal
	CHRIN  	= $FFCF		; KERNAL Read character from input
	CHROUT 	= $FFD2		; KERNAL Write character to output
	CHPTRO 	= FREKZP	; Page-zero word for input buffer
	STKBSE 	= $0100		; Base of 6502 stack
	
	.proc	_main
	
	;; -------------------------------------------------------------
	;; Main procedure
	;; 
start:	lda	#<hello		; Load welcome message address
	pha
	lda	#>hello
	pha
	jsr	putstr		; ... and show it
	pla			; Remove address from stack
	pla			;
	;; 
getlin:	jsr	newline		; New line before prompt
	lda	#<prompt	; Show prompt
	pha
	lda	#>prompt
	pha
	jsr	putstr
	pla
	pla
	;;	Get a line from the user
	ldy	#$0		; Ponter-index: zero
loop:	jsr	CHRIN		; Read character using KERNAL
	cmp	#CR		; Is it carriage return?
	beq	filoop		; Yes, we've got a line
	sta	buffin,Y	; No: store the character in buffer...
	iny			; ... and increment the pointer-index
	jmp	loop		; Get next character
	;; 
filoop:	cpy	#0		; Have we got any character?
	beq	final		; No, finish the process
	sty	numch		; Yes, store the number of characters	
	lda	#0		; Append a null marker
	sta	buffin,Y	
	;;
	jsr	newline		; New line on screen
	lda	#<invert	; Show "inverted" message
	pha
	lda	#>invert
	pha
	jsr	putstr
	pla
	pla
	;; Let's reverse the buffer
	ldx	#0		; X-> Index for output buffer
	ldy	numch
iloop:	dey			; Do not move final null
	lda	buffin,y	; We get characters from the end...
	sta	bufout,x	; ... and store from the beginning
	inx
	cpx	numch		; How many chars have we done?
	bne	iloop		; Loop until don
	lda	#0
	sta	bufout,x	; Add final null
	;; 
	lda	#<bufout	; Display inverted string
	pha
	lda	#>bufout
	pha
	jsr	putstr
	pla
	pla
	;;
	jmp	getlin		; Get one more line
	;; 
final:	jsr	newline
	lda	#<adeu		; Show the goodbye message
	pha
	lda	#>adeu
	pha
	jsr	putstr
	pla
	pla
	;; 
	rts

	.endproc

	;; -------------------------------------------------------------
	;; putstr procedure: put out a zero-terminated string
	;; -------------------------------------------------------------
	;; The address is in the stack. The low byte has to be
	;; pushed before the hight byte.
	;; At entry, the parameters are at SP+3
	;; Since we use the stack to preserve X and Y, we must
	;; get them at SP+5. To make it easier to understand, we will
	;; index using X+4. We use 4 INX instead of moving to ACC, adding
	;; and moving back to X to save cycles (hehehe).
	;; Uses the CHPTRO/CHRTRO+1 zero page addresses
	;; Clobbers the Accumulator
	.proc	putstr
	tya			; Preserve Y
	pha
	txa			; Preserve X
	pha
	tsx			; X = Stack pointer
	inx			; Adjust X for parameters in stack
	inx			;
	inx			;
	inx			; X = end of parameters in stack
	lda	STKBSE+1,X	; Get high byte of string address
	sta	CHPTRO+1	; ... store it in zero page pointer
	inx
	lda	STKBSE+1,X	; Get low byte of string address
	sta	CHPTRO		; ... store it in zero page pointer
	ldy	#$0		; Y: zero 
@loop:	lda	(CHPTRO),y	; Load byte at CHPTRO + y
	beq	@xloop		; If null, end of string
	jsr	CHROUT		; Put character using KERNAL
	iny			; Increment Y for next byte
	jmp	@loop		; And repeat
@xloop: pla			; Restore the X register
	tax			; ... using the accumulator
	pla			; Restore Y register
	tay			; ... using the accumulator
	rts
	.endproc

	;; -------------------------------------------------------------
	;; Output a newline (CR) using KERNAL
	;; -------------------------------------------------------------
	.proc newline
	lda	#CR
	jsr	CHROUT
	rts
	.endproc

	;; Constant data (literals)
	.rodata
hello:	.asciiz	"reverse per c64"
prompt:	.asciiz	"entra una linia:  "
invert:	.asciiz	"cadena invertida: "
adeu:	.asciiz	"finalitzat."

	;; Work area (buffers and counter)
	.bss
numch:	.byte	0
buffin:	.res	64,$00		
bufout:	.res	64,$00
	
	.end	


