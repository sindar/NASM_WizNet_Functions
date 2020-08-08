CPU 186
BITS 16

;---------------------- Function header ----------------------------

	        db    'HEADER'
			db 1
			db 0

global  _wiz_udp_init

_wiz_udp_init:
	%push     mycontext        ; save the current context 
    %stacksize small           ; tell NASM to use bp 
	%arg      val1:word
	%include  "_wiz_macro.asm"
	
		; ���������� � ���� �������� � �������� �������� ���������
		push ds
		push si
		
		; ��������� �������� �� ������� ������ WizNet
		mov ax, 0xE000 ; ��������� ��������� �������� �� ������� ������ WizNet
		mov ds, ax
		
		mov al, [S3_SR] ; ������ �������� ��������� ������
		cmp al, SOCK_UDP ; ���� ��������� ������ �� SOCK_UDP - �������������
		jne CLOSE_SOCK
		je END_INIT ; ����� ����� �� ���������
	
	CLOSE_SOCK:
		mov al, CLOSE ; ������� �������� ������
		mov [S3_CR], al 
	
	START_INIT:	 
		; --------- ��������� ������� ������ RX � TX
		; mov al, 0x55
		; mov [RMSR], al
		; mov [TMSR], al	
		; --------- ��������� ������ RX, TX � ���������� �� ���
	
		mov ax, 0x2 ; ��������� ������ ������ - UDP
		mov [S3_MR], ax 
		
		mov ax, 0x5D0 ; ��������� ���������� ����� 53253
		mov [S3_SPORT], ax 
			
		mov al, OPEN ; ������� �������� ������		
		mov [S3_CR], al 
		
		mov al, [S3_SR]; ������ �������� ��������� ������
		cmp al, SOCK_UDP ; ���� ��������� ������ �� SOCK_UDP, ������� ������� ��������� � ����� �������������
		jne CLOSE_SOCK
		je END_INIT
		
	END_INIT:
		; ---- ������� ���� (������� ��������� ������ ���������� � ������� 2)
			push ds
			push si
			
			mov bx, 0x1000 ; ��������� ��������� �������� �� ������� ������ 0x1000
			mov ds, bx
			mov si, 0x4

			mov [ds:si], al
			
			pop si
			pop ds
		; ---- ������� ���� (������� ��������� ������ ���������� � ������� 2)
	
		pop si
		pop ds
		
        ret 
    %pop            