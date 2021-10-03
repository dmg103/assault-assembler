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

.globl entity_size

;; Just to know how our entities are created

;;The sprite is 4 bytes width, 6 bytesub height, so 24 bytes
m_sprite: .ds 30

m_sprite_size = 30

m_sprite_mothership:
        .db #0x00
        .db #0xFF
        .db #0xFF
        .db #0xFF
        .db #0x00
        .db #0x00
        .db #0xFF
        .db #0xFF
        .db #0xFF
        .db #0x00
        .db #0x00
        .db #0xFF
        .db #0xFF
        .db #0xFF
        .db #0x00
        .db #0x00
        .db #0xFF
        .db #0xFF
        .db #0xFF
        .db #0x00
        .db #0x00
        .db #0xFF
        .db #0xFF
        .db #0xFF
        .db #0x00
        .db #0x00
        .db #0xFF
        .db #0xFF
        .db #0xFF
        .db #0x00
        

mothership_tmpl:
	.db 11	    ; type -> e_type_movable | e_type_render | e_type_ai
	.db 38	    ; pos_x
	.db 10	    ; pos_y
	.db 5       ; width  ;; TODO: This should change using the variables of sprites
	.db 6       ; height  ;; TODO: This should change using the variables of sprites
	.db -1	    ; vel_x
	.db 0       ; vel_y
	.dw m_sprite;sprite  ;; TODO: We should include the sprite generated and change this

playership_tmpl:
	.db 7	    ; type -> e_type_movable | e_type_render | e_type_controllable
	.db 38	    ; pos_x
	.db 180	    ; pos_y
	.db 5       ; width  ;; TODO: This should change using the variables of sprites
	.db 6       ; height  ;; TODO: This should change using the variables of sprites
	.db 0	    ; vel_x
	.db 0       ; vel_y
	.dw m_sprite;sprite  ;; TODO: We should include the sprite generated and change this

playership_lifes_tmpl:
	.db 1	    ; type -> e_type_render
	.db 0	    ; pos_x
	.db 192	    ; pos_y
	.db 5       ; width  ;; TODO: This should change using the variables of sprites
	.db 6       ; height  ;; TODO: This should change using the variables of sprites
	.db 0	    ; vel_x
	.db 0       ; vel_y
	.dw m_sprite;sprite  ;; TODO: We should include the sprite generated and change this



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