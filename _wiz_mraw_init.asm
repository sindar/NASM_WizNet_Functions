CPU 186
BITS 16

;---------------------- Function header ----------------------------

	        db    'HEADER'
			db 0
			db 0

global  _wiz_mraw_init

_wiz_mraw_init:
	%push     mycontext        ; save the current context 
    %stacksize small           ; tell NASM to use bp 
	%include  "_wiz_macro.asm"
	
		; сохранение в стек сегмента и смещение основной программы
		push ds
		push si
		
		; установка сегмента на область памяти WizNet
		mov ax, 0xE000 ; установка указателя сегмента на область памяти WizNet
		mov ds, ax
		
		mov al, [S0_SR] ; чтение регистра состояния сокета
		cmp al, SOCK_MACRAW ; если состояние сокета не SOCK_MACRAW - инициализация
		jne CLOSE_SOCK
		je END_INIT ; иначе выход из процедуры
	
	CLOSE_SOCK:
		mov al, CLOSE ; команда закрытия сокета
		mov [S0_CR], al 
	
	START_INIT:	 
		; --------- установка размера памяти RX и TX
		; mov al, 0x55
		; mov [RMSR], al
		; mov [TMSR], al	
		; --------- установка памяти RX, TX и указателей на них
	
		mov ax, MACRAW_MODE ; установка режима сокета - UDP
		mov [S0_MR], ax 
		
		mov ax, 0x5D0 ; установка исходящего порта 53253
		mov [S0_SPORT], ax 
			
		mov al, OPEN ; команда открытия сокета		
		mov [S0_CR], al 
		
		mov al, [S0_SR]; чтение регистра состояния сокета
		cmp al, SOCK_MACRAW ; если состояние сокета не SOCK_MACRAW, команда закрыть имеющийся и затем инициализация
		jne CLOSE_SOCK
		je END_INIT
		
	END_INIT:
		; ---- отладки ради (текущее состояние сокета копируется в регистр 2)
			push ds
			push si
			
			mov bx, 0x1000 ; установка указателя сегмента на область памяти 0x1000
			mov ds, bx
			mov si, 0x4

			mov [ds:si], al
			
			pop si
			pop ds
		; ---- отладки ради (текущее состояние сокета копируется в регистр 2)
	
		pop si
		pop ds
		
        ret 
    %pop            