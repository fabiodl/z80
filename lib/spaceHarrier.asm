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

.sdsctag 1.2,"Menu","sg1000","k"
	
.bank 0 slot 0
	
.define MUSICRAM $C000	
.DEFINE CMDP $BF ; VDP Command port $99 works on all MSX models

.define FM_REG $F0
.define FM_DATA $F1
.define FM_SWITCH $F2
.define IOMAN $3E
.define PSG $7F	
	


.org $18
_RST_18H:
  push hl
  pop hl
  ret


.org $28
_RST_28H:
  ld c, a
  ld b, $0
  add hl, bc
  add hl, bc
  ld a, (hl)
  inc hl
  ld h, (hl)
  ld l, a
  ret

.org $38
_IRQ_HANDLER:
 push af
  in a, (CMDP)
  push bc
  push de
  push hl
  ex af, af'
  push af
  call _Label_AA8_58_musicStep   	;need
  pop af
  ex af, af'
  pop hl
  pop de
  pop bc
  pop af
  ei
  ret

.org $100
initMusic:
  di
  im 1
  ld  A,$AF
  out (IOMAN),A
  ld a, $3
  out (FM_SWITCH), a
		;  ld sp, $DFEF	
  call _Label_EC0_15_psginit		
  ei
  ld a, $81
  ld (MUSICRAM+$03),a		;need
ret				




_Label_AA8_58_musicStep:
  ld hl, MUSICRAM+$0C
  exx
  call _Label_B16_59		;need

  call _Label_B24_61		;need

  ld a, $1
  ld (MUSICRAM+$00), a
  or a
  ex af, af'
  call _Label_AC5_69   		;need, sound changes
  xor a
  ld (MUSICRAM+$00), a
  or a
  ex af, af'
  jp _Label_AED_114




	
_Label_AC5_69:
  ld ix, MUSICRAM+$0D
  ld b, $7
_Label_ACB_87:
  push bc
  ld a, b
  ld (MUSICRAM+$06), a
  cp $1
  jr z, _Label_AE4_70
  bit 7, (ix+$0)
  call nz, _Label_BED_88 	;need,sound changes
_Label_ADB_86:
  ld de, $20
  add ix, de
  pop bc
  djnz _Label_ACB_87            ;need,sound changes
  ret

_Label_AE4_70:
  bit 7, (ix+$0)
  call nz, _Label_B99_71
  jr _Label_ADB_86

_Label_AED_114:
  ld ix, MUSICRAM+$ED
  ld b, $4
_Label_AF3_134:
  push bc
  ld a, b
  inc a
  ld (MUSICRAM+$DE), a
  cp $2
  jr z, _Label_B0D_115
  bit 7, (ix+$0)
  call nz, _Label_F8A_135
_Label_B04_133:
  ld de, $20
  add ix, de
  pop bc
  djnz _Label_AF3_134
  ret

_Label_B0D_115:
  bit 7, (ix+$0)
  call nz, _Label_EEF_116
  jr _Label_B04_133

_Label_B16_59:
  ld hl, MUSICRAM+$03
  ld a, (hl)
  or a
  jp p, _Label_B21_60
  ld (MUSICRAM+$02), a
_Label_B21_60:
  xor a
  ld (hl), a
  ret

_Label_B24_61:
  ld a, (MUSICRAM+$02)
  cp $81
  ret nz
  ld bc, MUSICDATA+$1166-$1059
  jp _Label_B30_62

_Label_B30_62:
  push bc
  call _Label_EC0_15_psginit
  pop bc
  call _Label_B3E_63
  ld de, MUSICRAM+$0D
  jp _Label_B64_65

_Label_B3E_63:
  push bc
  ld b, $12
  ld hl, fminit
_Label_B44_64:
  ld c, FM_REG
  outi
  rst $18
  ld c, FM_DATA
  outi
  rst $18
  jr nz, _Label_B44_64
  pop bc
  ret


