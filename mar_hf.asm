; *****************************************************
; Memóriakezelés
; *****************************************************
; Részeredmények tárolása
DIGIT10000 EQU 0x60 ; Tízezres helyiérték számjegye ezen a címen van a memóriában
DIGIT1000 EQU 0x50 ; Ezres helyiérték számjegye ezen a címen van a memóriában
DIGIT100 EQU 0x40 ; Százas helyiérték számjegye ezen a címen van a memóriában
DIGIT10 EQU 0x30 ; Tízes helyiérték számjegye ezen a címen van a memóriában
DIGIT1 EQU 0x20 ; Egyes helyiérték számjegye ezen a címen van a memóriában
; Bemeneti paraméterek címe
INPUT_L EQU 0x10 ; Osztás bemenetének alsó bájtja
INPUT_H EQU 0x11 ; Osztás bemenetének felső bájtja
; Bemeneti paraméterek tartalma
DATA_L EQU 49H
DATA_H EQU 0BAH

; *****************************************************
; Sebők Bence (K3VH3H)
; Feladat megfogalmazása:
; Regiszterekben található 16 bites előjel nélküli egész átalakítása 5 db BCD kódú számmá.
; Az eredményt 3 regiszterben kapjuk vissza: az elsőben a 4 felső bit 0, alatta a legmagasabb helyiértékű digit, a másodikban a következő két digit, a harmadikban a legkisebb helyiértékű két digit.
; Bemenet: az átalakítandó szám 2 regiszterben, kimenet az átalakított szám 3 regiszterben.
; *****************************************************
; Főprogram
ORG 0
CALL Reset ; Regiszterek nullázása (szimulációhoz)
MOV INPUT_L, #DATA_L ; Osztás bemenetének alsó bájtja
MOV INPUT_H, #DATA_H ; Osztás bemenetének felső bájtja

; Egyes helyiérték számjegyének meghatározása:
MOV R0, #0AH ; osztó: 10 (hexadecimálisan 0AH)
MOV R2, INPUT_H ; Osztás bemenetének felső bájtja
MOV A, INPUT_L ; Osztás bemenetének alsó bájtja
CALL Division ; 16 bites osztás, osztandó: 0BA49H, osztó: 0AH (decimális 10)
MOV DIGIT1, B ; DIGIT1 címre mentem az egyes helyiérték számjegyét

; Alsó két helyiérték számjegyének meghatározása
MOV R0, #64H ; osztó: 100 (hexadecimálisan 64H)
MOV R2, #DATA_H ; Osztás bemenetének felső bájtja
MOV A, #DATA_L ; Osztás bemenetének alsó bájtja
CALL Division ; 16 bites osztás
; Részeredmények tárolása a következő osztáshoz
MOV R5, A ; Hányados alsó bájtja
MOV A, R0
MOV R4, A ; Hányados felső bájtja

; Tízes helyiérték számjegyének meghatározása:
MOV R0, #0AH ; osztó: 10
MOV A, R3 
MOV R2, #0H ; Osztás bemenetének felső bájtja
MOV A, B ; Osztás bemenetének alsó bájtja
CALL Division ; 16 bites osztás
MOV DIGIT10, A ; DIGIT10 címre mentem a tízes helyiérték számjegyét

MOV R0, #64H ; osztó: 100 (hexadecimálisan 64H)
; Részeredmények betöltése az előuő osztásból
MOV A, R4
MOV R2, A ; Osztás bemenetének felső bájtja
MOV A, R5 ; Osztás bemenetének alsó bájtja
CALL Division ; 16 bites osztás

; Ezres és százas helyiérték számjegyeinek meghatározása:
MOV R0, #0AH ; osztó: 10 (hexadecimálisan 0AH)
MOV A, R3
MOV R2, #0H ; Osztás bemenetének felső bájtja
MOV A, B ; Osztás bemenetének alsó bájtja
CALL Division ; 16 bites osztás
MOV DIGIT100, B
MOV DIGIT1000, A

; Tízezres helyiérték számjegyének meghatározása:
MOV R0, #64H ; osztó: 100 (hexadecimálisan 64H)
MOV A, R4
MOV R2, A ; Osztás bemenetének felső bájtja
MOV A, R5 ; Osztás bemenetének alsó bájtja
CALL Division ; 16 bites osztás
MOV DIGIT10000, A

