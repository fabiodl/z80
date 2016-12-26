;============================================================== ;
; WLA-DX banking setup
;==============================================================
.memorymap
defaultslot 0
slotsize $8000
slot 0 $0000
.endme

.rombankmap
bankstotal 1
banksize $8000
banks 1
.endro

;==============================================================
; SDSC tag and SMS rom header
;==============================================================
.sdsctag 1.2,"Menu","sg1000","k"

.bank 0 slot 0

; This is a "Hello World" program for Z80 and TMS9918 / TMS9928 / TMS9929 /
; V9938 or V9958 VDP.
; That means that this should work on SVI, MSX, Colecovision, Memotech,
; and many other Z80 based home computers or game consoles.
;
; Because we don't know what system is used, we don't know where RAM
; is, so we can't use stack in this program.
;
; This version of Hello World was written by Timo "NYYRIKKI" Soilamaa
; 17.10.2001
;
;----------------------------------------------------------------------
; Configure this part:

.DEFINE DATAP $BE ; VDP Data port $98 works on all MSX models
; (TMS9918/TMS9929/V9938 or V9958)
; $80 works on SVI 
; (for other platforms you have to figure this out by your self)

.DEFINE CMDP $BF ; VDP Command port $99 works on all MSX models
; (TMS9918/TMS9929/V9938 or V9958)
; $81 works on SVI
; (for other platforms you have to figure this out by your self)
;-----------------------------------------------------------------------
; Program starts here:

	
.ORG 0 ; Z80 starts always from here when power is turned on
DI ; We don't know, how interrupts works in this system, so we disable them.
im 1
jp main



.org $0066
; Here is address $66, that is entry for NMI
RETN ;Return from NMI


.org $5245
	
;; address of the string in BC
prints:	
LD A,(BC)
SUB ' '
JP m,lastchar
OUT (DATAP),A
INC BC
/*NOP
NOP*/
jp prints
lastchar:	
ret
;; number to print in (B)C


	
clearVdp:
; Let's set VDP write address to $0000
XOR A
OUT (CMDP),A
LD A,$40
OUT (CMDP),A



; Now let's clear first 16Kb of VDP memory
LD B,0
LD HL,$3FFF
LD C,DATAP
CLEAR:
OUT (C),B ; LD (DATAP),B is invalid, only LD (DATAP),A
DEC HL
LD A,H
OR L
NOP ; Let's wait 8 clock cycles just in case VDP is not quick enough.
NOP
JR NZ,CLEAR
ret

loadSprites:	
;----------------------------------------
; Let's set VDP write address to $808 so, that we can write
; character set to memory
; (No need to write SPACE it is clear char already)
LD A,8
OUT (CMDP),A
LD A,$48
OUT (CMDP),A

; Let's copy character set
LD HL,CHARS
LD B, (CHARS_END-CHARS)/8
COPYCHARS:
LD D,8
COPYCHAR:
LD A,(HL)
OUT (DATAP),A
INC HL
NOP ; Let's wait 8 clock cycles just in case VDP is not quick enough.
NOP
DEC D
JR NZ,COPYCHAR	
DJNZ COPYCHARS
RET



	
	;; returns the controller status in register A,dirty up C
.define PAD_UP    0
.define PAD_DOWN  1
.define PAD_LEFT  2
.define PAD_RIGHT 3
.define PAD_A     4
.define PAD_B     5
	
getController:
.DEFINE CONTROLLER1 $DC
.DEFINE CONTROLLER2 $DD	
PUSH BC
IN A,(CONTROLLER1)
BIT 6,A
JR NZ,nobup
AND $FE
nobup:	
BIT 7,A
JR NZ,nobdown			
AND $FD
nobdown:	
LD C,CONTROLLER2
IN C,(C)
SLL C
SLL C
AND C	
CPL	
AND $3F
POP BC
ret	

	

printn:
PUSH HL
LD HL,numbers
ADD HL,BC
ADD HL,BC
ADD HL,BC	
LD B,3
LD C,DATAP
OTIR
POP HL
RET


	
setVdpRegisters:
; Now it is time to set up VDP registers:
;----------------------------------------
; Register 0 to $0
;
; Set mode selection bit M3 (maybe also M4 & M5) to zero and 
; disable external video & horizontal interrupt
XOR A
LD E,$80
LD C,CMDP
OUT (CMDP),A
OUT (C),E
;---------------------------------------- 
; Register 1 to $50
;
; Select 40 column mode, enable screen and disable vertical interrupt

LD A,$70			;without interrupt is $50
INC E
OUT (CMDP),A
OUT (C),E
;---------------------------------------- 
; Register 2 to $0
;
; Set pattern name table to $0000

