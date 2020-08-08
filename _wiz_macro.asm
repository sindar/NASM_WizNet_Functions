;--- ������� ������ WizNet � CPU-31C 0x0E0000-0x0EFFFF
;--- ����� ��������
%define RMSR 0x01A ; �������, �������� ������ ������ RX
%define TMSR 0x01B ; �������, �������� ������ ������ TX	
%define SHAR 0x0009 ; ������ ������� �� �����, �������� MAC-����� WizNet 0x0009 � 0x000E
%define SIPR 0x000F ; ������ ������� �� ������, �������� IP-����� WizNet 0x000F � 0x0012

;--- ������� ��������� �� ������� ������ TX � RX, � ����� ��� ������� ������ ������ �0
%define gS0_RX_BASE 0x6000 ; ������� ��������� �� ������ RX  
%define gS0_TX_BASE 0x4000 ; ������� ��������� �� ������ RX  
%define gS0_RX_MASK 0x07FF ; ����� ��� ������� ������ ������ RX
%define gS0_TX_MASK 0x07FF ; ����� ��� ������� ������ ������ TX

;--- ������� ��������� �� ������� ������ TX � RX, � ����� ��� ������� ������ ������ �3
%define gS3_RX_BASE 0x7800 ; ������� ��������� �� ������ RX  
%define gS3_TX_BASE 0x5800 ; ������� ��������� �� ������ RX  
%define gS3_RX_MASK 0x07FF ; ����� ��� ������� ������ ������ RX
%define gS3_TX_MASK 0x07FF ; ����� ��� ������� ������ ������ TX

;--- �������� ������ �0
%define S0_MR 0x400 ; ������� ������ ������
%define S0_CR 0x401 ; ������� ���������� �������
%define S0_IR 0x402 ; ������� ���������� ������
%define S0_SR 0x403 ; ������� ��������� ������
%define S0_SPORT 0x404 ; ������� ���������� ����� ������
%define S0_DHAR 0x406 ; ������ ������� �� ����� MAC-������ ���������� 0x0406�0x040B
%define S0_DIPR_OCT1 0x40C; ������� ip-������ ����������, ����� 1
%define S0_DIPR_OCT2 0x40D; ������� ip-������ ����������, ����� 2
%define S0_DIPR_OCT3 0x40E; ������� ip-������ ����������, ����� 3
%define S0_DIPR_OCT4 0x40F; ������� ip-������ ����������, ����� 4
%define S0_DPORT 0x410 ; ������� ����� ����������
%define S0_TX_FSR 0x420 ; �������, ���������� �������� ��������� ������ TX ������
%define S0_TX_RR 0x422 ; �������, ������������ ������������� �������� ������ TX ������(������ ��� ������)
%define S0_TX_WR 0x424 ; �������, �������� ��������� �� ������� ������ TX ��� �������� 
%define S0_RX_RSR 0x426 ; �������, ���������� ������ ���������� ������(������ ��� ������)
%define S0_RX_RD 0x428 ; ������� ��������� �� ���������� ������(����������� ���� ������� Receive) 

;--- �������� ������ �3
%define S3_MR 0x700 ; ������� ������ ������
%define S3_CR 0x701 ; ������� ���������� �������
%define S3_IR 0x702 ; ������� ���������� ������
%define S3_SR 0x703 ; ������� ��������� ������
%define S3_SPORT 0x704 ; ������� ���������� ����� ������
%define S3_DHAR 0x706 ; ������ ������� �� ����� MAC-������ ���������� 0x0706�0x070B
%define S3_DIPR_OCT1 0x70C; ������� ip-������ ����������, ����� 1
%define S3_DIPR_OCT2 0x70D; ������� ip-������ ����������, ����� 2
%define S3_DIPR_OCT3 0x70E; ������� ip-������ ����������, ����� 3
%define S3_DIPR_OCT4 0x70F; ������� ip-������ ����������, ����� 4
%define S3_DPORT 0x710 ; ������� ����� ����������
%define S3_TX_FSR 0x720 ; �������, ���������� �������� ��������� ������ TX ������
%define S3_TX_RR 0x722 ; �������, ������������ ������������� �������� ������ TX ������(������ ��� ������)
%define S3_TX_WR 0x724 ; �������, �������� ��������� �� ������� ������ TX ��� �������� 
%define S3_RX_RSR 0x726 ; �������, ���������� ������ ���������� ������(������ ��� ������)
%define S3_RX_RD 0x728 ; ������� ��������� �� ���������� ������(����������� ���� ������� Receive) 

;--- ������ ��������� �������
%define	UDP_MODE 0x02; ���������� ����� ���� UDP
%define MACRAW_MODE 0x04; ���������� ����� ���� MACRAW

;--- ������� �������� ���������� ��������
%define OPEN 0x01; ������� �������� ������
%define CLOSE 0x10; ������� �������� ������
%define SEND 0x20; ������� �������� �������
%define RECV 0x40; ������� ��������� �������

;--- ��������� �������� ��������� � �������� ��������� ������
%define	SOCK_UDP 0x22; ����� ���� UDP
%define SOCK_MACRAW 0x42; ����� ���� MACRAW
%define SOCK_CLOSED 0x00; ����� ������

;--- �������� �������� ��������/���������
;%define BUFFER_START 0xE000 ; ������� ������ TX
%define BUFFER_START 0x3C ; ������� ������ ������ ��� ��������
%define SEND_SIZE 0x30 ; ������ ������������ ������ SNTP
%define SEND_ARP_SIZE 0x30 ; ������� ������������ ������ ARP

;--- �������� �������� ������ ��� �������� ds
%define MB_SEG 0x1000 ; ������� ������, ��������� �� ModBusTCP
%define WIZNET_SEG 0xE000 ; ������� ������ WizNet

;--- ���������� �� ����������� ������
%define RECV_HEADER_PTR 0x3C ; ����������� ������ ���������(header) ���������� ������
%define PEER_IP_OCT1 0x3C ; ip-����������� 1-� �����
%define PEER_IP_OCT2 0x3E ; ip-����������� 2-� �����
%define PEER_IP_OCT3 0x40 ; ip-����������� 3-� �����
%define PEER_IP_OCT4 0x42 ; ip-����������� 4-� �����
%define PEER_PORT 0x44 ; ���� �����������
%define RECV_DATA_SIZE 0x46 ; ������ ���������� ������
%define RECV_DATA_PTR 0x48 ; ��������� �� ������ ���������� ������


