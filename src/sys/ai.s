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
;; Objetive: Update the AI for one entity.
;;
;; Modifies: a, d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_update_one_entity:

    inc hl                      ;;HL pointing to the entity pos_x

    ld d, (hl)                  ;;D contains the pos_x of the entity
    ld a, #0x00
    
    add a, d
    jr z, on_left_border        ;;Check if the entity is on the left border

    ;;D still contains the the pos_x of the entity

    ld a, #80
    
    inc hl
    inc hl                      ;;HL pointing towards the width of the entity

    ld d, (hl)                  ;;D contains the width of the entity

    sub d                       ;;A contains the right_bound

    dec hl
    dec hl                      ;;HL pointing towards the pos_x of the entity

    ld d, (hl)                  ;;D contains the pos_x of the entity

    sub d                       ;;Right_bound - e->pos_x if == 0 Right_bound == e->pos_x

    jr z, on_right_border

    dec hl                      ;;HL pointing towards the entity type

    jr ai_totally_updated

    on_left_border:

    ld a, #0x04
    call inc_hl_number         ;;HL pointing to entity vel_x

    ld (hl), #0x01

    jr hl_back_to_type
    on_right_border:

    ld a, #0x04
    call inc_hl_number         ;;HL pointing to entity vel_x

    ld (hl), #0xFF

    hl_back_to_type:

    ld a, #0x05
    call dec_hl_number          ;;HL pointing to entity type again


    ai_totally_updated:
ret

    

