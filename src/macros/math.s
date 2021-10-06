;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Given a certain _increment, increment the _register
;; in _increment times
;;
;; Return: The _register incremented _increment times
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.macro INCREMENT_REGISTER _register, _increment
   ld a, #_increment
   inc_register:
	  inc _register
	  dec a
   jr nz, inc_register

.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Given a certain _increment, increment the _register
;; in _increment times. The register used for the increment loop
;; is _counter_register
;;
;; Return: The _register incremented _increment times
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro INCREMENT_COUNTER_REGISTER _counter_register, _register, _increment
   ld _counter_register, #_increment
   inc_counter_register:
	  inc _register
	  dec a
   jr nz, inc_counter_register

.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Given a certain _decrement, decrement the _register
;; in _decrement times
;;
;; Return: The _register decremented _decrement times
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro DECREMENT_REGISTER _register, _decrement
   ld a, #_decrement
   inc_register:
	  dec _register
	  dec a
   jr nz, inc_register

.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Given a certain _decrement, decrement the _register
;; in _decrement times. The register used for the decrement loop
;; is _counter_register
;;
;; Return: The _register decremented _decrement times
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro DECREMENT_COUNTER_REGISTER _counter_register, _register, _decrement
   ld _counter_register, #_decrement
   dec_counter_register:
	  inc _register
	  dec a
   jr nz, dec_counter_register

.endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Compare if _n1 and _n2 are equals
;;
;; Return: Z = 1 if _n1, _n2 are equals, otherwise Z = 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro IS_EQUALS _n1, _n2
   
   ld a, #_n1
   ld b, #_n2

   sub b
.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Compare if _n1 >  _n2
;;
;; Return: C = 0 if _n1, > _n2, otherwise Z = 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro IS_HIGHER _n1, _n2
   
   ld a, #_n1
   ld b, #_n2

   sub b

.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Compare if _n1 < _n2
;;
;; Return: C = 0 if _n1, < _n2, otherwise Z = 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro IS_LOWER _n1, _n2
   IS_HIGHER _n2, _n1
.endm