
.globl cpct_memset_asm
.globl cpct_memcpy_asm

;;Maths utilities
.globl inc_hl_number
.globl dec_bc_number

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; """""Variables""""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
m_entities: .ds 110                     ;;Reserved memory for the entities array
m_zero_type_at_the_end: .db #0x00       ;;Trick for stop the loop of entities, positioned
max_entities: .db 10                    ;;Num of maximum entities
m_next_free_entity: .ds 2               ;;Reserved memory for the pointer of the next free entity
m_num_entities: .db 0                   ;;Current number of entities
m_function_given_forall: .dw #0x0000    ;;Memory direction of the function that we want to execute

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global constant variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
entity_size                 = 11            ;;Total size of one entity
entities_total_size         = 108           ;;Total size of the array of entites
entity_type_invalid         = 0x00          ;;Invalid entity type
entity_type_render          = 0x01          ;;Renderable entity
entity_type_movable         = 0x02          ;;Movable entity
entity_type_controllable    = 0x04          ;;Entity controllable by input
entity_type_ai              = 0x08          ;;Entity controllabe by AI
entity_type_dead            = 0x80          ;;Upper bit signals dead entity
entity_type_default         = 0x7F         ;;Default entity (all bits = 1 but the one to signal dead)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Initialize the entities establishing their values to 0
;; Also m_next_free_entity points to the first free entity to write
;;
;; Modifies: de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_entity_init::

    ;;Filling up with zeros
    ld de, #m_entities
    ld a, #0x00 
    ld bc, #entities_total_size

    call cpct_memset_asm
    
    ;;Next free entity should point towards m_entities
    ld hl, #m_entities
    ld (m_next_free_entity), hl
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Create a new entity, increase the number of entities
;; and update the next_free_entity
;;
;; Modifies: de, bc, hl
;;
;; Returns: In de, returns the direction of the entity created
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
man_entity_create::
    ;;Saving the next free memory direction of m_entities into de
    ld de, (m_next_free_entity)

    ld bc, #entity_size
    ld hl, (m_next_free_entity)

    ;;Used to not modify a
    push af

    ;;Increase the num of entities 
    ld a, (m_num_entities)
    inc a
    ld (m_num_entities), a

    pop af

    add hl, bc
    ld (m_next_free_entity), hl
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - de: should contain the memory direction for the given function to be called
;;  - bc: should contain the signature to know if we should exec the function or not
;;        BC SHOULD BE INTO THE STACK
;;  - SIGNATURE: (the group of bytes activated as 1 to know if we should exec the function)
;;  - Example: (SIGNATURE = 0000 0011 --> this means the entity is renderable and movable,
;;              if the entity match those settings the function will be executed)
;;
;; Objetive: For all the entities, execute the function given by the systems
;; if the type of the entity is the same as the signature
;;
;; Modifies: (Probably almost all the entities)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
man_entity_forall_matching::
    ld hl, #m_entities
    ;;Keeping the function adress in a variable to use it.
    ld (m_function_given_forall), de

    ld de, (#max_entities)
    ld d, #0x00
        repeat_man_entity_forall:

        ;;Compare against type_invalid to know if we should continue looping
        ld a, (hl)
        add a, #0x00 
        jr z, entity_no_valid

        ;;Check if the type of the entity is the same as the signature
        ld a, (hl)
        and c                           ;;A contains now the result of entity->type & signature

        ;;If the signature is the same as the entity type, the result of entity->type - signature = 0
        sub c

        jr nz, entity_no_matching_signature

        ;;In case the signature is the same, we want to keep bc without any change
        push bc         

        ;;Call the funcion given registered in m_function_given_forall
		ld ix, #position_after_function_given
		push ix

		ld ix, (#m_function_given_forall)
		jp (ix)
        
		position_after_function_given:

        pop bc

        entity_no_matching_signature:
        ;;Add entity_size to hl to move to the reach the next entity available
        ld a, #entity_size
        call inc_hl_number

        ;;Decrement a to loop among the entities
        dec e
    jr nz, repeat_man_entity_forall
    entity_no_valid:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Updates the entities by destroying all marked entities as dead
;;
;; Modifies: a, b, de, (no se si hl pq casi siempre la reseteamos)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
man_entity_update::
    ld hl, #m_entities

    ;;Looping through all the actives entities
    ld de, (#max_entities)
    ld d, #0x00
    repeat_man_entity_update:

        ;;Compare against type to know if we should continue looping -->TODO: creo que si quito este bucle igual deberia funcionar igual
        ld a, (hl)
        add a, #0x00 
        jr z, no_update_entity_no_valid

        ;;Check if the entity is marked as dead
        ld a, (hl)
        ld b, #entity_type_dead
        and b
        jr nz, destroy_dead_entity

        ;;Increasing in entity_size to reach the next entity position
        ld a, #entity_size
        call inc_hl_number
        
        jr continue

        destroy_dead_entity:
            push de
            call man_entity_destroy
            pop de
        continue:
        dec e
    jr nz, repeat_man_entity_update

    no_update_entity_no_valid:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - hl: should contain the memory direction for the entity
;;
;; Objetive: Set the type of the entity as dead
;;
;; Modifies: a, b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
man_entity_set4destruction::
    ld a, (hl)
    ld b, #entity_type_dead

    or b

    ld (hl), a
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - hl: should contain the memory direction for the entity

;; Objetive: Mark the dead entity as invalid and copy the last entity
;; into the dead entity memory position, also updates the m_next_free_entity
;; pointer

;; Modifies: a, bc
;; Returns: The number of free spaces in the A register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
man_entity_destroy:

    ;;Hl wiil contain the direction of the entity to be destroyed entity

    ;;Bc will contain the direction of the last available entity

    ld bc, (#m_next_free_entity)

    ld a, #entity_size
    call dec_bc_number

    ;;Compare if bc and hl are the same
    ld a, c

    ;;If this is = 0, the pointers are pointing to the same direction
    sub l
    jr z, no_copy_memory

    ;;Saving hl in the stack
    push hl

    ;;Coping memory in the free entity array space cause we destroy one entity
    ld d, h
    ld e, l
    ld h, b
    ld l, c

    ;;Saving bc in the stack
    push bc
    ld bc, #entity_size

    call cpct_memcpy_asm

    pop hl
    pop bc

    no_copy_memory:
        ;;Marked as invalid
        ld a, #entity_type_invalid
        ld (hl), a

        ;;Next free entity pointing to the last available position
        ld (m_next_free_entity), hl

        ;;Decrease m_num_entities --> m_num_entities - 1
        ld a, (m_num_entities)
        dec a
        ld (m_num_entities), a
    
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  - 
;; Objetive: Calculates how many spaces available are to create a new entity
;;
;; Modifies: a, bc
;;
;; Returns: The number of free spaces in the A register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
man_entity_free_space::
    ld a, (#max_entities)
    ld bc, (#m_num_entities)
    ld b, #0x00

    sub c
ret