; Data from $B52 to $B63 (18 bytes)
fminit:	
.db $16, $20, $17, $B0, $18, $01, $26, $05, $27, $01, $28, $01, $36, $00, $37, $50
.db $38, $03



	
.org $3B4			;needed

; Data from $3B4 to $AA7 (1780 bytes) only 90 bytes may be unused, other is all used
.incbin "spaceHarrier3B4.i"

	

_Label_B64_65:
  ex af, af'
  ld h, b
  ld l, c
  ld b, (hl)
  inc hl
	
_Label_B69_68:
  push bc
  push hl
  pop ix
  ld bc, $9
  ldir
  ld a, $20
  ld (de), a
  inc de
  ld a, $1
  ld (de), a
  inc de
  xor a
  ld (de), a
  inc de
  ld (de), a
  inc de
  ld (de), a
  ex de, hl
  ld c, $12
  add hl, bc
  ex de, hl
  inc de
  ex af, af'
  push af
  call _Label_CA9_66  
  call _Label_104C_67
  pop af
  ex af, af'
  pop bc
  djnz _Label_B69_68
  ld a, $80
  ld (MUSICRAM+$02), a
  ret

_Label_B99_71:
  inc (ix+$B)
  ld a, (ix+$A)
  sub (ix+$B)
  jr nz, _Label_BB3_72
  call _Label_BBF_73
  ld a, $E
  out (FM_REG), a
  ld a, (ix+$10)
  or $20
  out (FM_DATA), a
  ret

_Label_BB3_72:
  cp $2
  ret nz
  ld a, $E
  out (FM_REG), a
  rst $18
  xor a
  out (FM_DATA), a
  ret

_Label_BBF_73:
  ld e, (ix+$3)
  ld d, (ix+$4)
label_bc5:	
  ld a, (de)
  inc de
  cp $E0
  jp nc, _Label_BE3_74
  cp $7F
  jp c, _Label_D67_78
  bit 5, a
  jr z, _Label_BD7_81
  or $1
_Label_BD7_81:
  bit 4, a
  jr z, _Label_BDD_82
  or $10
_Label_BDD_82:
  ld (ix+$10), a
  jp _Label_D59_83

_Label_BE3_74:
  ld hl, labelbe9
  jp _Label_DAA_75

labelbe9:  			;was thought data
 INC DE
 JP label_bc5

_Label_BED_88:
  inc (ix+$B)
  ld a, (ix+$A)
  sub (ix+$B)
  call z, _Label_D13_89
  ld (MUSICRAM+$0C), a
  cp $80
  jp z, _Label_C36_96
  bit 5, (ix+$0)
  jp z, _Label_C36_96
  exx
  ld (hl), $80
  exx
  ld a, (ix+$11)
  or a
  jp p, _Label_C21_111
  add a, (ix+$E)
  jr c, _Label_C33_112
  dec (ix+$F)
  dec (ix+$F)
  jp _Label_C2F_113

_Label_C21_111:
  add a, (ix+$E)
  jr nc, _Label_C33_112
  inc (ix+$F)
  inc (ix+$F)
  jp _Label_C2F_113

_Label_C2F_113:
  set 1, (ix+$7)
_Label_C33_112:
  ld (ix+$E), a
_Label_C36_96:
  ld a, (ix+$13)
  cp $1F
  ret z
  ld a, (MUSICRAM+$0C)
  bit 0, (ix+$7)
  jr nz, _Label_C4A_97
  cp $2
  jp c, _Label_CBF_100
_Label_C4A_97:
  or a
  jp m, _Label_C5B_98
  bit 7, (ix+$14)
  ret nz
  ld a, (ix+$6)
  dec a
  jp p, _Label_C5F_110
  ret

_Label_C5B_98:
  ld a, (ix+$6)
  dec a
_Label_C5F_110:
  ld l, (ix+$E)
  ld h, (ix+$F)
  jp m, _Label_C70_99
  ex de, hl
  ld hl, MUSICDATA+$142E-$1059
  rst $28
  call _Label_CD6_104
