CPU 186
BITS 16

;---------------------- Function header ----------------------------

	        db    'HEADER'
			db 1
			db 0

global  _wiz_ntp_send

_wiz_ntp_send:
	%push     mycontext        ; save the current context 
    %stacksize small           ; tell NASM to use bp 
	%arg      val1:word
	; %assign %$localsize 0
	; %local    send_size:word ; размер передаваемых данных
	; %local    get_start_address:word ; начальный адрес дл€ копировани€ в пам€ть TX
	; %local    get_offset:word ; смещение в буфере отправик TX
	%include  "_wiz_macro.asm"
		
			; ; ---- отладки ради 
			; push ds
			; push si
			; mov bx, MB_SEG ; установка указател€ сегмента на область пам€ти 0x1000
			; mov ds, bx
			; mov si, 0x6
			; mov [ds:si], ax
			; pop si
			; pop ds
			; ; ---- отладки ради 
		
		; сохранение в стек сегмента и смещение основной программы
		push ds
		push si
		push bp
		push di
		
		; установка сегмента на область пам€ти WizNet
		mov ax, WIZNET_SEG ; установка указател€ сегмента на область пам€ти WizNet
		mov ds, ax
		
		mov al, [S3_SR] ; чтение регистра состо€ни€ сокета
		cmp al, SOCK_UDP ; если состо€ние сокета не SOCK_UDP - выход из процедуры
		jne END_SEND 
		
		;================ заполнение посылки =====================
		; push ds
		
		; mov si, MB_SEG ; установка указател€ сегмента на область пам€ти 0x1000
		; mov ds, si
		; mov si, BUFFER_START
		; mov bl, byte 0x1B
		; mov bh, byte 0x00
		; mov [ds:si], bx
		
		; mov ax, si
		; mov cx, ax
		; add ax, SEND_SIZE
		; add cx, 2
	; FILL_DATA:
		; mov si, cx
		; mov [ds:si], word 0x0
		; add cx, 2
		; cmp cx, ax
		; jb FILL_DATA
		
		; mov si, 0xC8 ; - запись значени€ в регистр 100 дл€ контрол€
		; mov [ds:si], cx
		
		; pop ds
		;================ заполнение посылки =====================
		
	FREESIZE:
		mov ah, byte [S3_TX_FSR] ; чтение значени€ свободной пам€ти TX
		mov al, byte [S3_TX_FSR+1]
							
		cmp ax, SEND_SIZE   ; если значение свободной пам€ти меньше буффера дл€ передачи - 
		jb FREESIZE ; ожидание освобождени€ пам€ти
		
		mov ah, 0x0 ; установка порта назначени€ - 123
		mov [S3_DPORT+1], ah
		mov al, 0x7B ; установка порта назначени€ - 123
		mov [S3_DPORT+1], al
		
		mov ax, 192 ; назначение 1-го октета ip-адреса 
		mov [S3_DIPR_OCT1], ax 
		
		mov ax, 168 ; назначение 2-го октета ip-адреса
		mov [S3_DIPR_OCT2], ax 
		
		mov ax, 1  ; назначение 3-го октета ip-адреса
		mov [S3_DIPR_OCT3], ax 
		
		mov ax, 168  ; назначение 4-го октета ip-адреса
		mov [S3_DIPR_OCT4], ax 
			
		; /* calculate offset address */ 
		; get_offset = Sn_TX_WR & gSn_TX_MASK;
		; mov di, [S3_TX_WR] ; расчЄт смещени€ в пам€ти TX
		; and di, gS3_TX_MASK
		; mov [get_offset], di
		
		; ; /* calculate start address(physical address) */ 
		; ; get_start_address = gSn_TX_BASE + get_offset; 
		; mov bp, [get_offset]
		; add bp, gS3_TX_BASE ; расчЄт адреса в пам€ти TX
		; mov [get_start_address], bp
		
		; ; /* if overflow socket TX memory */ 
		; ; if ( (get_offset + send_size) > (gSn_TX_MASK + 1) ) 
		; ; - ѕроверка переполнени€ пам€ти TX
		; mov ax, di
		; add ax, [send_size]
		; cmp ax, gS3_TX_MASK + 1
		; ja TX_OVERFLOW
		; jmp near NO_TX_OVERFLOW 

	; TX_OVERFLOW:	
			; ; ; /* copy upper_size bytes of source_addr to get_start_address */ 
			; ; ; upper_size = (gSn_TX_MASK + 1) Ц get_offset;
			; ; ; memcpy(source_addr, get_start_address, upper_size);
			; ; ; -  опирование доступной свободной пам€ти TX до верхней границы 
			; ; mov ax, gS3_TX_MASK + 1
			; ; sub ax, di
			; ; mov cx, 0
		; ; COPY_DATA_UPPER:
			; ; ; -  опирование байта из буффера дл€ отправки в bl
			; ; mov si, BUFFER_START
			; ; add si, cx
			; ; mov bl, byte[ds:si]
			; ; ; - ¬ставка из bl в пам€ть TX
			; ; mov si, bp
			; ; add si, cx
			; ; mov byte[ds:si], bl
			; ; inc cx
			; ; cmp cx, ax
			; ; jnz COPY_DATA_UPPER
			 
			; ; ; /* update source_addr*/ 
			; ; ; source_addr += upper_size; 
			; ; ; - указание адреса с которого начнЄтс€ копирование после циклического перехода в пам€ти TX
			; ; mov si, BUFFER_START
			; ; add si, ax
			; ; mov bx, si
			
			; ; ; /* copy left_size bytes of source_addr to gSn_TX_BASE */ 
			; ; ; left_size = send_size Ц upper_size; 
			; ; ; memcpy(source_addr, gSn_TX_BASE, left_size); 
			; ; ; - копирование оставшихс€ данных
			; ; sub dx, ax	
			; ; mov cx, 0
			; ; mov bp, gS3_TX_BASE
		; ; COPY_DATA_LEFT:
			; ; ; -  опирование байта из буффера дл€ отправки в bl
			; ; mov si, bx
			; ; add si, cx
			; ; mov bl, byte[ds:si]
			; ; ; - ¬ставка из bl в пам€ть TX
			; ; mov di, bp
			; ; add di, cx
			; ; mov byte[ds:di], bl
			; ; inc cx
			; ; cmp cx, dx
			; ; jnz COPY_DATA_LEFT
		
	NO_TX_OVERFLOW:
	
	
		; -===================== ѕока считаю, что невозможно переполнение!!!
		; get_offset = Sn_TX_WR & gSn_TX_MASK;
		mov dh, [S3_TX_WR] ; расчЄт смещени€ в пам€ти TX
		mov dl, [S3_TX_WR+1]
		and dx, gS3_TX_MASK
			
		; /* calculate start address(physical address) */ 
		; get_start_address = gSn_TX_BASE + get_offset; 
		mov di, dx
		add di, gS3_TX_BASE ; расчЄт адреса в пам€ти TX
		; -===================== ѕока считаю, что невозможно переполнение!!!
		
			; /* copy send_size bytes of source_addr to get_start_address */ 
			; memcpy(source_addr, get_start_address, send_size);   
			mov bx, word 0x001b
			mov word[ds:di], bx
			mov cx, 2
			add di, 2
			mov ax, SEND_SIZE
		COPY_DATA:
			; -  опирование байта из буфера дл€ отправки в bl
			; push ds
			; mov si, MB_SEG
			; mov ds, si
			; mov si, BUFFER_START
			; add si, cx
			; mov bl, [ds:si]
			; pop ds
			
			; - ¬ставка из bl в пам€ть TX			
			;mov byte[ds:di], bl
			mov word[ds:di], 0x0 ; пока нул€ми всЄ
			add cx, 2
			add di, 2
			cmp cx, ax
			jb COPY_DATA		
				
		; ; /* increase Sn_TX_WR as length of send_size */ 
		; ; Sn_TX_WR += send_size; 
		; ; /* set SEND command */ 
		; ; Sn_CR = SEND;
		 mov ax, SEND_SIZE
		 add [S3_TX_WR], ah
		 add [S3_TX_WR+1], al
		 mov ah, [S3_TX_WR]
		 mov al, [S3_TX_WR+1]
		 		
		 mov al, SEND ; команда посылки пакета		
		 mov [S3_CR], al 
	
	WAIT_END_SEND:
		 cmp byte[S3_CR], 0x00
		 jne WAIT_END_SEND
		
	END_SEND:
		pop di
		pop bp
		pop si
		pop ds
		
        ret 
    %pop            