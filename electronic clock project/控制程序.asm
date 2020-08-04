SET_INT MACRO X,Y  
    ;设置中断向量
    MOV AX,0
    MOV ES,AX ;将中断向量段地址设为0，那偏移地址和段地址就好用公式了
    MOV BX,4*X    ;BX=
    MOV ES:WORD PTR[BX],OFFSET Y;中断程序的偏移地址送入对应地方
    MOV ES:WORD PTR[BX+2],SEG Y ;中断程序送入段地址 
ENDM 


;用来处理显示
INT_PRO MACRO X,NUM,Y,Z 
    LOCAL AA
    XOR BX,BX
    MOV AX,BX
    MOV AL,X
    CMP AL,NUM  ;比较秒计数到60或24了吗？
    JNE AA
    INC Y   ;是，则分钟/小时加一
    MOV AL,0   ;复位秒
    MOV X,AL
AA: 
    MOV BL,10
    DIV BL
    MOV BL,AL
    MOV AL,TABLE[BX]       ;转换时/分/秒 的高位
    MOV Z,AL
    MOV BL,AH   ;转换得到对应的低位
    MOV AL,TABLE[BX]
    MOV Z+1,AL  
ENDM     



     

    
    



    

    

; multi-segment executable file template.

DATA segment
    ; add your data here!
    TABLE DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH;阴极显示
    
    HOUR DB 00H ;小时变量
    MINUTE DB 00H ;分钟变量
    SECOND DB 00H ;秒变量  
    DAY DB 00H;天变量        
    HR DB 0,0,40H ;用于存放显示的变量
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
    MOV SS,AX;堆栈段设置
    CLI;关中断
    
    
    SET_INT 80H,INT_0
    SET_INT 81H,INT_1
    SET_INT 82H,INT_2
    SET_INT 83H,INT_3
    SET_INT 84H,INT_4
    
    ;8259设置
    ;写ICW1  00010011B
    MOV AL,00010011B
    OUT 50H,AL ;送到偶地址
    ;写ICW2中断类型号高5位，这里设置中断类型号为80H和81H,IR0为中断
    MOV AL,10000000B
    OUT 52H,AL
    ;ICW3不用写
    ;写ICW4 00000001B，非特殊，非自动结束，非缓冲，8086工作方式
    MOV AL,00000001B
    OUT 52H,AL   
    
    ;8259操作命令字管理
    MOV AL,11100000B
    OUT 52H,AL;写OCW1字，开放IR0,IR1,IR2,IR3,IR4的中断
    
  
    
    
     
    ;8255初始化
    MOV AL,10000000B;方式字，设置A为方式0输出
                    ;输出，B口方式0输出。  
                    ;方式C输入
    OUT 4EH,AL  ;  写入8255   
    STI ;开中断  
    
    ;设置8253工作
    MOV AL,00010110B    ;时钟频率200HZ 设置8253工作方式3 产生方波
	OUT 46H,AL          ;  写入控制器
    MOV AL,72H               ;输入低8位计数值计数保证
	OUT 40H,AL               ;写入对应寄存器   


AGAIN1:  CALL DISPLAY;显示
    JMP AGAIN1
    NOP 
	   	
	   

INT_0 PROC
    CLI
    PUSH AX
    PUSH BX
     	    
    ;重置
    MOV SECOND,0
    MOV MINUTE,0
    MOV HOUR ,0
  
    
    INT_PRO SECOND,60,MINUTE,SD
    INT_PRO MINUTE,60,HOUR,ME
    INT_PRO HOUR,24,DAY,HR     
      
    MOV AL,00100000B 
    OUT 50H,AL;写OCW2字实现普通方式结束中断  
    POP BX
    POP AX 
    STI
    IRET   ;中断服务程序
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
    OUT 50H,AL;写OCW2字实现普通方式结束中断 
    
    POP BX
    POP AX 
    STI
    IRET   ;中断服务程序
INT_1 ENDP


INT_2 PROC
    CLI
    PUSH AX
    PUSH BX 	
    
    INC HOUR
      
    MOV AL,00100000B
    OUT 50H,AL;写OCW2字实现普通方式结束中断 
    
    POP BX
    POP AX 
    STI
    IRET   ;中断服务程序
INT_2 ENDP   



INT_3 PROC
    CLI
    PUSH AX
    PUSH BX 	
    
    INC MINUTE
      
    MOV AL,00100000B
    OUT 50H,AL;写OCW2字实现普通方式结束中断 
    
    POP BX
    POP AX 
    STI
    IRET   ;中断服务程序
INT_3 ENDP   


INT_4 PROC
    CLI
    PUSH AX
    PUSH BX 	
    
    INC SECOND
      
    MOV AL,00100000B
    OUT 50H,AL;写OCW2字实现普通方式结束中断 
    
    POP BX
    POP AX 
    STI
    IRET   ;中断服务程序
INT_4 ENDP 


 
    
    


;LED显示
DISPLAY PROC NEAR    
    
    LEA DI,HR ;得到
    
    
    
    ;片选第一个数码管
    MOV AL,01111111B
    OUT 4AH,AL      
   
     ;写入8255通道0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
    INC DI
    
    
    ;片选第2个数码管
    MOV AL,10111111B
    OUT 4AH,AL 
   
      ;写入8255通道0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
    INC DI
    
    
    ;片选第3个数码管
    MOV AL,11011111B
    OUT 4AH,AL 
      ;写入8255通道0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
    
    INC DI
    
    
    ;片选第4个数码管
    MOV AL,11101111B
    OUT 4AH,AL
      ;写入8255通道0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
 
    INC DI
    
    ;片选第5个数码管
    MOV AL,11110111B
    OUT 4AH,AL
      ;写入8255通道0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY

    INC DI  
    
    ;片选第6个数码管
    MOV AL,11111011B
    OUT 4AH,AL 
      ;写入8255通道0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY

    INC DI
    
    ;片选第7个数码管
    MOV AL,11111101B
    OUT 4AH,AL
      ;写入8255通道0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY
 
    INC DI
    
    ;片选第8个数码管
    MOV AL,11111110B
    OUT 4AH,AL
      ;写入8255通道0 
    MOV AL,[DI]     
    OUT 48H,AL  
    CALL DELAY

    
    
  
  
    RET 
DISPLAY ENDP

;延时子程序
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
