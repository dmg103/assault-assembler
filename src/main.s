.include "cpctelera.h.s"

.area _DATA
.area _CODE

;;Cpctelera video functions
.globl _cpct_disableFirmware

;;Managers
.globl man_game_init
.globl man_game_play

_main::
	;;Initialize cpctelera render setting
	call    _cpct_disableFirmware

	call man_game_init
	call man_game_play


	