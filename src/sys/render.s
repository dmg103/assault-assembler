.globl _cpct_setPALColour
.globl _cpct_setVideoMode
.globl cpct_getScreenPtr_asm
.globl cpct_drawSprite_asm
.globl cpct_setPalette_asm

.globl man_entity_forall_matching

;;States of an entity
.globl entity_type_dead
.globl entity_type_render
.globl entity_type_controllable

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

	ld hl, #0x1400
	push    hl 
	call	_cpct_setPALColour

    ;;ld hl,  #_main_pal
    ;;ld de,  #16
    ;;call    cpct_setPalette_asm

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the render for all the entities matching with the signature
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_render_update::
    ld de, #sys_render_one_entity

    ;;BC will contain the signature for the man_entity_forall_matching
    ld bc, #0x0000
    ld a, #entity_type_render
    ld c, a

    call man_entity_forall_matching
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: Update the render for one entity
;; Modifies: a, bc, de, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_render_one_entity:

    ;;Check if the entity is dead
    ld a, (hl)
    ld b, #entity_type_dead

    and b

    jr nz, entity_dead_no_render

    ;;Getting in HL the screen memory location to draw 
    ld de, #0xC000

    inc hl
    ld a, (hl)
    ld c, a

    inc hl
    ld a, (hl)
    ld b, a

    dec hl
    dec hl

    push hl

    call cpct_getScreenPtr_asm

    ;;Drawing the sprite

    ;;DE will contain the screen memory location to draw
    ld d, h
    ld e, l

    ;;Recovering hl that is pointing towards the entity
    pop hl

    ;;C should contain the width of the sprite and B the height
    ld a, #0x03
    call inc_hl_number

    ld c, (hl)

    inc hl
    ld b, (hl)

    ;;HL should point towards the entity sprite
    ld a, #0x03
    call inc_hl_number

    push hl

    push bc

    ld b, h
    ld c, l

    ld a, (bc)
    ld l, a

    inc bc
    ld a, (bc)
    ld h, a

    pop bc

    call cpct_drawSprite_asm

    pop hl

    ;;After the drawing, hl should return to his original direction memory
    ld a, #0x07
    call dec_hl_number
    entity_dead_no_render:
ret