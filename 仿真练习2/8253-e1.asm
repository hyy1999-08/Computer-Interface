CODE SEGMENT
ASSUME CS:CODE
START:	MOV AL,00010001B    ;设置8253工作方式
	OUT 46H,AL               ;
	MOV AL,05H               ;输入低8位计数值
	OUT 40H,AL               ;写入对应寄存器
	JMP $
CODE ENDS
END START

