; Végeredmény mentése és főprogram befejezése
JMP saveToRegisters ; Az egyes helyiértékek számjegyeit elmentem az R5, R6, R7 regiszterekbe
JMP endOfProgram ; Program vége
; *****************************************************

; Division szubrutin
; Részfeladat: a bemenetként kapott 16 bites számot (felső bájt: R2, alsó bájt: A) elosztja egy 8 bites osztóval (R0) és az eredményt (hányadost: R3, R1).
; Bemenet:
; - A: 16 bites szám alsó bájtja
; - R2: 16 bites szám felső bájtja
; - R0: 8 bites osztó
; Kimenet:
; - R3: hányados felső bájtja
; - R1: hányados alsó bájtja
; - B: maradék
; Szubrutin módosítja a következőket: A, B, R0, R1, R2, R3
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
; Hányados átvitelének ellenőrzése:
PUSH PSW ; Carry flag miatti mentés
CJNE R1, #0FFH, NoOverflow ; Ha a hányados alsó bájtja még nem csordul túl, akkor simán növeljük meg 1-gyel
INC R3 ; Ha az alsó bájton túlcsordulás van, akkor növeljük 1-gyel a felső bájtot
NoOverflow: ; Ha nincs az alsó bájton túlcsordulás, akkor:
POP PSW ; Akksi (Carry miatt) visszatöltése
INC R1 ; Hányados alsó bájtjának növelése
JNC Substracion ; Ha még nem csordul túl az osztandó alsó bájtja, akkor vonjuk ki újra az osztót
DEC R2 ; Ha túlcsordul az osztandó alsó bájtja, akkor csökkentsük az osztandó felső bájtját
CJNE R2, #0FFH, clearC ; Ha az osztandó felső bájtja még nem csordul túl, akkor folytassuk a kivonásokat
;  Az osztandó felső bájtja akkor csordul túl, ha elérte a nullát és csökkentettük
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
; Részfeladat: nullára állítja a következőket:
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
; Részfeladat: az osztásból kapott részeredmények elmentése a kimeneti regiszterekbe.
; Bemenet:
; - DIGIT1
; - DIGIT10
; - DIGIT100
; - DIGIT1000
; - DIGIT10000
; a fenti memóriacímek, ahol az egyes helyiértékek számjegyei vannak
; Kimenet:
; - R7 regiszterben az egyes és tízes helyiértéken szereplő számjegyek
; - R6 regiszterben a százas és ezres helyiértéken szereplő számjegyek
; - R5 regiszterben a tízezeres helyiértéken szereplő számjegy
; (BCD kódolással)
; Szubrutin módosítja a következőket:
; - R7, R6, R5 regiszterek
saveToRegisters:
PUSH ACC ; ACC használata miatt elmentjük a Stack-re
MOV A, DIGIT10 ; Tízes helyiérték számjegyét teszem az akksiba, hogy a fels? 4 bitre forgassam
SWAP A ; Megcserélem az ACC alsó és felső 4 bitjét, így a felsőn lesz a tízes helyiérték számjegye, az alsón még négy darab 0 van
ORL A, DIGIT1 ; Hozzávagyolom az egyes helyiérték számjegyét, így a fels? 4 biten a tízes helyiérték számjegye, alsón pedig az egyes helyiérték számjegye
MOV R7, A ; Elhelyezem az egyes és tízes helyiérték számjegyeiből álló számot az R7 regiszterbe
MOV A, DIGIT1000 ; Ezres számjegy az akksiba hogy a felső 4 bitre forgassam
SWAP A ; Alsó és felső 4 bit cseréje, hogy felül legyen az ezres számhegy
ORL A, DIGIT100 ; Hozzávagyolom a százas számjegyet az alsó 4 bitre
MOV R6, A ; Elhelyezem a százas és ezres helyiérték számjegyeiből álló számot az R6 regiszterbe
MOV A, DIGIT10000 ; Tízezres számjegy az akksiba
MOV R5, A ; Elhelyezem a tízezres számjegyet az R5 regiszterbe (felső 4 bit az nulla)
POP ACC ; Használat után visszatöltjük az eredeti értékét
RET

; Program vége
endOfProgram:
END