_Label_C70_99:
  bit 0, (ix+$0)
  ret nz
  ld a, l
  or h
  jp z, _Label_CBF_100
  ld c, FM_DATA
  ld a, (ix+$1)
  out (FM_REG), a
  add a, $10
  rst $18
  out (c), l
  rst $18
  exx
  bit 7, (hl)
  exx
  out (FM_REG), a
  jr nz, _Label_C9E_101
  bit 0, (ix+$7)
  jr z, _Label_C9E_101
  bit 1, (ix+$7)
  ret z
  res 1, (ix+$7)
_Label_C9E_101:
  bit 2, (ix+$7)
  jr z, _Label_CA6_102
  set 5, h
_Label_CA6_102:
  out (c), h
  ret

_Label_CA9_66:
  ld a, (ix+$1)
  add a, $20
  out (FM_REG), a
  ld a, (ix+$7)
  and $F0
  ld c, a
  ld a, (ix+$8)
  and $F
  or c
  out (FM_DATA), a
  ret

_Label_CBF_100:
  xor a
  ld (MUSICRAM+$04), a
  ld a, (ix+$1)
  add a, $10
  out (FM_REG), a
  rst $18
  ld (ix+$13), $1F
  xor a
  out (FM_DATA), a
  ret

_Label_CD3_108:
  ld (ix+$D), a
_Label_CD6_104:
  ld a, (ix+$D)
  add a, l
  ld c, a
  adc a, h
  sub c
  ld b, a
  ld a, (bc)
  or a
  jp p, _Label_CF8_105
  cp $83
  jr z, _Label_CF1_107
  cp $80
  jr z, _Label_CF5_109
  ld (ix+$14), $FF
  pop hl
  ret

_Label_CF1_107:
  inc bc
  ld a, (bc)
  jr _Label_CD3_108

_Label_CF5_109:
  xor a
  jr _Label_CD3_108

_Label_CF8_105:
  inc (ix+$D)
  ld l, a
  ld h, $0
  add hl, de
  ld a, (MUSICRAM+$00)
  or a
  jr z, _Label_D0F_106
  ld a, h
  cp (ix+$10)
  jr z, _Label_D0F_106
  set 1, (ix+$7)
_Label_D0F_106:
  ld (ix+$10), a
  ret

_Label_D13_89:
  ld a, (ix+$8)
  or a
  jp p, _Label_D25_90
  inc a
  bit 6, a
  jr nz, _Label_D20_95
  inc a
_Label_D20_95:
  and $3F
  ld (ix+$8), a
_Label_D25_90:
  ld e, (ix+$3)
  ld d, (ix+$4)
label_D2B_:	
  ld a, (de) 			;accessing 3B4..
  inc de
  cp $E0
  jp nc, _Label_DA7_91
  cp $80
  jp c, _Label_D67_78
  call _Label_D90_92
  ld a, (hl)
  ld (ix+$E), a
  inc hl
  ld a, (hl)
  ld (ix+$F), a
  bit 5, (ix+$0)
  jp z, _Label_D59_83
  ld a, (de)
  inc de
  ld (ix+$12), a
  ld (ix+$11), a
  ld (ix+$11), a
  inc de
  ld a, (de)
  jr _Label_D66_84

_Label_D59_83:
  ld a, (de)
  or a
  jp p, _Label_D66_84
  ld a, (ix+$15)
  ld (ix+$A), a
  jr _Label_D77_85

_Label_D66_84:
  inc de
_Label_D67_78:
  ld b, (ix+$2)
  dec b
  jr z, _Label_D71_79
  ld c, a
_Label_D6E_80:
  add a, c
  djnz _Label_D6E_80
_Label_D71_79:
  ld (ix+$A), a
  ld (ix+$15), a
