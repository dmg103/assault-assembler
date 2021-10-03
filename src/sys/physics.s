;;Cpctelera functions
.globl cpct_scanKeyboard_f_asm
.globl cpct_isKeyPressed_asm
.globl Key_D
.globl Key_A

.globl man_entity_forall_matching
.globl man_entity_set4destruction

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number

;;Entity types
.globl entity_type_movable
.globl entity_type_render
.globl entity_type_controllable

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Update the physics for all the entities matching with the signature
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_update::
    ld de, #sys_physics_update_one_entity

    ;;BC will contain the signature for the man_entity_forall_matching
    ld bc, #0x0000
    ld a, #entity_type_movable
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
sys_physics_update_one_entity:
    
    ld a, (hl)                          ;;Type of the entity
    ld d, #entity_type_controllable     ;;Type entity_controllable

    and d

    ;;If = 0 the entity isnt controllable
    jr z, entity_no_controllable

    ;;Otherwise, entity is controllable

    call sys_physics_check_keyboard

    entity_no_controllable:
    
    ;;Now, update the x and y position

    ;;Entity->pos_x
    inc hl                             ;;Hl pointing to entity pos_x
    ld a, (hl)                         ;;Saving pos_x on a

    push af

    ld a, #0x04
    call inc_hl_number                 ;;Hl pointing to entity vel_x

    pop af

    ld d, a                            ;;Saving pos_x on d
    ld a, (hl)                         ;;Saving vel_x on a

    add a, d                           ;;Now a contains e->pos_x + e->vel_x

    push af

    ld a, #0x04
    call dec_hl_number                 ;;Hl pointing to entity pos_x

    pop af

    ld (hl), a

    ;;Entity->pos_y
    inc hl                             ;;Hl pointing to entity pos_y
    ld a, (hl)                         ;;Saving pos_y on a

    push af

    ld a, #0x04
    call inc_hl_number                 ;;Hl pointing to entity vel_y

    pop af

    ld d, a                            ;;Saving pos_y on d
    ld a, (hl)                         ;;Saving vel_y on a

    add a, d                           ;;Now a contains e->pos_y + e->vel_y

    push af

    ld a, #0x04
    call dec_hl_number                 ;;Hl pointing to entity pos_y

    pop af

    ld (hl), a

    ;;At the end, hl should be pointing towards the entity memory direction again

    ld a, #0x02
    call dec_hl_number                 ;;Hl pointing to entity type

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the entity we want to update the render
;; Objetive: In case the entity is controllable type, check if the keyboard keys are pressed
;; to change the entity velocity
;;
;; Modifies: probably all the registers but not HL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_physics_check_keyboard:
    
    push hl

    ;;Scanning the keyboard
    call cpct_scanKeyboard_f_asm

    pop hl

    ld a, #0x05                         ;;HL is pointing to the entity type
    call inc_hl_number                  ;;Now, HL is pointing to the entity vel_x

    push hl                             ;;Saving hl into the stack

    ld hl, #Key_A                        ;;Key_A
    call cpct_isKeyPressed_asm

    jr nz, a_is_pressed

    ld hl, #Key_D                       ;;Key_D
    call cpct_isKeyPressed_asm

    jr nz, d_is_pressed                 

    ;;In case a and d werent pressed
    pop hl
    ld a, #0x00
    ld (hl), a

    jr final_check_keyboard

    a_is_pressed:

    pop hl
    ld a, #0xFF
    ld (hl), a

    jr final_check_keyboard

    d_is_pressed:

    pop hl
    ld a, #0x01
    ld (hl), a
    final_check_keyboard:

    ld a, #0x05                         ;;HL is pointing to the vel_x 
    call dec_hl_number                  ;;Now, HL is pointing to the entity type
ret