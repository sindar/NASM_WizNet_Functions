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
	; %local    send_size:word ; ������ ������������ ������
	; %local    get_start_address:word ; ��������� ����� ��� ����������� � ������ TX
	; %local    get_offset:word ; �������� � ������ �������� TX
	%include  "_wiz_macro.asm"
		
			; ; ---- ������� ���� 
			; push ds
			; push si
			; mov bx, MB_SEG ; ��������� ��������� �������� �� ������� ������ 0x1000
			; mov ds, bx
			; mov si, 0x6
			; mov [ds:si], ax
			; pop si
			; pop ds
			; ; ---- ������� ���� 
		
		; ���������� � ���� �������� � �������� �������� ���������
		push ds
		push si
		push bp
		push di
		
		; ��������� �������� �� ������� ������ WizNet
		mov ax, WIZNET_SEG ; ��������� ��������� �������� �� ������� ������ WizNet
		mov ds, ax
		
		mov al, [S3_SR] ; ������ �������� ��������� ������
		cmp al, SOCK_UDP ; ���� ��������� ������ �� SOCK_UDP - ����� �� ���������
		jne END_SEND 
		
		;================ ���������� ������� =====================
		; push ds
		
		; mov si, MB_SEG ; ��������� ��������� �������� �� ������� ������ 0x1000
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
		
		; mov si, 0xC8 ; - ������ �������� � ������� 100 ��� ��������
		; mov [ds:si], cx
		
		; pop ds
		;================ ���������� ������� =====================
		
	FREESIZE:
		mov ah, byte [S3_TX_FSR] ; ������ �������� ��������� ������ TX
		mov al, byte [S3_TX_FSR+1]
							
		cmp ax, SEND_SIZE   ; ���� �������� ��������� ������ ������ ������� ��� �������� - 
		jb FREESIZE ; �������� ������������ ������
		
		mov ah, 0x0 ; ��������� ����� ���������� - 123
		mov [S3_DPORT+1], ah
		mov al, 0x7B ; ��������� ����� ���������� - 123
		mov [S3_DPORT+1], al
		
		mov ax, 192 ; ���������� 1-�� ������ ip-������ 
		mov [S3_DIPR_OCT1], ax 
		
		mov ax, 168 ; ���������� 2-�� ������ ip-������
		mov [S3_DIPR_OCT2], ax 
		
		mov ax, 1  ; ���������� 3-�� ������ ip-������
		mov [S3_DIPR_OCT3], ax 
		
		mov ax, 168  ; ���������� 4-�� ������ ip-������
		mov [S3_DIPR_OCT4], ax 
			
		; /* calculate offset address */ 
		; get_offset = Sn_TX_WR & gSn_TX_MASK;
		; mov di, [S3_TX_WR] ; ������ �������� � ������ TX
		; and di, gS3_TX_MASK
		; mov [get_offset], di
		
		; ; /* calculate start address(physical address) */ 
		; ; get_start_address = gSn_TX_BASE + get_offset; 
		; mov bp, [get_offset]
		; add bp, gS3_TX_BASE ; ������ ������ � ������ TX
		; mov [get_start_address], bp
		
		; ; /* if overflow socket TX memory */ 
		; ; if ( (get_offset + send_size) > (gSn_TX_MASK + 1) ) 
		; ; - �������� ������������ ������ TX
		; mov ax, di
		; add ax, [send_size]
		; cmp ax, gS3_TX_MASK + 1
		; ja TX_OVERFLOW
		; jmp near NO_TX_OVERFLOW 

	; TX_OVERFLOW:	
			; ; ; /* copy upper_size bytes of source_addr to get_start_address */ 
			; ; ; upper_size = (gSn_TX_MASK + 1) � get_offset;
			; ; ; memcpy(source_addr, get_start_address, upper_size);
			; ; ; - ����������� ��������� ��������� ������ TX �� ������� ������� 
			; ; mov ax, gS3_TX_MASK + 1
			; ; sub ax, di
			; ; mov cx, 0
		; ; COPY_DATA_UPPER:
			; ; ; - ����������� ����� �� ������� ��� �������� � bl
			; ; mov si, BUFFER_START
			; ; add si, cx
			; ; mov bl, byte[ds:si]
			; ; ; - ������� �� bl � ������ TX
			; ; mov si, bp
			; ; add si, cx
			; ; mov byte[ds:si], bl
			; ; inc cx
			; ; cmp cx, ax
			; ; jnz COPY_DATA_UPPER
			 
			; ; ; /* update source_addr*/ 
			; ; ; source_addr += upper_size; 
			; ; ; - �������� ������ � �������� ������� ����������� ����� ������������ �������� � ������ TX
			; ; mov si, BUFFER_START
			; ; add si, ax
			; ; mov bx, si
			
			; ; ; /* copy left_size bytes of source_addr to gSn_TX_BASE */ 
			; ; ; left_size = send_size � upper_size; 
			; ; ; memcpy(source_addr, gSn_TX_BASE, left_size); 
			; ; ; - ����������� ���������� ������
			; ; sub dx, ax	
			; ; mov cx, 0
			; ; mov bp, gS3_TX_BASE
		; ; COPY_DATA_LEFT:
			; ; ; - ����������� ����� �� ������� ��� �������� � bl
			; ; mov si, bx
			; ; add si, cx
			; ; mov bl, byte[ds:si]
			; ; ; - ������� �� bl � ������ TX
			; ; mov di, bp
			; ; add di, cx
			; ; mov byte[ds:di], bl
			; ; inc cx
			; ; cmp cx, dx
			; ; jnz COPY_DATA_LEFT
		
	NO_TX_OVERFLOW:
	
	
		; -===================== ���� ������, ��� ���������� ������������!!!
		; get_offset = Sn_TX_WR & gSn_TX_MASK;
		mov dh, [S3_TX_WR] ; ������ �������� � ������ TX
		mov dl, [S3_TX_WR+1]
		and dx, gS3_TX_MASK
			
		; /* calculate start address(physical address) */ 
		; get_start_address = gSn_TX_BASE + get_offset; 
		mov di, dx
		add di, gS3_TX_BASE ; ������ ������ � ������ TX
		; -===================== ���� ������, ��� ���������� ������������!!!
		
			; /* copy send_size bytes of source_addr to get_start_address */ 
			; memcpy(source_addr, get_start_address, send_size);   
			mov bx, word 0x001b
			mov word[ds:di], bx
			mov cx, 2
			add di, 2
			mov ax, SEND_SIZE
		COPY_DATA:
			; - ����������� ����� �� ������ ��� �������� � bl
			; push ds
			; mov si, MB_SEG
			; mov ds, si
			; mov si, BUFFER_START
			; add si, cx
			; mov bl, [ds:si]
			; pop ds
			
			; - ������� �� bl � ������ TX			
			;mov byte[ds:di], bl
			mov word[ds:di], 0x0 ; ���� ������ ��
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
		 		
		 mov al, SEND ; ������� ������� ������		
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