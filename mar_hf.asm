ORG 0H
LJMP Main
; F?program
Main:
MOV R7, #75H ;#0FEH
MOV A, R7
ANL A, #80H ; Megnézzük, hogy az MSB 1-e (negatív-e)
JNZ Negativ ; Ha negatív, akkor átváltás
JMP Vege
; Kettes komplemens átváltása
; Ha negatív, akkor minden bitet negálunk és hozzáadunk egyet az LSB-n
Negativ:
MOV A, R7
CPL A
INC A
MOV R6, A
Vege:
END
