.include "cpctelera.h.s"

.area _DATA

;;m_left_key:: .db #0x69
;;m_right_key:: .db #0x61

.area _CODE
.globl man_entity_forall_matching

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number

.globl entity_type_movable
.globl entity_type_render
.globl entity_type_ai


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the ai
;; Objetive: Update the ai for one entity
;; Modifies: a, bc, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_update_one_entity::
    ;;right_bound = 80 - e->w
    ld a, #0x03
    call inc_hl_number ;;hl points to the w

    ld a, #0x50        ;;loads 80(dec) to a
    sub (hl)           ;;80 - w

    push af             ;;a contains righ_bound

    ;;if( e-> w == 0) e -> vx = 1
    ld a, #0x00
    dec hl
    dec hl              ;;hl points to pos_x
    sub (hl)
    jr z, right_collision

    ;;else if(e->x == right-bound) e -> vx = -1
    pop af
    sub (hl)
    jr z, left_collision

    ;;else, nothing happens
    jr end_ai_update

    right_collision:
    pop af
    ld b, #0x01
    jr apply_ai_update

    left_collision:
    ld b, #0xFF

    apply_ai_update:
    ;;set vel_x
    ld a, #0x04
    call inc_hl_number
    ld (hl), b

    end_ai_update:
    ;;return hl to the beginning of the entity
    ld a, #0x05
    call dec_hl_number
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the ai for all the entities matching
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_update::
    ld de, #sys_ai_update_one_entity
    
    ;;bc will contain the signature
    ld bc, #0x0000

    ld a, #entity_type_movable
    add a, #entity_type_render
    add a, #entity_type_ai
    ld c, a

    call man_entity_forall_matching

ret