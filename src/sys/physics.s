.globl man_entity_forall
.globl man_entity_set4destruction

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the physics for all the entities
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_update::
    ld de, #sys_physics_update_one_entity
    call man_entity_forall

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: Update the render for one entity
;; Modifies: a, bc, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_update_one_entity::
    ;;B is the current entity pos_x
    inc hl
    ld b, (hl)

    ;;C is the current entity vel_x
    ld a, #0x04
    call inc_hl_number

    ld c, (hl)

    ;;Pos_x + Vel_x to know the new position of the entity
    ld a, #0x00
    add a, b
    add a, c

    push af

    sub b
    ;;If the sum causes zero in a, the entity should be destroyed
    jr nc, destroy_entity

    ;;Coming back to the pos_x memory direction fo the entity to modify it
    ld a, #0x04
    call dec_hl_number

    pop af

    ld (hl), a 

    dec hl

    jr no_zero
    
    destroy_entity:
        pop af

        ld a, #0x05
        call dec_hl_number

        call man_entity_set4destruction
    no_zero:

ret