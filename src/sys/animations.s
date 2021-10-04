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

    ret
    animation_should_change:

        ld a, #0x02
        call dec_hl_number              ;;HL pointing to the first byte of the _anim

        ;;++ e->anim

        ld e, (hl)
        inc hl                        
        ld d, (hl)
        dec hl

        ;;Now, DE is pointing to the value of HL, in this case is the memory direction for entity _anim
        ld a, #0x04
        call inc_de_number

        ld a, e 

        ld (hl), a               

        inc hl

        ld a, d

        ld (hl), a

        ;;After this, the entity anim memory direction is pointing to the next sprite

        dec de
        ld a, (de)

        add a, #0x00

        dec hl

        jr nz, no_reset_cycle_animation

        ;;In case Z is activated, we need to reset de anim, HL is still pointing to the _anim

        ;;ld (hl), a

        ;;inc hl

        ;;ld (hl), a


        no_reset_cycle_animation:

        ;;HL is still pointing to the _anim

        ld d, h
        ld e, l                                 ;;DE pointing to the first byte of _anim

        ld a, #0x04
        call dec_hl_number                      ;;HL pointing to first byte of _sprite                 

        ;;Me estoy liando con punteros y values mirar esto

        ;;e->sprite = e->anim->val.sprite
        ld a, (de)

        ld (hl), a

        inc de
        inc hl

        ld a, (de)

        ld (hl), a



        

ret