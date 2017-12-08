; Részeredmények tárolása
DIGIT10000 EQU 0x60 ; Tízezres helyiérték számjegye ezen a címen van a memóriában
DIGIT1000 EQU 0x50 ; Ezres helyiérték számjegye ezen a címen van a memóriában
DIGIT100 EQU 0x40 ; Százas helyiérték számjegye ezen a címen van a memóriában
DIGIT10 EQU 0x30 ; Tízes helyiérték számjegye ezen a címen van a memóriában
DIGIT1 EQU 0x20 ; Egyes helyiérték számjegye ezen a címen van a memóriában

; Bemeneti paraméterek
BEMENET_ALSO EQU 0x01
BEMENET_FELSO EQU 0x11

; F?program
ORG 0
CALL Reset ; Regiszterek nullázása (szimulációhoz)
MOV BEMENET_ALSO, #0x49
MOV BEMENET_FELSO, #0xBA
MOV R0, #0AH ; osztó: 10
MOV R2, BEMENET_FELSO ; high byte
MOV A, BEMENET_ALSO ; low byte
CALL Division ; 16 bites osztás
MOV R7, B ; R7-be teszem az egyes helyiérték számjegyét
MOV 20H, R7 ; 20-as címre mentem az egyes helyiérték számjegyét
; 1-es helyiérték: R7, 20-as cím

MOV R0, #64H ; osztó: 100
MOV R2, #0BAH ; high byte
MOV A, #49H ; low byte
CALL Division ; 16 bites osztás

; R3: fels?
; A: alsó
MOV R5, A
MOV A, R0
MOV R4, A

MOV R0, #0AH ; osztó: 10
MOV A, R3
MOV R2, #0H ; high byte
MOV A, B ; low byte
CALL Division ; 16 bites osztás
MOV R6, A
MOV 30H, R6

MOV R0, #64H ; osztó: 100
MOV A, R4
MOV R2, A ; high byte
MOV A, R5 ; low byte
CALL Division ; 16 bites osztás

MOV R0, #0AH ; osztó: 10
MOV A, R3
MOV R2, #0H ; high byte
MOV A, B ; low byte
CALL Division ; 16 bites osztás
MOV 40H, B
MOV 50H, A

MOV R0, #64H ; osztó: 100
MOV A, R4
MOV R2, A ; high byte
MOV A, R5 ; low byte
CALL Division ; 16 bites osztás
MOV 60H, A

JMP saveToRegisters ; Az egyes helyiértékek számjegyeit elmentem az R5, R6, R7 regiszterekbe
JMP Vege ; Program vége

; Division szubrutin
; A bemenetként kapott 16 bites számot (R2, A) elosztja egy 8 bites osztóval (R0) és az eredményt (hányadost: R3, R1)
; Bemenet:
; - A: 16 bites szám alsó bájtja
; - R2: 16 bites szám fels? bájtja
; - R0: 8 bites osztó
Division:
; Használt regiszterek eredeti értékének mentése a Stack-re
PUSH PSW
; Hányados és maradék nullázása
MOV R1, #0H
MOV R3, #0H
clearC:
CLR C
Substracion:
SUBB A, R0 ; Alsó bájtból kivonja az osztót
; Hányados átvitelének ellen?rzése:
PUSH PSW ; Carry flag miatti mentés
CJNE R1, #0FFH, NoOverflow ; Ha a hányados alsó bájtja még nem csordul túl, akkor simán növeljük meg 1-gyel
INC R3 ; Ha az alsó bájton túlcsordulás van, akkor növeljük 1-gyel a fels? bájtot
NoOverflow: ; Ha nincs az alsó bájton túlcsordulás, akkor:
POP PSW ; Akksi (Carry miatt) visszatöltése
INC R1 ; Hányados alsó bájtjának növelése
JNC Substracion ; Ha még nem csordul túl az osztandó alsó bájtja, akkor vonjuk ki újra az osztót
DEC R2 ; Ha túlcsordul az osztandó alsó bájtja, akkor csökkentsük az osztandó fels? bájtját
CJNE R2, #0FFH, clearC ; Ha az osztandó fels? bájtja még nem csordul túl, akkor folytassuk a kivonásokat
;  Az osztandó fels? bájtja akkor csordul túl, ha elérte a nullát és csökkentettük
DEC R1 ; Eggyel többször vontuk ki az osztót az osztandóból, szóval adjuk hozzá egyszer
ADD A, R0 ; Akksiba teszem a maradékot
MOV B, A ; B-be teszem a maradékot
MOV A, R3 ; Akksiba teszem a hányados felső bájtját
MOV R0, A ; R0-ba teszem a hányados felső bájtját
MOV A, R1 ; R1-be teszem a hányados felső bájtját
; Használt regiszterek eredeti értékének visszatöltése
POP PSW
RET

; Szimulációhoz nullázó szubrutin
; Nullára állítja a következ?ket:
; - A, B
; - R1...R7
; - 10H, 11H, 12H, 20H, 21H, 30H, 31H
; - 40H, 50H, 60H, 70H
Reset: ; Nullát tölt a fent felsorolt regiszterekbe és memóriacímekre
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
MOV 20H, #0H
MOV 21H, #0H
MOV 30H, #0H
MOV 31H, #0H
MOV 40H, #0H
MOV 50H, #0H
MOV 60H, #0H
MOV 70H, #0H
RET

; saveToRegisters szubrutin
; Bemenet:
; - DIGIT1
; - DIGIT10
; - DIGIT100
; - DIGIT1000
; - DIGIT10000
; a fenti memóriacímek, ahol az egyes helyiértékek számjegyei vannak
; Kimenet:
; - R7 regiszterben az egyes és tízes helyiértéken szerepl? számjegyek
; - R6 regiszterben a százas és ezres helyiértéken szerepl? számjegyek
; - R5 regiszterben a tízezeres helyiértéken szerepl? számjegy
; Szubrutin módosítja a következ?ket:
; - R7, R6, R5 regiszterek
saveToRegisters:
PUSH ACC ; ACC használata miatt elmentjük a Stack-re
MOV A, DIGIT10 ; Tízes helyiérték számjegyét teszem az akksiba, hogy a fels? 4 bitre forgassam
SWAP A ; Megcserélem az ACC alsó és fels? 4 bitjét, így a fels?n lesz a tízes helyiérték számjegye, az alsón még négy darab 0 van
ORL A, DIGIT1 ; Hozzávagyolom az egyes helyiérték számjegyét, így a fels? 4 biten a tízes helyiérték számjegye, alsón pedig az egyes helyiérték számjegye
MOV R7, A ; Elhelyezem az egyes és tízes helyiérték számjegyeib?l álló számot az R7 regiszterbe
MOV A, DIGIT1000 ; Ezres számjegy az akksiba hogy a fels? 4 bitre forgassam
SWAP A ; Alsó és fels? 4 bit cseréje, hogy felül legyen az ezres számhegy
ORL A, DIGIT100 ; Hozzávagyolom a százas számjegyet az alsó 4 bitre
MOV R6, A ; Elhelyezem a százas és ezres helyiérték számjegyeib?l álló számot az R6 regiszterbe
MOV A, DIGIT10000 ; Tízezres számjegy az akksiba
MOV R5, A ; Elhelyezem a tízezres számjegyet az R5 regiszterbe (fels? 4 bit az nulla)
POP ACC ; Használat után visszatöltjük az eredeti értékét
RET

; Program vége
Vege:
END
