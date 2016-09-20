        ;; This code is derived from
        ;;     Hello World  written by Timo "NYYRIKKI" Soilamaa
        ;;     http://sc3000-multicart.com/downloads/xevious_kr_sc3000.asm


        
; WLA-DX banking setup

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

; SDSC tag and SMS rom header

.sdsctag 1.2,"Test 2 pads","Test 2 pads","k"

.bank 0 slot 0

.DEFINE DATAP $BE ; VDP Data port 
.DEFINE CMDP $BF ; VDP Command port 

.DEFINE CONTROLLER1 $DC
.DEFINE CONTROLLER2 $DD	

;; screen is 24*40
.DEFINE ROWS 24
.DEFINE COLS 40


.define PAD_UP    0
.define PAD_DOWN  1
.define PAD_LEFT  2
.define PAD_RIGHT 3
.define PAD_1     4
.define PAD_2     5

.DEFINE COLOR $C000
.DEFINE PATTERNT $C001
.DEFINE PATTERNTR $C002
.DEFINE PATTERNB $C003
.DEFINE PATTERNBR $C004


        
	
.ORG 0 
jp main

.org $0038                      ;VDP interrupt
jp vdpInterrupt

.org $0066                      ;NMI (pause)
ret
	
clearVdp:
; set VDP write address to $0000
XOR A
OUT (CMDP),A
LD A,$40
OUT (CMDP),A
;clear the first 16Kb of VDP memory
LD B,0
LD HL,$3FFF
LD C,DATAP
clear:
OUT (C),B 
DEC HL
LD A,H
OR L
;pause for the vdp
NOP 
NOP
JR NZ,clear
ret


writeChar:
;; each char has height rows
LD B,8
sendChar:	
OUT (DATAP),A
DJNZ sendChar
ret	

loadSprites:	
; set VDP write address to $808 
; (No need to write SPACE it is clear char already)
PUSH AF
PUSH BC
LD A,$08
OUT (CMDP),A
LD A,$48
OUT (CMDP),A
LD A,(PATTERNT)
call writeChar
LD A,(PATTERNTR)
call writeChar
LD A,(PATTERNB)
call writeChar
LD A,(PATTERNBR)
call writeChar
POP BC
POP AF
ret



fillHalfline:
PUSH BC
LD B,COLS/2
-:
OUT (DATAP),A	
DJNZ -
POP BC
RET



fillScreen:
DI
PUSH BC


LD A,$00
OUT (CMDP),A
LD A,$40
OUT (CMDP),A
	
LD B,ROWS/2
-:	
LD A,$01
call fillHalfline
LD A,$02
call fillHalfline
DJNZ -

LD B,ROWS/2
-:	
LD A,$03
call fillHalfline
LD A,$04
call fillHalfline
DJNZ -
	
POP BC
EI
ret
	

	

ppiFix:
.define sc_ppi_c                       $de
.define sc_ppi_control                 $df

; Make sure the joystick column of the keyboard matrix
; is selected.  This is required for games like Yie Ar Kung Fu
; that never ran on an SC-3000 and just assume that sc_ppi_c
; has the joystick input.

ld     a,%10010010                           ; initialise SC PPI: set I/O to mode 0, A+B in, C out
out    (sc_ppi_control),a
nop    
nop
nop
nop
in     a,(sc_ppi_c)
or     %00000111
out    (sc_ppi_c), a                        ; and select the joystick column of keyboard matrix
nop    
nop
nop
nop
nop
ret

;; returns the controller status in A
getController1:
IN A,(CONTROLLER1)
AND $3F
ret

;; returns the controller status in A        
getController2:
PUSH BC
LD C,CONTROLLER1
IN A,(CONTROLLER2)
AND $0F
fuse:  
IN B,(C)
.REPEAT 6
SRL B
.ENDR
.REPEAT 2
SLA A
.ENDR
OR B
POP BC
ret



main:
DI 
IM 1
	
LD sp, $dff0	
EI
call clearVdp
LD A,$70
LD (COLOR),A
LD A,$A8
LD (PATTERNT),A
LD (PATTERNB),A
LD (PATTERNTR),A
LD (PATTERNBR),A	
call ppiFix	
call loadSprites
call setVdpRegisters
call fillScreen
loop:	
jp loop


padToColor:
PUSH BC
call getController1		
LD B,A
XOR A
BIT PAD_UP,B
JR NZ,+
OR $01
+:
BIT PAD_RIGHT,B
JR NZ,+
OR $02
+:
BIT PAD_1,B
JR NZ,+
OR $04
+:
BIT PAD_2,B
JR NZ,+
OR $08
+:
PUSH AF
call getController2		        
LD B,A
POP AF
BIT PAD_UP,B
JR NZ,+
OR $10
+:        
BIT PAD_RIGHT,B
JR NZ,+
OR $20
+:
BIT PAD_1,B
JR NZ,+
OR $40
+:
BIT PAD_2,B
JR NZ,+
OR $80
+:        
POP BC       
ret
              
	
vdpInterrupt:
IN A,(CMDP) 			;read the vdp
call padToColor                 
LD (COLOR),A            
call setVdpRegisters
EI
ret

setVdpRegisters:
; Now it is time to set up VDP registers:
;----------------------------------------
; Register 0
;
; Set mode selection bit M3 (maybe also M4 & M5) to zero and 
; disable external video & horizontal interrupt
XOR A
LD E,$80
LD C,CMDP
OUT (CMDP),A
OUT (C),E
;---------------------------------------- 
; Register 1 
;
; Select 40 column mode, enable screen and disable vertical interrupt

LD A,$70			;without interrupt is $50
INC E
OUT (CMDP),A
OUT (C),E
;---------------------------------------- 
; Register 2
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
; Register 7
; Set colors 

LD HL,COLOR
LD A,(HL)

INC E
OUT (CMDP),A
OUT (C),E
ret

