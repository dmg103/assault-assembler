.include "cpctelera.h.s"

.area _DATA

;;m_left_key:: .db #0x69
;;m_right_key:: .db #0x61

.area _CODE
.globl man_entity_forall_matching
.globl man_entity_set4destruction

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number

;;cpc_telera
.globl  cpct_scanKeyboard_f_asm
.globl cpct_isKeyPressed_asm
.globl Key_A
.globl Key_D

.globl entity_type_movable
.globl entity_type_input
.globl entity_type_render


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the physiscs
;; Objetive: Update the physics for one entity
;; Modifies: a, bc, (hl no se si lo modifica)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_update_one_entity::

    ;;Check if the entity has type input
    ld a, (hl)                  ;;Type of the entity
    ld d, #entity_type_input    ;;Type input
    and d
    jr z, entity_no_input       ;; If = 0, entity is not movable

    call sys_physics_check_input

    entity_no_input :
    ;;Now, update the x and y position

    ;;Entity->pos_x
    inc hl                      ;; hl pointing to pos_x
    ld a, (hl)                  ;; save pos_x in a

    push af

    ld a, #0x04
    call inc_hl_number          ;;hl pointing to vel_x

    pop af

    ld d, a                     ;;Save pos_x on d
    ld a, (hl)                  ;;Save vel_x on a
    add a, d                    ;; Now a contains pos_x+vel_x

    push af

    ld a, #0x04
    call dec_hl_number          ;;hl points to pos_x

    pop af

    ld (hl), a                  ;;Save newpos_x in pos_x

    ;;Entity->pos_y
    inc hl                      ;;Hl pointing to entity vel_y
    ld a, (hl)                  ;; Save pos_y on a

    push af

    ld a, #0x04
    call inc_hl_number

    pop af

    ld d, a                        ;;Saving pos_y on d
    ld a, (hl)                     ;;Saving vel_y on a
    add a, d                       ;;Now a contains e->pos_y + e->vel_y

    push af

    ld a, #0x04
    call dec_hl_number              ;;Hl pointing to entity pos_y

    pop af

    ld (hl), a                      ;;Save newpos_y in pos_y

    ld a, #0x02
    call dec_hl_number              ;;hl points to the beginning of the entity
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the input
;; Objetive: Check if a key is pressed
;; Modifies: AF, BC, DE, HL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_check_input::
    push hl ;;save hl in the stack
    call cpct_scanKeyboard_f_asm

    ;;Check if left_key is pressed
    ld hl, #Key_A
    call cpct_isKeyPressed_asm
    jr  nz, left_key_pressed

    ;;Check if right_key is pressed
    ld hl, #Key_D
    call cpct_isKeyPressed_asm
    jr  nz, right_key_pressed

    ;;No key is pressed
    ld b, #0x00
    jr end_check_keyboard

    left_key_pressed:
    ld b, #0xFF
    jr end_check_keyboard
    right_key_pressed:
    ld b, #0x01

    end_check_keyboard:
    pop hl
    ld a, #0x05
    call inc_hl_number
    ld (hl), b

    ;;return hl to the beginning of the pointer
    ld a, #0x05
    call dec_hl_number

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the physics for all the entities matching
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_update::
    ld de, #sys_physics_update_one_entity
    
    ;;bc will contain the signature
    ld bc, #0x0000

    ld a, #entity_type_movable
    add a, #entity_type_render
    ld c, a

    call man_entity_forall_matching

ret