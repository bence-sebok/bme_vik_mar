ORG 0H
LJMP Main
; F?program
Main:
MOV R7, #75H ;#0FEH
MOV A, R7
ANL A, #80H ; Megn�zz�k, hogy az MSB 1-e (negat�v-e)
JNZ Negativ ; Ha negat�v, akkor �tv�lt�s
JMP Vege
; Kettes komplemens �tv�lt�sa
; Ha negat�v, akkor minden bitet neg�lunk �s hozz�adunk egyet az LSB-n
Negativ:
MOV A, R7
CPL A
INC A
MOV R6, A
Vege:
END
