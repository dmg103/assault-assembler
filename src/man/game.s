;;Cpctelera video functions
.globl cpct_waitVSYNC_asm
.globl cpct_memcpy_asm
.globl cpct_memset_asm

;;Managers
.globl man_entity_init
.globl man_entity_update
.globl man_entity_create

;;Systems
.globl sys_physics_update
.globl sys_render_init
.globl sys_render_update
.globl sys_ai_update

;;AI behaviour functions
.globl sys_ai_behaviour_left_right
.globl sys_ai_behaviour_mothership

.globl entity_size

;Math utilities
.globl inc_hl_number
.globl dec_hl_number

;;Macro for creation of entity templates _
.macro DEFINE_ENTITY_TEMPLATE _name, _type, _pos_x, _pos_y, _width, _height, _vel_x, _vel_y, _sprite, _ai_behaviour
_name:
    .db _type           ; type -> e_type_movable | e_type_render | e_type_ai
    .db _pos_x          ; pos_x
    .db _pos_y          ; pos_y
    .db _width          ; width  ;; TODO: This should change using the variables of sprites
    .db _height         ; height  ;; TODO: This should change using the variables of sprites
    .db _vel_x          ; vel_x
    .db _vel_y          ; vel_y
    .dw _sprite         ; sprite TODO: We should include the sprite generated and change this
    .dw _ai_behaviour   ;ai_behaviour (The memory direction for the function behaviour of the AI)
.endm


;; Just to know how our entities are created

;;The sprite is 4 bytes width, 6 bytesub height, so 24 bytes
m_sprite: .ds 30

m_sprite_size = 30

m_sprite_mothership:
        .db #0x00, #0xFF, #0xFF, #0xFF, #0x00
        .db #0x00, #0xFF, #0xFF, #0xFF, #0x00
        .db #0x00, #0xFF, #0xFF, #0xFF, #0x00
        .db #0x00, #0xFF, #0xFF, #0xFF, #0x00
        .db #0x00, #0xFF, #0xFF, #0xFF, #0x00
        .db #0x00, #0xFF, #0xFF, #0xFF, #0x00

DEFINE_ENTITY_TEMPLATE mothership_tmpl,        11, 38,  10, 5, 6, -1, 0, m_sprite, #sys_ai_behaviour_mothership
DEFINE_ENTITY_TEMPLATE playership_tmpl,        7, 38, 180, 5, 6,  0, 0, m_sprite, 0x0000
DEFINE_ENTITY_TEMPLATE playership_lifes_tmpl,  1,  0, 192, 5, 6,  0, 0, m_sprite, 0x0000
DEFINE_ENTITY_TEMPLATE enemy1_tmpl,            11, 0, 40, 5, 6, 0, 0, m_sprite, #sys_ai_behaviour_left_right

m_enemy_on_lane: .db #0x00

man_game_init::
    call man_entity_init
	call sys_render_init

    ;;Filling the sprite[] with  #0xFF
    ld de, #m_sprite
    ld hl, #m_sprite_mothership
    ld bc, #m_sprite_size

    call cpct_memcpy_asm

    ;;Once our sprite is set up, create the entities

    ;;Mothership
    ld hl, #mothership_tmpl
    call man_game_create_template_entity

    ;;Player
    ld hl, #playership_tmpl
    call man_game_create_template_entity


    ;;TODO: This from here
    ld hl, #playership_lifes_tmpl
    call man_game_create_template_entity

    inc de
    ld a, #20
    ld (de), a
    dec de 


    ld hl, #playership_lifes_tmpl
    call man_game_create_template_entity

    inc de
    ld a, #10
    ld (de), a
    dec de 


    ld hl, #playership_lifes_tmpl
    call man_game_create_template_entity
    ;;To here should be changed for a loop
ret
man_game_play::
    game_loop:

    call sys_ai_update
	call sys_physics_update
	call sys_render_update
	call man_entity_update
	call cpct_waitVSYNC_asm

    jr game_loop
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction for the template to by created
;; Objetive: Creates an entity given a template
;; Modifies: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_create_template_entity:

    push hl

    call man_entity_create

    pop hl

    ;;HL contains the template, DE conntais the memory direction and BC the size
    ld bc, #entity_size

    ;;We want to keep the value of DE
    push de

    call cpct_memcpy_asm

    pop de
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - HL: should contain the memory direction of the AI entity that
;;        execute this function, in this case the MotherShip
;; Objetive: Creates an entity given a template
;; Modifies: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_create_enemy::

    push hl

    ld a, #0x01
    ld de, (#m_enemy_on_lane)
    ld d, #0x00
    and e

    jr z, enemy_not_on_lane

    ret
    enemy_not_on_lane:

        ld hl, #enemy1_tmpl
        call man_game_create_template_entity

        pop hl

        ;;DE contains the direction memory of the new enemy created

        ;;The enemy pos_x = mothership-> pos_x + 4 
        inc hl
        ld a, (hl)
        add a, #0x04

        ld (de), a

        ;;The enemy vel_x = mothership-> vel_x
        ld a, #0x04
        call inc_hl_number

        ld a, (hl)
        ld (de), a

        ld a, #0x05
        call dec_hl_number

    ld a, #0x01
    ld (#m_enemy_on_lane), a

    
ret
