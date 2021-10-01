;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This class contains a number of utility functions related to math
;; As inc, dec for different registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All the inc and dec functions: Pre requirements
;; - A: should contain how much we want inc/dec a register
;; - Modify: A and the register of the function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inc_bc_number::
    ibn:
    inc bc
    dec a
    jr nz, ibn

ret

inc_de_number::
    idn:
    inc de
    dec a
    jr nz, idn


ret

inc_hl_number::
    ihn:
    inc hl
    dec a
    jr nz, ihn


ret

inc_sp_number::
    isn:
    inc sp
    dec a
    jr nz, isn


ret

inc_ix_number::
    ixn:
    inc ix
    dec a
    jr nz, ixn


ret

dec_bc_number::
    dbn:
    dec bc
    dec a
    jr nz, dbn

ret

dec_de_number::
    ddn:
    dec de
    dec a
    jr nz, ddn


ret

dec_hl_number::
    dhn:
    dec hl
    dec a
    jr nz, dhn


ret

dec_sp_number::
    dsn:
    dec sp
    dec a
    jr nz, dsn


ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;; - IX: should contain how much we want inc/dec a register
;; - Modify: IX and the register of the function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dec_a_number::
    dan:
    dec a
    dec ix
    jr nz, dan
ret







