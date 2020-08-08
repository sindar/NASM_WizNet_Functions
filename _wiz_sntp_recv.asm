CPU 186
BITS 16

;---------------------- Function header ----------------------------

	        db    'HEADER'
			db 1
			db 0

global  _wiz_ntp_recv

_wiz_ntp_recv:
	%push     mycontext        ; save the current context 
    %stacksize small           ; tell NASM to use bp 
	%arg      val1:word
	; %assign %$localsize 0
	; %local    send_size:word ; размер передаваемых данных
	; %local    get_start_address:word ; начальный адрес для копирования в память TX
	; %local    get_offset:word ; смещение в буфере отправик TX
	%include  "_wiz_macro.asm"
		
			; ; ---- пример куска для отладки
			; push ds
			; push si
			; mov bx, MB_SEG ; установка указателя сегмента на область памяти 0x1000
			; mov ds, bx
			; mov si, 0x6
			; mov [ds:si], ax
			; pop si
			; pop ds
			; ; ---- пример куска для отладки
		
		; сохранение в стек сегмента и смещение основной программы
		push ds
		push si
		push bp
		push di
		
		; установка сегмента на область памяти WizNet
		mov ax, WIZNET_SEG ; установка указателя сегмента на область памяти WizNet
		mov ds, ax
		
		mov al, [S3_SR] ; чтение регистра состояния сокета
		mov ah, 0
		
			; ---- пример куска для отладки
			push ds
			push si
			mov bx, MB_SEG ; установка указателя сегмента на область памяти 0x1000
			mov ds, bx
			mov si, 0x6
			mov [ds:si], ax
			pop si
			pop ds
			; ---- пример куска для отладки
		
		cmp al, SOCK_UDP ; если состояние сокета не SOCK_UDP - выход из процедуры
		jne END_RECEIVE
		
		; 1-й способ(через значение регистра S3_RX_RSR)
		; mov ah, [S3_RX_RSR]
		; mov al, [S3_RX_RSR+1]
		; cmp ax, 0x0000
		; je END_RECEIVE
		
		mov al, RECV ; команда RECV
		mov [S3_CR], al 
		
		; 2-й способ(через прерывание S3_IR)
		mov al, [S3_IR]
		and al, 0x4
		cmp al, 0x4
		jne END_RECEIVE
		
		; ---- пример куска для отладки
			push ds
			push si
			mov bx, MB_SEG ; установка указателя сегмента на область памяти 0x1000
			mov ds, bx
			mov si, 0x8
			mov [ds:si], ax
			pop si
			pop ds
			; ---- пример куска для отладки
		
	START_RECEIVE:
		; /* first, get the received size */ 
		; get_size = Sn_RX_RSR; 
		; установка сегмента на область памяти WizNet
		mov ax, WIZNET_SEG ; установка указателя сегмента на область памяти WizNet
		mov ds, ax
		
		mov al, [S3_RX_RSR]
		mov ah, [S3_RX_RSR+1]
				
		; /* calculate offset address */ 
		; get_offset = Sn_RX_RD & gSn_RX_MASK;
		mov si, [S3_RX_RD]
		mov dx, si
		
		and si, gS3_RX_MASK
		mov dx, si
		
		; /* calculate start address(physical address) */ 		
		; get_start_address = gSn_RX_BASE + get_offset; 
		add si, gS3_RX_BASE
		mov dx, si
		
		;=== копирование содержимого посылки(8 байт заголовка, 48 байт данных) в оперативную память
		; /* save remote peer information & received data size */ 
		; peer_ip = header[0 to 3]; 
		; peer_port = header[4 to 5]; 
		; get_size = header[6 to 7]; 
		mov cx, 0
	COPY_DATA:
		mov bl, byte[ds:si]
		
		; - копирование в SRAM
		push ds
		mov di, MB_SEG
		mov ds, di
		mov di, RECV_HEADER_PTR
		add di, cx
		mov [ds:di], bl
		pop ds
		; - копирование в SRAM
		
		inc cx
		inc si
		cmp cx, 56
		jne COPY_DATA
		;=== копирование содержимого посылки(8 байт заголовка, 48 байт данных) в оперативную память
		
		; /* increase Sn_RX_RD as length of get_size+header_size */ 
		; Sn_RX_RD = Sn_RX_RD + get_size + header_size; 
		;add [S3_RX_RD], ax
		; /* set RECV command */ 
		; Sn_CR = RECV; 
		;mov al, RECV ; команда RECV
		;mov [S3_CR], al 
		
	END_RECEIVE:
		;mov al, CLOSE ; команда закрытия сокета
		;mov [S3_CR], al 
		
		pop di
		pop bp
		pop si
		pop ds
		
        ret 
    %pop            