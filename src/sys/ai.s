;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GLOBL INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Managers
.globl man_entity_forall_matching
.globl man_game_create_enemy

;;Entity types
.globl entity_type_movable
.globl entity_type_render
.globl entity_type_ai

;;Maths utilities
.globl inc_hl_number
.globl dec_hl_number
.globl dec_de_number


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

m_ai_behaviour: .dw #0x0000


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

    ld e, (hl)                     ;;D contains 40

    inc hl

    ld d, (hl)                     ;;E contains C8

    ld a, #10
    call dec_hl_number          ;;HL pointing to the ai_behaviour

    ld (m_ai_behaviour), de

    ld ix, (#m_ai_behaviour)
    ;;As the result, DE contains C840
    ;;Having stored the position of the ai_behaviour jump into that behaviour, depending on the entity 
    jp(ix)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: (FIRST ON THE STACK!!) should contain the memory direction of the entity we want to update the render
;; Objetive: Update the AI with the behaviour of moving left and right.
;; Updating the vel depending on which border is the entity colliding with
;;
;; Modifies: a, b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_ai_behaviour_mothership::

    inc hl 

    ld d, #0x00
    ld e, (hl)

    dec hl

    ;;Check if the pos_x is == 20, if pos_x & 20 == 0 -> create enemy
    ld a, #20
    call dec_de_number

    ld a, e
    add a, #0x00

    ;;This check is wrong im retard
    jr nz, no_create_enemy 

    call man_game_create_enemy
    
    no_create_enemy:

    ;;We cant use call cause that would cause another value into the stack, and that is absolutely wrong here
    call sys_ai_behaviour_left_right
ret 
    

