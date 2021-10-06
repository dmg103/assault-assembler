

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Given a certain _increment, increment the _register
;; in _increment times
;;
;; Return: The _register incremented _increment times
;; Modifies: -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.macro INCREMENT_REGISTER _register, _increment

   .rept _increment
      inc _register
   .endm

.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Given a certain _decrement, decrement the _register
;; in _decrement times
;;
;; Return: The _register decremented _decrement times
;; Modifies: a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro DECREMENT_REGISTER _register, _decrement

   .rept _decrement
      inc _register
   .endm

.endm


.macro MULTIPLY _n1, _n2

   

.endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Compare if _n1 and _n2 are equals
;;
;; Return: Z = 1 if _n1, _n2 are equals, otherwise Z = 0
;; Modifies: a, b
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
;; Modifies: a, b
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
;; Modifies: a, b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro IS_LOWER _n1, _n2
   IS_HIGHER _n2, _n1
.endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pre requirements
;;  -
;; Objetive: Calculate the given number negated
;; Return: Return the number negated in the _register
;; Modifies: a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.macro NEGATE_NUMBER _n1

   ld a, #_n1
   xor #FF
   add a, #0x01

.endm