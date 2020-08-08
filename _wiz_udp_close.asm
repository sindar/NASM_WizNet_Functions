CPU 186
BITS 16

;---------------------- Function header ----------------------------

	        db    'HEADER'
			db 0
			db 0

global  _wiz_udp_close

_wiz_udp_close:
	%push     mycontext        ; save the current context 
    %stacksize small           ; tell NASM to use bp 
	%include  "_wiz_macro.asm"
	%arg      val1:word
	
		; ��������� �������� �� ������� ������ WizNet
		mov ax, WIZNET_SEG ; ��������� ��������� �������� �� ������� ������ WizNet
		mov ds, ax
		
		mov al, [S3_SR] ; ������ �������� ��������� ������
		cmp al, SOCK_CLOSED ; ���� ����� �� ������ - ��������
		je END_PROC
		
	CLOSE_SOCK:
		mov al, CLOSE ; ������� �������� ������
		mov [S3_CR], al 
	END_PROC:
		
        ret 
    %pop            