CODE SEGMENT
ASSUME CS:CODE
START:	MOV AL,00010001B    ;����8253������ʽ
	OUT 46H,AL               ;
	MOV AL,05H               ;�����8λ����ֵ
	OUT 40H,AL               ;д���Ӧ�Ĵ���
	JMP $
CODE ENDS
END START

















