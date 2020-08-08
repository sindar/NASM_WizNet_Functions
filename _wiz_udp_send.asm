CPU 186
BITS 16

;---------------------- Function header ----------------------------

	        db    'HEADER'
			db 1
			db 0

global  _wiz_udp_send

_wiz_udp_send:
	%push     mycontext        ; save the current context 
    %stacksize small           ; tell NASM to use bp 
	%arg      val1:word
	%assign %$localsize 0
	%local    send_size:word ; размер передаваемых данных
	%local    get_start_address:word ; начальный адрес для копирования в память TX
	%local    get_offset:word ; смещение в буфере отправик TX
	%include  "_wiz_macro.asm"
		
		; сохранение в стек сегмента и смещение основной программы
		push ds
		push si
		push bp
		push di
		
		; установка сегмента на область памяти WizNet
		mov ax, 0xE000 ; установка указателя сегмента на область памяти WizNet
		mov ds, ax
		
		mov al, [S3_SR] ; чтение регистра состояния сокета
		cmp al, SOCK_UDP ; если состояние сокета не SOCK_UDP - выход из процедуры
		jnz END_SEND 
		
		mov word [send_size], 0xA ; размер пересылаемых данных
		
		
			; ---- отладки ради 
			mov ax, [send_size]
			push ds
			push si
			mov bx, 0x1000 ; установка указателя сегмента на область памяти 0x1000
			mov ds, bx
			mov si, 0x6
			mov [ds:si], ax
			pop si
			pop ds
			; ---- отладки ради 
		
		; заполнение посылки
		mov ax, 0
		mov cx, 0
	FILL_DATA:
		mov si, BUFFER_START
		add si, cx
		mov [ds:si], ax
		inc cx
		cmp cx, [send_size]
		jnz FILL_DATA
		
	FREESIZE:
		mov ah, byte [S3_TX_FSR] ; чтение значения свободной памяти TX
		mov al, byte [S3_TX_FSR+1]
		
			; ---- отладки ради (текущее значение свободной памяти TX копируется в регистр 3)
			push ds
			push si
			mov bx, 0x1000 ; установка указателя сегмента на область памяти 0x1000
			mov ds, bx
			mov si, 0x8
			mov [ds:si], ax
			pop si
			pop ds
			; ---- отладки ради (текущее значение свободной памяти TX копируется в регистр 3)
		
		cmp ax, [send_size]   ; если значение свободной памяти меньше буффера для передачи - 
		jb FREESIZE ; ожидание освобождения памяти
		
		mov ah, 0x0 ; установка порта назначения - 123
		mov [S3_DPORT+1], ah
		mov al, 0x7B ; установка порта назначения - 123
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
		mov di, [S3_TX_WR] ; расчёт смещения в памяти TX
		and di, gS3_TX_MASK
		mov [get_offset], di
		
		; /* calculate start address(physical address) */ 
		; get_start_address = gSn_TX_BASE + get_offset; 
		mov bp, [get_offset]
		add bp, gS3_TX_BASE ; расчёт адреса в памяти TX
		mov [get_start_address], bp

			; ---- отладки ради (адрес указателя в памяти TX копируется в регистр 4)
			push ds
			push si
			mov bx, 0x1000 ; установка указателя сегмента на область памяти 0x1000
			mov ds, bx
			mov si, 0xA
			mov ax, [get_start_address]
			mov [ds:si], ax
			pop si
			pop ds
			; ---- отладки ради (адрес указателя в памяти TX копируется в регистр 4)
		
		
		; /* if overflow socket TX memory */ 
		; if ( (get_offset + send_size) > (gSn_TX_MASK + 1) ) 
		; - Проверка переполнения памяти TX
		mov ax, di
		add ax, [send_size]
		cmp ax, gS3_TX_MASK + 1
		ja TX_OVERFLOW
		jmp near NO_TX_OVERFLOW 

	TX_OVERFLOW:	
			; ; /* copy upper_size bytes of source_addr to get_start_address */ 
			; ; upper_size = (gSn_TX_MASK + 1) – get_offset;
			; ; memcpy(source_addr, get_start_address, upper_size);
			; ; - Копирование доступной свободной памяти TX до верхней границы 
			; mov ax, gS3_TX_MASK + 1
			; sub ax, di
			; mov cx, 0
		; COPY_DATA_UPPER:
			; ; - Копирование байта из буффера для отправки в bl
			; mov si, BUFFER_START
			; add si, cx
			; mov bl, byte[ds:si]
			; ; - Вставка из bl в память TX
			; mov si, bp
			; add si, cx
			; mov byte[ds:si], bl
			; inc cx
			; cmp cx, ax
			; jnz COPY_DATA_UPPER
			 
			; ; /* update source_addr*/ 
			; ; source_addr += upper_size; 
			; ; - указание адреса с которого начнётся копирование после циклического перехода в памяти TX
			; mov si, BUFFER_START
			; add si, ax
			; mov bx, si
			
			; ; /* copy left_size bytes of source_addr to gSn_TX_BASE */ 
			; ; left_size = send_size – upper_size; 
			; ; memcpy(source_addr, gSn_TX_BASE, left_size); 
			; ; - копирование оставшихся данных
			; sub dx, ax	
			; mov cx, 0
			; mov bp, gS3_TX_BASE
		; COPY_DATA_LEFT:
			; ; - Копирование байта из буффера для отправки в bl
			; mov si, bx
			; add si, cx
			; mov bl, byte[ds:si]
			; ; - Вставка из bl в память TX
			; mov di, bp
			; add di, cx
			; mov byte[ds:di], bl
			; inc cx
			; cmp cx, dx
			; jnz COPY_DATA_LEFT
		
	NO_TX_OVERFLOW:
			; /* copy send_size bytes of source_addr to get_start_address */ 
			; memcpy(source_addr, get_start_address, send_size);   
			mov cx, 0
			mov ax, [send_size]
			mov bp, [get_start_address]
			mov bx, BUFFER_START
			
				; ---- отладки ради 
				push ds
				push si
				mov dx, 0x1000 ; установка указателя сегмента на область памяти 0x1000
				mov ds, dx
				mov si, 0xC			
				mov [ds:si], ax
				mov si, 0xE
				mov [ds:si], bp
				mov si, 0x10
				mov [ds:si], bx
				mov si, 0x12
				mov [ds:si], cx
				pop si
				pop ds
				; ---- отладки ради 
				
		COPY_DATA:
			; - Копирование байта из буфера для отправки в bl
			mov si, bx
			adc si, cx
			mov bl, byte[ds:si]
			; - Вставка из bl в память TX
			mov di, bp
			add di, cx
			mov byte[ds:di], bl
			inc cx
			cmp cx, ax
			jb COPY_DATA
			
			mov bx, si
			
			; ---- отладки ради 
				push ds
				push si
				mov dx, 0x1000 ; установка указателя сегмента на область памяти 0x1000
				mov ds, dx
				mov si, 0x14			
				mov [ds:si], ax
				mov si, 0x16
				mov [ds:si], bp
				mov si, 0x18
				mov [ds:si], bx
				mov si, 0x1A
				mov [ds:si], cx
				pop si
				pop ds
				; ---- отладки ради 
			
		; /* increase Sn_TX_WR as length of send_size */ 
		; Sn_TX_WR += send_size; 
		; /* set SEND command */ 
		; Sn_CR = SEND;
		mov ax, [send_size]
		add [S3_TX_WR], ah
		add [S3_TX_WR+1], al
		
		mov al, SEND ; команда посылки пакета		
		mov [S3_CR], al 
		
	END_SEND:
		pop di
		pop bp
		pop si
		pop ds
		
        ret 
    %pop            