		.model small
		.stack

BUFSIZ  EQU 256

		.data

hello   db  'Reverse program - MSDOS',0dh,0ah,'$'
prompt  db  'Entra una linia:   ','$'
inver   db  0dh,0ah,'Linia invertida:   ','$'
adeu    db  0dh,0ah,'Finalitzat'
crlf    db  0dh,0ah,'$'
buffin  db  255
numch   db  0
bufchr  db  BUFSIZ dup(' ')
bufout  db  BUFSIZ dup(' ')
		
		.code
  
main    proc
		mov ax, seg hello       ; C…rrega segments de dades
		mov ds, ax
		mov es, ax

		lea dx, hello           ; Mostrar missatge inicial
		mov ah, 09h
		int 21h      

getlin: lea dx, prompt          ; Mostrar prompt
		mov ah, 09h
		int 21h

		lea dx, buffin          ; Llegir linia d'entrada
		mov ah, 0ch             ; Netejar buffer STDIN
		mov al, 0ah             ; Llegir amb buffer
		int 21h
		mov al, byte ptr [numch]; AL: Nombre de caracters
		cmp al, 0               ; Buffer buit?
		je  final               ; Si: acabar

		lea dx,inver
		mov ah,09h
		int 21h

		lea ax,bufchr           ; AX => Inici buffer entrada
		sub cx,cx               ; CX => Zero
		mov cl,byte ptr [numch] ; CX => Bytes a buffer
		add ax,cx               ; AX => Final buffer entrada+1
		dec ax                  ; AX => Final cadena entrada
		mov si,ax               ; SI => Final buffer entrada
		lea di,bufout           ; DI => Inici buffer sortida

theloop:
		std                     ; Sentit SI: Descendent
		lodsb                   ; Carregar byte a AL
		cld                     ; Sentit DI: Ascendent
		stosb                   ; Desar byte a buffer
		loop theloop            ; Saltar segons comptador CX
		mov cx,3                ; Apuntar a sequencia CR+LF+$ 
		lea si,crlf             ;
		rep movsb               ; I afegir-la al buffer

		lea dx, bufout          ; Emetre el buffer de sortida...
		mov ah, 09h
		int 21h
		
		lea dx,crlf             ; Emetre un altre salt de linia
		mov ah, 09h
		int 21h

		jmp getlin              ; Processar una altra linia


final:  lea dx, adeu
		mov ah, 09h
		int 21h

		mov ax, 4C00h
		int 21h

		ret
main    endp
	
		end main
