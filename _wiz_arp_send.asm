CPU 186
BITS 16

;---------------------- Function header ----------------------------

	        db    'HEADER'
			db 0
			db 0

global  _wiz_arp_send

_wiz_arp_send:
	%push     mycontext        ; save the current context 
    %stacksize small           ; tell NASM to use bp 
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
		
		mov al, [S0_SR] ; чтение регистра состо€ни€ сокета
		cmp al, SOCK_MACRAW ; если состо€ние сокета не SOCK_UDP - выход из процедуры
		jne END_SEND 
		
	FREESIZE:
		mov ah, byte [S3_TX_FSR] ; чтение значени€ свободной пам€ти TX
		mov al, byte [S3_TX_FSR+1]
							
		cmp ax, SEND_ARP_SIZE   ; если значение свободной пам€ти меньше буффера дл€ передачи - 
		jb FREESIZE ; ожидание освобождени€ пам€ти
		
		; назначение MAC-адреса получател€(в данном случае - широковещательный)
		mov al, 0xFF 
		mov [S0_DHAR], al 	
		mov [S0_DHAR+1], al
		mov [S0_DHAR+2], al
		mov [S0_DHAR+3], al
		mov [S0_DHAR+4], al
		mov [S0_DHAR+5], al
		 
		; -===================== ѕока считаю, что невозможно переполнение!!!
		; get_offset = Sn_TX_WR & gSn_TX_MASK;
		mov dh, [S0_TX_WR] ; расчЄт смещени€ в пам€ти TX
		mov dl, [S0_TX_WR+1]
		and dx, gS0_TX_MASK
			
		; /* calculate start address(physical address) */ 
		; get_start_address = gSn_TX_BASE + get_offset; 
		mov di, dx
		add di, gS0_TX_BASE ; расчЄт адреса в пам€ти TX
		; -===================== ѕока считаю, что невозможно переполнение!!!
			
		; заполнение MAC-адреса получател€
		mov bx, word 0xFFFF
		mov word[ds:di], bx 
		mov word[ds:di+2], bx
		mov word[ds:di+4], bx

		; заполнение MAC-адреса отправител€
		mov bx, word[SHAR]
		mov word[ds:di+6], bx 
		mov bx, word[SHAR+2]
		mov word[ds:di+8], bx 
		mov bx, word[SHAR+4]
		mov word[ds:di+10], bx 
				
		; указание типа Ethernet ARP(0x0806)
		mov bl, 0x08
		mov byte[ds:di+12], bl
		mov bl, 0x06
		mov byte[ds:di+13], bl
		
		; =============================================‘ормирование ARP-посылки, начало =========================================
		mov bx, 0x0100 ; ѕоле HTYPE(Hardware Type), код Ethernet
		mov word[ds:di+14], bx
		
		mov bx, 0x0008 ; ѕоле PTYPE(Protocol Type), код IPv4
		mov word[ds:di+16], bx
		
		mov bl, 0x06 ; ѕоле HLEN(Hardware Length), длина MAC-адреса = 6 байт
		mov byte[ds:di+18], bl
		
		mov bl, 0x04 ; ѕоле PLEN(Protocol Length), длина IP-адреса = 4 байтa
		mov byte[ds:di+19], bl
		
		mov bx, 0x0100 ; ѕоле OPER(Operation), код операции = 1(запрос)
		mov word[ds:di+20], bx
		
		;ARP-оповещение (ARP Announcement) Ч это пакет (обычно ARP запрос [3]), 
		;содержащий корректную SHA и SPA хоста-отправител€, с TPA, равной SPA. 
		;Ёто не разрешающий запрос, а запрос на обновление ARP-кэша других хостов, получающих пакет.
		
		mov bl, byte[SHAR] ; «аполнение пол€ Sender hardware address (SHA)
		mov byte[ds:di+22], bl 
		mov bl, byte[SHAR+1]
		mov byte[ds:di+23], bl 
		mov bl, byte[SHAR+2]
		mov byte[ds:di+24], bl 
		mov bl, byte[SHAR+3]
		mov byte[ds:di+25], bl 
		mov bl, byte[SHAR+4]
		mov byte[ds:di+26], bl 
		mov bl, byte[SHAR+5]
		mov byte[ds:di+27], bl 
		
		mov bl, byte[SIPR] ; «аполнение пол€ Sender protocol address (SPA)
		mov byte[ds:di+28], bl 
		mov bl, byte[SIPR+1] 
		mov byte[ds:di+29], bl
		mov bl, byte[SIPR+2] 
		mov byte[ds:di+30], bl
		mov bl, byte[SIPR+3] 
		mov byte[ds:di+31], bl
		
		mov bl, byte 0x00 ; «аполнение пол€  Target hardware address (THA)
		mov byte[ds:di+32], bl
		mov byte[ds:di+33], bl
		mov byte[ds:di+34], bl
		mov byte[ds:di+35], bl
		mov byte[ds:di+36], bl
		mov byte[ds:di+37], bl
		
		mov bl, byte[SIPR] ; «аполнение пол€ Target protocol address (TPA) значением равным SPA дл€ оповещени€ о своЄм MAC-адресе
		mov byte[ds:di+38], bl 
		mov bl, byte[SIPR+1] 
		mov byte[ds:di+39], bl
		mov bl, byte[SIPR+2] 
		mov byte[ds:di+40], bl
		mov bl, byte[SIPR+3] 
		mov byte[ds:di+41], bl
		; =============================================‘ормирование ARP-посылки, окончание =========================================
		
		; ; /* increase Sn_TX_WR as length of send_size */ 
		; ; Sn_TX_WR += send_size; 
		; ; /* set SEND command */ 
		; ; Sn_CR = SEND;
		 mov ax, SEND_ARP_SIZE
		 add [S0_TX_WR], ah
		 add [S0_TX_WR+1], al
		 mov ah, [S0_TX_WR]
		 mov al, [S0_TX_WR+1]
		 		
		 mov al, SEND ; команда посылки пакета		
		 mov [S0_CR], al 
	
	WAIT_END_SEND:
		 cmp byte[S0_CR], 0x00
		 jne WAIT_END_SEND
		
	END_SEND:
		pop di
		pop bp
		pop si
		pop ds
		
        ret 
    %pop            