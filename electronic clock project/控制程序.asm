SET_INT MACRO X,Y  
    ;�����ж�����
    MOV AX,0
    MOV ES,AX ;���ж������ε�ַ��Ϊ0����ƫ�Ƶ�ַ�Ͷε�ַ�ͺ��ù�ʽ��
    MOV BX,4*X    ;BX=
    MOV ES:WORD PTR[BX],OFFSET Y;�жϳ����ƫ�Ƶ�ַ�����Ӧ�ط�
    MOV ES:WORD PTR[BX+2],SEG Y ;�жϳ�������ε�ַ 
ENDM 


;����������ʾ
INT_PRO MACRO X,NUM,Y,Z 
    LOCAL AA
    XOR BX,BX
    MOV AX,BX
    MOV AL,X
    CMP AL,NUM  ;�Ƚ��������60��24����
    JNE AA
    INC Y   ;�ǣ������/Сʱ��һ
    MOV AL,0   ;��λ��
    MOV X,AL
AA: 
    MOV BL,10
    DIV BL
    MOV BL,AL
    MOV AL,TABLE[BX]       ;ת��ʱ/��/�� �ĸ�λ
    MOV Z,AL
    MOV BL,AH   ;ת���õ���Ӧ�ĵ�λ
    MOV AL,TABLE[BX]
    MOV Z+1,AL  
ENDM     



     

    
    



    

    

; multi-segment executable file template.

DATA segment
    ; add your data here!
    TABLE DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH;������ʾ
    
    HOUR DB 00H ;Сʱ����
    MINUTE DB 00H ;���ӱ���
    SECOND DB 00H ;�����  
    DAY DB 00H;�����        
    HR DB 0,0,40H ;���ڴ����ʾ�ı���
    ME DB 0,0,40H
    SD DB 0,0    
DATA ends

STACK segment PARA STACK 'STACK'
    dw   1024  dup(0)
STACK ends

CODE segment  
    ASSUME CS:CODE,DS:DATA
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    MOV AX,STACK
    MOV SS,AX;��ջ������
    CLI;���ж�
    
    
    SET_INT 80H,INT_0
    SET_INT 81H,INT_1
    SET_INT 82H,INT_2
    SET_INT 83H,INT_3
    SET_INT 84H,INT_4
    
    ;8259����
    ;дICW1  00010011B
    MOV AL,00010011B
    OUT 50H,AL ;�͵�ż��ַ
    ;дICW2�ж����ͺŸ�5λ�����������ж����ͺ�Ϊ80H��81H,IR0Ϊ�ж�
    MOV AL,10000000B
    OUT 52H,AL
    ;ICW3����д
    ;дICW4 00000001B�������⣬���Զ��������ǻ��壬8086������ʽ
    MOV AL,00000001B
    OUT 52H,AL   
    
    ;8259���������ֹ���
    MOV AL,11100000B
    OUT 52H,AL;дOCW1�֣�����IR0,IR1,IR2,IR3,IR4���ж�
    
  
    
    
     
    ;8255��ʼ��
    MOV AL,10000000B;��ʽ�֣�����AΪ��ʽ0���
                    ;�����B�ڷ�ʽ0�����  
                    ;��ʽC����
    OUT 4EH,AL  ;  д��8255   
    STI ;���ж�  
    
    ;����8253����
    MOV AL,00010110B    ;ʱ��Ƶ��200HZ ����8253������ʽ3 ��������
	OUT 46H,AL          ;  д�������
    MOV AL,72H               ;�����8λ����ֵ������֤
	OUT 40H,AL               ;д���Ӧ�Ĵ���   


AGAIN1:  CALL DISPLAY;��ʾ
    JMP AGAIN1
    NOP 
	   	
	   

INT_0 PROC
    CLI
    PUSH AX
    PUSH BX
     	    
    ;����
    MOV SECOND,0
    MOV MINUTE,0
    MOV HOUR ,0
  
    
    INT_PRO SECOND,60,MINUTE,SD
    INT_PRO MINUTE,60,HOUR,ME
    INT_PRO HOUR,24,DAY,HR     
      
    MOV AL,00100000B 
    OUT 50H,AL;дOCW2��ʵ����ͨ��ʽ�����ж�  
    POP BX
    POP AX 
    STI
    IRET   ;�жϷ������
INT_0 ENDP 

INT_1 PROC
    CLI
    PUSH AX
    PUSH BX 	
    INC SECOND  
    INT_PRO SECOND,60,MINUTE,SD
    INT_PRO MINUTE,60,HOUR,ME
    INT_PRO HOUR,24,DAY,HR  
      
    MOV AL,00100000B
    OUT 50H,AL;дOCW2��ʵ����ͨ��ʽ�����ж� 
    
    POP BX
    POP AX 
    STI
    IRET   ;�жϷ������
INT_1 ENDP


INT_2 PROC
    CLI
    PUSH AX
    PUSH BX 	
    
    INC HOUR
      
    MOV AL,00100000B
    OUT 50H,AL;дOCW2��ʵ����ͨ��ʽ�����ж� 
    
    POP BX
    POP AX 
    STI
    IRET   ;�жϷ������
INT_2 ENDP   



INT_3 PROC
    CLI
    PUSH AX
    PUSH BX 	
    
    INC MINUTE
      
    MOV AL,00100000B
    OUT 50H,AL;дOCW2��ʵ����ͨ��ʽ�����ж� 
    
    POP BX
    POP AX 
    STI
    IRET   ;�жϷ������
INT_3 ENDP   


INT_4 PROC
    CLI
    PUSH AX
    PUSH BX 	
    
    INC SECOND
      
    MOV AL,00100000B
    OUT 50H,AL;дOCW2��ʵ����ͨ��ʽ�����ж� 
    
    POP BX
    POP AX 
    STI
    IRET   ;�жϷ������
INT_4 ENDP 


 
    
    


;LED��ʾ
DISPLAY PROC NEAR    
    
    LEA DI,HR ;�õ�
    
    
    
    ;Ƭѡ��һ�������
    MOV AL,01111111B
    OUT 4AH,AL      
   
     ;д��8255ͨ��0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
    INC DI
    
    
    ;Ƭѡ��2�������
    MOV AL,10111111B
    OUT 4AH,AL 
   
      ;д��8255ͨ��0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
    INC DI
    
    
    ;Ƭѡ��3�������
    MOV AL,11011111B
    OUT 4AH,AL 
      ;д��8255ͨ��0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
    
    INC DI
    
    
    ;Ƭѡ��4�������
    MOV AL,11101111B
    OUT 4AH,AL
      ;д��8255ͨ��0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
 
    INC DI
    
    ;Ƭѡ��5�������
    MOV AL,11110111B
    OUT 4AH,AL
      ;д��8255ͨ��0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY

    INC DI  
    
    ;Ƭѡ��6�������
    MOV AL,11111011B
    OUT 4AH,AL 
      ;д��8255ͨ��0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY

    INC DI
    
    ;Ƭѡ��7�������
    MOV AL,11111101B
    OUT 4AH,AL
      ;д��8255ͨ��0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
 
    INC DI
    
    ;Ƭѡ��8�������
    MOV AL,11111110B
    OUT 4AH,AL
      ;д��8255ͨ��0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY

    
    
  
  
    RET 
DISPLAY ENDP

;��ʱ�ӳ���
DELAY PROC NEAR 
    PUSH CX
    MOV CX,80
AGAIN3:LOOP AGAIN3
    POP CX 
    RET
DELAY ENDP    	     	
    ; add your code here    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends
end start ; set entry point and stop the assembler.
