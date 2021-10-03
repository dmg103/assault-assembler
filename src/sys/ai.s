;;Managers
.globl man_entity_forall_matching

;;Entity types
.globl entity_type_movable
.globl entity_type_render
.globl entity_type_ai

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the AI for all the entities matching with the signature
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_update::
    ld de, #sys_ai_update_one_entity

    ;;BC will contain the signature for the man_entity_forall_matching
    ld bc, #0x0000
    ld a, #entity_type_movable
    add a, #entity_type_render
    add a, #entity_type_ai
    ld c, a

    call man_entity_forall_matching

ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: Update the AI for one entity. Call the behaviour of the entity
;;
;; Modifies: a, de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_update_one_entity:

    ld a, #9
    call inc_hl_number          ;;HL pointing to the ai_behaviour

    ld de, #position_after_ai_behaviour
    push de

    ;;As an example, ai_behaviour is contains the function registered in C840

    ld d, (hl)                     ;;D contains C8

    inc hl

    ld e, (hl)                     ;;E contains 40

    ld a, #10
    call dec_hl_number          ;;HL pointing to the ai_behaviour

    push hl

    ld h, d
    ld l, e

    ;;As the result, DE contains C840
    ;;Having stored the position of the ai_behaviour jump into that behaviour, depending on the entity 
    jp(hl)

    position_after_ai_behaviour:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: (FIRST ON THE STACK!!) should contain the memory direction of the entity we want to update the render
;; Objetive: Update the AI with the behaviour of moving left and right.
;; Updating the vel depending on which border is the entity colliding with
;;
;; Modifies: a, b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_behaviour_left_right::

    pop hl

    inc hl                      ;;HL pointing to the entity pos_x

    ld a, #0x00    
    add a, (hl)
    jr z, on_left_border        ;;Check if the entity is on the left border

    ;;D still contains the the pos_x of the entity

    ld a, #80
    
    inc hl
    inc hl                      ;;HL pointing towards the width of the entity

    sub (hl)                    ;;Now, A contains the right_bound

    dec hl
    dec hl                      ;;HL pointing towards the pos_x of the entity

    sub (hl)                    ;;Right_bound - e->pos_x if == 0 Right_bound == e->pos_x

    jr z, on_right_border

    dec hl                      ;;HL pointing towards the entity type

    ret

    on_left_border:

    ld b, #0x01

    jr update_the_ai_vel
    on_right_border:

    ld b, #0xFF

    update_the_ai_vel:

    ld a, #0x04
    call inc_hl_number         ;;HL pointing to entity vel_x

    ld (hl), b                 ;;B contains the new vel_x

    ld a, #0x05
    call dec_hl_number         ;;HL pointing to entity type again
ret



    