_Label_D77_85:
  xor a
  ld (ix+$C), a
  ld (ix+$D), a
  ld (ix+$B), a
  ld (ix+$13), a
  ld (ix+$14), a
  ld (ix+$3), e
  ld (ix+$4), d
  ld a, $80
  ret

_Label_D90_92:
  sub $80
  jr z, _Label_D97_93
  add a, (ix+$5)
_Label_D97_93:
  ld hl, MUSICDATA
  ex af, af'
  jr z, _Label_DA0_94
  ld hl, MUSICDATA+$10D3-$1059
_Label_DA0_94:
  ex af, af'
  ld c, a
  ld b, $0
  add hl, bc
  add hl, bc
  ret


	
_Label_DA7_91:
  ld hl, dynamicLabel
_Label_DAA_75:
  push hl
  sub $F0
  jp c, _Label_E22_76
  ld hl, musicJumpTable
  add a, a
  ld c, a
  ld b, $0
  add hl, bc
  ld c, (hl)
  inc hl
  ld h, (hl)
  ld l, c
  jp (hl)


dynamicLabel:
LD HL,MUSICRAM+$06
BIT 0,(HL)
JR Z,_label_dc9_
LD A,$01
LD (MUSICRAM+$04),A
_label_dc9_:	
INC DE
JP label_D2B_  

musicJumpTable:
; Jump Table from DCD to DEC (16 entries, indexed by unknown)
.dw _LABEL_E02_ _LABEL_DFD_ _LABEL_E7A_ _LABEL_E35_ _LABEL_E60_ _LABEL_E49_ label_E65 _LABEL_EA8_
.dw _LABEL_E7A_ _LABEL_E95_ _Label_E22_76 _LABEL_E1A_ _LABEL_E6B_ _LABEL_DEE_ _LABEL_DED_ _LABEL_DF8_

; 15th entry of Jump Table from DCD (indexed by unknown)
_LABEL_DED_:
	ret

; 14th entry of Jump Table from DCD (indexed by unknown)
_LABEL_DEE_:
	set 0, (ix+0)
	set 0, (ix+7)
	dec de
	ret

; 16th entry of Jump Table from DCD (indexed by unknown)
_LABEL_DF8_:
	ld a, (de)
	ld (MUSICRAM+$05), a
	ret

; 2nd entry of Jump Table from DCD (indexed by unknown)
_LABEL_DFD_:
	ld a, (de)
	ld (MUSICRAM+$04), a
	ret

; 1st entry of Jump Table from DCD (indexed by unknown)
_LABEL_E02_:
	dec de
	ld a, (ix+8)
	and $0F
	or a
	ret z
	dec a
	jr nz, _LABEL_E11_
	or $40
	jr _LABEL_E12_

_LABEL_E11_:
	dec a
_LABEL_E12_:
	or $80
	ld (ix+8), a
	jp _LABEL_E32_

; 12th entry of Jump Table from DCD (indexed by unknown)
_LABEL_E1A_:
	ld a, (de)
	add a, (ix+5)
	ld (ix+5), a
	ret	

; 11th entry of Jump Table from DCD (indexed by unknown)
_Label_E22_76:
	dec de
	ex af, af'
	jr nz, _Label_E28_77
	ex af, af'
	ret

_Label_E28_77:
	ex af, af'
	and $0F
	ld (ix+8), a
	res 0, (ix+0)
_LABEL_E32_:
	jp _Label_CA9_66

; 4th entry of Jump Table from DCD (indexed by unknown)
_LABEL_E35_:
	ld a, (de)
	or $E0
	out (PSG), a
	or $FC
	inc a
	jr nz, _LABEL_E44_
	res 6, (ix+0)
	ret

_LABEL_E44_:
	set 6, (ix+0)
	ret

; 6th entry of Jump Table from DCD (indexed by unknown)
_LABEL_E49_:
	ex af, af'
	jr nz, _LABEL_E56_
	ex af, af'
	ld a, (de)
	inc de
	cp $80
	ret z
	ld (ix+7), a
	ret