XOR A
INC E
OUT (CMDP),A
OUT (C),E
;---------------------------------------- 
; Register 3 is ignored as 40 column mode does not need color table
;
INC E
;---------------------------------------- 
; Register 4 to $1
; Set pattern generator table to $800

INC A
INC E

OUT (CMDP),A
OUT (C),E
;---------------------------------------- 
; Registers 5 (Sprite attribute) & 6 (Sprite pattern) are ignored 
; as 40 column mode does not have sprites

INC E
INC E
;---------------------------------------- 
; Register 7 to $70
; Set colors to cyan on black

LD A,$70
INC E
OUT (CMDP),A
OUT (C),E
RET

ppiFix:
.define sc_ppi_c                       $de
.define sc_ppi_control                 $df

; Add our new intitialisation code here
; Make sure the joystick column of the keyboard matrix
; is selected.  This is required for games like Yie Ar Kung Fu
; that never ran on an SC-3000 and just assume that sc_ppi_c
; has the joystick input.

ld     a,%10010010                           ; initialise SC PPI: set I/O to mode 0, A+B in, C out
out    (sc_ppi_control),a
nop    ; paranoia - probably not required :)
nop
nop
nop
in     a,(sc_ppi_c)
or     %00000111
out    (sc_ppi_c), a                        ; and select the joystick column of keyboard matrix
nop    ; just for paranoia :)
nop
nop
nop
nop
ret


	
	;; position in D=row E=col
moveCursor:	
PUSH HL
PUSH DE
.define COLUMNS 40
.define ROWS 24
.define PROPSNUM 3

.define GAMES 128
.define NUMPAGES 6 
.define LASTPAGEITEMS 13

	
LD HL,0
LD BC,COLUMNS
XOR A
rowCheck:	
CP D
JR Z,multok
ADD HL,BC
INC A
jp rowCheck
multok:
LD D,0
ADD HL,DE
SET 6,H
LD C,CMDP
OUT (C),L
NOP
OUT (C),H
POP DE
POP HL

ret


clearPage:
PUSH BC
PUSH DE
LD DE,$0000
call moveCursor
LD DE,COLUMNS*ROWS
-:
XOR A
OUT (DATAP),A
DEC DE
LD A,D
OR E
JR NZ,-
POP DE
POP BC
ret	




	;; color is specified in register A
setColor:	
OUT (CMDP),A
LD A,$87
OUT (CMDP),A
RET

	
	
printPage: 			;prints a page starting from page B
PUSH BC
PUSH DE
LD D,0
LD E,B
LD HL,pagesColor
ADD HL,DE
LD A,(HL)
call setColor
LD HL,titlePages
XOR A
CP B
JR Z,addrok	
LD DE,ROWS*COLUMNS
compPage:	
ADD HL,DE
DJNZ compPage
addrok:
LD DE,$0000
call moveCursor
LD C,DATAP


LD B,0
OTIR
LD B,0
OTIR
LD B,0
OTIR
LD B,COLUMNS*ROWS-256*3 	;all - previous 3 otirs
OTIR

POP DE
POP BC
ret


incPage:	
INC B
LD A,B
CP NUMPAGES
JP M,inMaxRange
LD B, NUMPAGES-1
inMaxRange:	
CALL printPage	
ret


decPage:
DEC B
XOR A
LD A,B
CP $FF
JP NZ,inMinRange
LD B,0
inMinRange:	
CALL printPage
ret


delCursor:
PUSH BC
PUSH DE
LD D,C
INC D
LD E,0
call moveCursor
XOR A
OUT (DATAP),A
POP DE
POP BC
ret
	


	
	
main:
	
ld sp, $dff0
call initMusic	
ei
call clearVdp
call setVdpRegisters
call loadSprites
call ppiFix

LD DE,$0000
call moveCursor




	
	;; page in in B, row in C
LD BC,0
CALL printPage
		;CALL printGameProp
	
LD E,0	
controllerLoop:
CALL getController
CP E
JR Z,controllerLoop
LD E,A

checkRight:	
PUSH AF
BIT PAD_RIGHT,A
JR Z,+
call delCursor
call incPage
+:		
POP AF

checkLeft:	
PUSH AF
BIT PAD_LEFT,A
JR Z,+
call delCursor
call decPage
+:		
POP AF	

	


	
jp controllerLoop


pagesColor:	
.db $70,$30,$B0,$90,$D0,$F0
	




	
CHARS:
.INCLUDE "../fonts/msxFont.i"	
CHARS_END
.include "numbers.i"

.include "hexPages.i"





