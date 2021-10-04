;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GLOBL INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.globl man_entity_forall_matching

;;Entity types
.globl entity_type_animated
.globl entity_type_render

;Math utilities
.globl inc_hl_number
.globl inc_de_number
.globl dec_hl_number
.globl dec_de_number

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the physics for all the entities matching with the signature
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_animation_update::
	ld de, #sys_animation_update_one_entity

	;;BC will contain the signature for the man_entity_forall_matching
	ld bc, #0x0000
	ld a, #entity_type_animated
	add a, #entity_type_render
	ld c, a

	call man_entity_forall_matching

ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: Update the physics for one entity.
;;
;; Modifies: a, d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys_animation_update_one_entity:

	ld a, #13
	call inc_hl_number                      ;;HL pointing to the anim counter

	ld a, (hl)
	dec a

	ld (hl), a                             ;;Updating the anim_counter
	
	jr z, animation_should_change 

	ld a, #13
	call dec_hl_number                      ;;HL pointing to the anim counter

	ret
	animation_should_change:

	   ld a, #0x02
	   call dec_hl_number                  ;;HL pointing to the first byte of _anim (-->DB 41)

	   ;;Saving into de the pos of the current _anim
	   ld e, (hl)
	   inc hl
	   ld d, (hl)
	   dec hl

	   ld a, #0x03
	   call inc_de_number

	   ld (hl), e 

	   inc hl

	   ld (hl), d

	;;Check if the next anim we are pointing now with DE has time == 0

	ld a, (de)

	add a, #0x00

	jr nz, no_cycle_ended

	inc de							;;DE pointing to the anim which has the anim_counter set to 0
	inc de

	ld a, (de)

	ld (hl), a

	dec de
	dec hl

	ld a, (de)

	ld (hl), a

	inc hl

	no_cycle_ended:

	ld a, #5
	call dec_hl_number

ret