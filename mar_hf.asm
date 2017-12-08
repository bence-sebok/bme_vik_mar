; R0: osztó
; R2: osztandó high byte
; R1: osztandó low byte
; R7: 5. digit
; R6: 4. digit
; R5: 3. digit
; R4: 2. digit
; R3: 1. digit
; B: maradék
; ACC: hányados alsó byte
; R3: hányados fels? byte

ORG 0
CALL Reset ; regiszterek nullázása
MOV R0, #0AH ; osztó: 10
MOV R2, #0BAH ; high byte
MOV A, #49H ; low byte
CALL sixteenBitDivision ; osztás
MOV R7, B
MOV 20H, R7
; 1-es helyiérték: R7

MOV R0, #64H ; osztó: 100
MOV R2, #0BAH ; high byte
MOV A, #49H ; low byte
CALL sixteenBitDivision ; osztás

; R3: fels?
; A: alsó
MOV R5, A
MOV A, R0
MOV R4, A

MOV R0, #0AH ; osztó: 10
MOV A, R3
MOV R2, #0H ; high byte
MOV A, B ; low byte
CALL sixteenBitDivision ; osztás
MOV R6, A
MOV 30H, R6

MOV R0, #64H ; osztó: 100
MOV A, R4
MOV R2, A ; high byte
MOV A, R5 ; low byte
CALL sixteenBitDivision ; osztás

MOV R0, #0AH ; osztó: 10
MOV A, R3
MOV R2, #0H ; high byte
MOV A, B ; low byte
CALL sixteenBitDivision ; osztás
MOV 40H, B
MOV 50H, A

MOV R0, #64H ; osztó: 100
MOV A, R4
MOV R2, A ; high byte
MOV A, R5 ; low byte
CALL sixteenBitDivision ; osztá
MOV 60H, A

;MOV R0, #0AH ; osztó
;MOV R2, #00H ; high byte
;MOV A, b ; low byte
;CALL sixteenBitDivision ; osztás
;MOV R6, A
; 10-es helyiérték: R6
;MOV R0, #0AH ; osztó
;MOV R2, #00H ; high byte
;MOV A, r4 ; low byte
;CALL sixteenBitDivision ; osztás
;MOV R5, B
;MOV R4, A
; =============================
JMP Vege
 
sixteenBitDivision:
PUSH PSW
MOV R1, #0H
MOV R3, #0H
clearC:
CLR C
subA:
SUBB A, R0
PUSH PSW
CJNE R1, #0FFH, megnemcsordultul
INC R3
megnemcsordultul:
POP PSW
INC R1
JNC subA
DEC R2
CJNE R2, #0FFH, clearC
DEC R1
ADD A, R0
MOV B, A
MOV A, R3
MOV R0, A
MOV A, R1
POP PSW
RET

Reset:
MOV B, #0H
MOV A, #0H
MOV R0, #0H
MOV R1, #0H
MOV R2, #0H
MOV R3, #0H
MOV R4, #0H
MOV R5, #0H
MOV R6, #0H
MOV R7, #0H
MOV 10H, #0H
MOV 11H, #0H
MOV 12H, #0H
RET

Vege:
END
