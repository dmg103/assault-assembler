.include "cpctelera.h.s"

.area DATA
.area CODE

;; manager methods
.globl man_entity_init
.globl man_entity_update
.globl man_entity_create

;; system methods
.globl sys_render_init
.globl sys_physics_update
.globl sys_render_update
.globl sys_ai_update

;;cpctelera utilities
.globl cpct_waitVSYNC_asm
.globl cpct_waitHalts_asm
.globl cpct_memcpy_asm

;;Global variables references
.globl entity_size
.globl entity_type_render
.globl entity_type_movable

;;math utils
.globl inc_de_number
.globl dec_de_number

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Sprite:
;;  - 4 width, 6 height = 24bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mothership_sprite::
    .db #0x00, #0x0F, #0x0F, #0x00 ;; TODO: Tenemos que hacer lo de la lectura de sprites, conversion y setear la paleta
    .db #0x00, #0x0F, #0x0F, #0x00
    .db #0x00, #0x0F, #0x0F, #0x00
    .db #0x00, #0x0F, #0x0F, #0x00
    .db #0x00, #0x0F, #0x0F, #0x00
    .db #0x00, #0x0F, #0x0F, #0x00

playership_sprite::
    .db #0x00, #0xFF, #0xFF, #0x00 ;; TODO: Tenemos que hacer lo de la lectura de sprites, conversion y setear la paleta
    .db #0x00, #0xFF, #0xFF, #0x00
    .db #0x00, #0xFF, #0xFF, #0x00
    .db #0x00, #0xFF, #0xFF, #0x00
    .db #0x00, #0xFF, #0xFF, #0x00
    .db #0x00, #0xFF, #0xFF, #0x00

player_sprite::
    .db #0x00, #0x88, #0x88, #0x00 ;; TODO: Tenemos que hacer lo de la lectura de sprites, conversion y setear la paleta
    .db #0x00, #0x88, #0x88, #0x00
    .db #0x00, #0x88, #0x88, #0x00
    .db #0x00, #0x88, #0x88, #0x00
    .db #0x00, #0x88, #0x88, #0x00
    .db #0x00, #0x88, #0x88, #0x00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Entity struct:
;;  - type, x, y, w, h, vx, vy, sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mothership_template::
    .db #0x0B   ;; TODO:poner como entity_type_movable | entity_type_render | entity_type_ai
    .db 38      ;; x
    .db 10      ;; y
    .db #0x04   ;; w ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x06   ;; h ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0xFF   ;; vx = -1
    .db #0x00   ;; vy = 0
    .dw mothership_sprite

playership_template::
    .db #0x01   ;; entity_type_render
    .db 0       ;; x
    .db 192     ;; y
    .db #0x04   ;; w ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x06   ;; h ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x00   ;; vx = 0 TODO: acordarme de ponerle velocidad 0
    .db #0x00   ;; vy = 0
    .dw playership_sprite

player_template::
    .db #0x07  ;; entity_type_render | entity_type_movable | entity_type_input
    .db 38      ;; x
    .db 180     ;; y
    .db #0x04   ;; w ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x06   ;; h ;;TODO: se supone que con los sprites se nos van a crear unas macros
    .db #0x00  ;; vx = 0 TODO: acordarme de ponerle velocidad 0, este se va a mover por los inputs
    .db #0x00   ;; vy = 0
    .dw player_sprite


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;MAN_GAME_WAIT 
;;Pre requirements
;;  - a: should contain the times to execute the loop
;; Objetive: make VSYNC slower
;; Modifies: a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_wait:
    ;;a contains the number of times to do this
    while_remain_halts:
        ;;TODO --> buscar que registro usa para cargar el numero de halts
        ;;call cpct_waitHalts_asm
        halt ;;placeholder
        halt ;;placeholder
        call cpct_waitVSYNC_asm
        dec a 
        jr nz, while_remain_halts
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;man_game_create_template_entity
;;Pre requirements
;;  - hl: contains the template direction to be used
;;  - bc contains the size of the entity to be created
;; Objetive: create an entity in fucntion of the template it is
;; Modifies: hl, bc, de
;; Returns: de contains the direction of the entity created
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_create_template_entity::
    ;;hl contains the template direction to be used
    ;;bc contains the size of the entity to be created
    push hl
    push bc
    call man_entity_create
    pop bc
    pop hl

    push de ;;contains the direction of the entity created
    call cpct_memcpy_asm
    pop de
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;man_game_init
;;Pre requirements
;;  -
;; Objetive: initialize all necessary entities
;; Modifies: hl, bc, de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_init::
    call man_entity_init
    call sys_render_init

    ;;creating the mothership
    ld hl, #mothership_template
    ld bc, #entity_size
    call man_game_create_template_entity


    ;;This is the scoreboard
    ;;creating the playerships
    ;;TODO: meter esto en un bucle y crear 3 playership en diferentes posiciones
    ld hl, #playership_template
    ld bc, #entity_size
    call man_game_create_template_entity

    
    ld hl, #playership_template
    ld bc, #entity_size
    call man_game_create_template_entity
    inc de
    ld a, #10
    ld (de), a
    dec de

    ld hl, #playership_template
    ld bc, #entity_size
    call man_game_create_template_entity
    inc de
    ld a, #20
    ld (de), a
    dec de


    ;;creating the player
    ld hl, #player_template
    ld bc, #entity_size
    call man_game_create_template_entity



    ret

man_game_play::
    game_loop:
        call sys_ai_update
        call sys_physics_update
        call sys_render_update
        call man_entity_update
        ;;ld a, #0x05
        ;;call man_game_wait
        call cpct_waitVSYNC_asm
    jr game_loop
    ret 