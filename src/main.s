.include "macros/math.s"
.include "cpctelera.h.s"

.area _DATA
.area _CODE

;;Cpctelera video functions
.globl _cpct_disableFirmware

;;Managers
;;.globl man_game_init
;;.globl man_game_play

_main::
	
	ld hl, #0x00
	ld a, #0x00

	;;.rept #5
	;;	inc hl
	;;.endm

	jr .
	
	
	;;Initialize cpctelera render setting
	;;call    _cpct_disableFirmware

	;;call man_game_init
	;;call man_game_play


	