_LABEL_E56_:
	ex af, af'
	inc de
	ld a, (de)
	cp $04
	ret z
	ld (ix+7), a
	ret

; 5th entry of Jump Table from DCD (indexed by unknown)
_LABEL_E60_:
	ld a, (de)
	ld (ix+6), a
	ret

; 7th entry of Jump Table from DCD (indexed by unknown)
label_E65:
	ex de, hl
	ld e, (hl) 		;accessing 3B4..
	inc hl
	ld d, (hl)	       	;;accessing 3B4..
	dec de
	ret

; 13th entry of Jump Table from DCD (indexed by unknown)
_LABEL_E6B_:
	ld a, (de)
	cp $01
	jr nz, _LABEL_E75_
	set 5, (ix+0)
	ret

_LABEL_E75_:
	res 5, (ix+0)
	ret

; 3rd entry of Jump Table from DCD (indexed by unknown)
_LABEL_E7A_:
	ld a, (de)
	ld c, a
	inc de
	ld a, (de)
	ld b, a
	push bc
	push ix
	pop hl
	dec (ix+9)
	ld c, (ix+9)
	dec (ix+9)
	ld b, $00
	add hl, bc
	ld (hl), d
	dec hl
	ld (hl), e
	pop de
	dec de
	ret

; 10th entry of Jump Table from DCD (indexed by unknown)
_LABEL_E95_:
	push ix
	pop hl
	ld c, (ix+9)
	ld b, $00
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc (ix+9)
	inc (ix+9)
	ret

; 8th entry of Jump Table from DCD (indexed by unknown)
_LABEL_EA8_:
	ld a, (de) ;accessing 3B4..
	inc de
	add a, $16
	ld c, a
	ld b, $00
	push ix
	pop hl
	add hl, bc
	ld a, (hl)
	or a
	jr nz, _LABEL_EB9_
	ld a, (de)
	ld (hl), a
_LABEL_EB9_:
	inc de
	dec (hl)
	jp nz, label_E65
	inc de
	ret



	

_Label_EC0_15_psginit:
  ld hl, MUSICRAM+$02
  ld de, MUSICRAM+$03
  ld bc, $163
  ld (hl), $0
  ldir
  ld hl, psgInitData
  ld bc, $97F
  otir
  xor a
  ld bc, $60F0
  ld d, $20
  xor a
_Label_EDC_17:
  out (c), d
  inc d
  rst $18
  out (FM_DATA), a
  rst $18
  djnz _Label_EDC_17
  ret

psgInitData:	
; Data from $EE6 to $EEE (9 bytes)
.db $80, $00, $A0, $00, $C0, $00, $E0, $00, $FF

	
_Label_EEF_116:
  inc (ix+$B)
  ld a, (ix+$A)
  sub (ix+$B)
  call z, _Label_F11_117
  bit 4, (ix+$13)
  ret nz
  ld a, (ix+$7)
  dec a
  ret m
  ld hl, $13D6
  rst $28
  call _Label_1014_126
  or $F0
  out (PSG), a
  ret


	
_Label_F11_117:
  ld e, (ix+$3)
  ld d, (ix+$4)
label_f17_	
  ld a, (de)
  inc de
  cp $E0
  jp nc, _Label_F3B_118
  cp $80
  jp c, _Label_D67_78
  call _Label_F45_119
  ld a, (de)
  inc de
  cp $80
  jp c, _Label_D67_78
  dec de
  ld a, (ix+$15)
  ld (ix+$A), a
  jp _Label_D77_85


; Data from F37 to F3A (4 bytes)
  DEC DE    		;these two instructions are never executed?
  JP _Label_D77_85	;
	
_Label_F3B_118:
  ld hl, label_f41			
  jp _Label_DAA_75
label_f41:	
  INC DE
  JP label_f17_	


