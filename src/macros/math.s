.macro INCREMENT_REGISTER _register, _increment
   ld a, #_increment
   inc_register:
	  inc _register
	  dec a
   jr nz, inc_register

.endm

.macro INCREMENT_COUNTER_REGISTER _counter_register, _register, _increment
   ld _counter_register, #_increment
   inc_counter_register:
	  inc _register
	  dec a
   jr nz, inc_counter_register

.endm

.macro DECREMENT_REGISTER _register, _decrement
   ld a, #_decrement
   inc_register:
	  dec _register
	  dec a
   jr nz, inc_register

.endm

.macro DECREMENT_COUNTER_REGISTER _counter_register, _register, _decrement
   ld _counter_register, #_decrement
   dec_counter_register:
	  inc _register
	  dec a
   jr nz, dec_counter_register

.endm

;;Return Z= 1 if equals otherwise 0
.macro IS_EQUALS _n1, _n2
   
   ld a, #_n1
   ld b, #_n2

   sub b
.endm

;;Return C = 0 if _n1 higher than _n2, otherwise, 0
.macro IS_HIGHER _n1, _n2
   
   ld a, #_n1
   ld b, #_n2

   sub b

.endm

;;Return C = 0 if _n1 lower than _n2, otherwise, 0
.macro IS_LOWER _n1, _n2
   IS_HIGHER _n2, _n1
.endm