.include "cpctelera.h.s"

.area _DATA
.area _CODE

;;cpct utils
.globl _cpct_setPALColour
.globl _cpct_setVideoMode
.globl _cpct_setPalette
.globl cpct_setPalette_asm
.globl cpct_getScreenPtr_asm
.globl cpct_drawSprite_asm

;sprite color palette
.globl _main_palette

;; man methods
.globl man_entity_forall_matching

;;States of an entity
.globl entity_type_dead
.globl entity_type_render

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Initialize cpctelera render and screen settings
;; Modifies: Probably all the registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_render_init::
	ld l, #0x00
   	call	_cpct_setVideoMode

	;;set border
	ld hl, #0x1410
	push    hl 
	call	_cpct_setPALColour

    ld hl,  #_main_palette
    ld de,  #16
    call    cpct_setPalette_asm
ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: Update the render for one entity
;; Modifies: a, bc, de, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_render_one_entity:
    ;;Now, we should check if the start is dead, hl is pointing to the beginning of the entity

    ;;Type of the star
    ld a, (hl)           
    ld b, #entity_type_dead 

    and b
    
    jr nz, star_dead_no_render

    ;;The star is alive, we should render it
    ld de, #0xC000

    inc hl
    ld c, (hl)
    inc hl
    ld b, (hl)

    dec hl
    dec hl

    push hl

    call cpct_getScreenPtr_asm
    
    ;;Save in bc pvmem
    ld c, l
    ld b, h

    ;;point hl to the beginning of the entity
    pop hl
    push hl

    ;;We are going to get the pvmem, w, h, sprite
    ld e, c
    ld d, b
    push de

    inc hl
    inc hl
    inc hl
    ld c, (hl) ;; load in c --> width
    inc hl
    ld b, (hl) ;; load in b --> height
    inc hl
    inc hl
    inc hl ;; points to the 2 lower bytes of the direction of the sprite
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld l, e ;; save th direction fo the sprite in hl
    ld h, d

    pop de ;;de contains the pvmem again

    call cpct_drawSprite_asm

    pop hl ;;hl points to the beginnign of the entity

    star_dead_no_render:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the render for all the entities
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_render_update::
    ld de, #sys_render_one_entity
    ;;bc contains the signature
    ld bc, #0x0000
    ld c, #entity_type_render
    call man_entity_forall_matching
ret