_Label_F45_119:
  bit 3, a
  jr nz, _Label_F62_120
  bit 5, a
  jr nz, _Label_F69_123
  bit 1, a
  jr nz, _Label_F69_123
  bit 0, a
  jr nz, _Label_F77_125
  bit 2, a
  jr nz, _Label_F77_125
  ld (ix+$7), $0
  ld a, $FF
  out (PSG), a
  ret

_Label_F62_120:
  ex af, af'
  ld a, $2
  ld b, $3
  jr _Label_F7C_121

_Label_F69_123:
  ld c, $4
  bit 0, a
  jr nz, _Label_F71_124
  ld c, $3
_Label_F71_124:
  ex af, af'
  ld a, c
  ld b, $5
  jr _Label_F7C_121

_Label_F77_125:
  ex af, af'
  ld a, $1
  ld b, $6
_Label_F7C_121:
  ld (ix+$7), a
  ex af, af'
  bit 2, a
  jr z, _Label_F86_122
  dec b
  dec b
_Label_F86_122:
  ld (ix+$8), b
  ret

_Label_F8A_135:
  inc (ix+$B)
  ld a, (ix+$A)
  sub (ix+$B)
  call z, _Label_D13_89
  ld (MUSICRAM+$0C), a
  cp $80
  ld a, (ix+$13)
  cp $1F
  ret z
  jr _Label_FAE_136

_Label_FA3_129:
  ld a, $1F
  ld (ix+$13), a
  add a, (ix+$1)
  out (PSG), a
  ret

_Label_FAE_136:
  cp $FF
  jp z, _Label_FC8_137
  ld a, (ix+$7)
  dec a
  jp m, _Label_FC8_137
  ld hl, $13D6
  rst $28
  call _Label_1014_126
  or (ix+$1)
  add a, $10
  out (PSG), a
_Label_FC8_137:
  ld a, (MUSICRAM+$0C)
  or a
  jp m, _Label_FDC_138
  bit 7, (ix+$14)
  ret z
  ld a, (ix+$6)
  dec a
  jp p, _Label_FE0_141
  ret

_Label_FDC_138:
  ld a, (ix+$6)
  dec a
_Label_FE0_141:
  ld l, (ix+$E)
  ld h, (ix+$F)
  jp m, _Label_FF1_139
  ex de, hl
  ld hl, $142E
  rst $28
  call _Label_CD6_104
_Label_FF1_139:
  bit 6, (ix+$0)
  ret nz
  ld a, (ix+$1)
  cp $E0
  jr nz, _Label_FFF_140
  ld a, $C0
_Label_FFF_140:
  ld c, a
  ld a, l
  and $F
  or c
  out (PSG), a
  ld a, l
  and $F0
  or h
  rrca
  rrca
  rrca
  rrca
  out (PSG), a
  ret

_Label_1011_132:
  ld (ix+$C), a
_Label_1014_126:
  push hl
  ld c, (ix+$C)
  ld b, $0
  add hl, bc
  ld c, l
  ld b, h
  pop hl
  ld a, (bc)
  bit 7, a
  jr z, _Label_1040_127
  cp $82
  jr z, _Label_1033_128
  cp $81
  jr z, _Label_103A_130
  cp $80
  jr z, _Label_1037_131
  inc bc
  ld a, (bc)
  jr _Label_1011_132

_Label_1033_128:
  pop hl
  jp _Label_FA3_129

_Label_1037_131:
  xor a
  jr _Label_1011_132

_Label_103A_130:
  ld (ix+$13), $FF
  dec bc
  ld a, (bc)
_Label_1040_127:
  inc (ix+$C)
  add a, (ix+$8)
  bit 4, a
  ret z
  ld a, $F
  ret

_Label_104C_67:
  ld a, (ix+$8)
  and $F
  or (ix+$1)
  add a, $10
  out (PSG), a
  ret

.org $1059
MUSICDATA:	
; Data from $1059 to $1FFF (4007 bytes)
	;; mostly used
.incbin "spaceHarrier1059.i"
musicdataend:	




	