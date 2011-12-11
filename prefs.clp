;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  FILE:   prefs.clp
;;  AUTHOR: Chris Wolverton
;;
;;  DESC:   Templates and rules for managing user preferences.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule PREFS
	"PREFS module contains templates and rules related to user preferences."
	(import MAIN deftemplate initial-fact)
	(export	deftemplate pref)
)


;; Template(s)
;; ============================================================================

(deftemplate PREFS::pref

	(slot category
		(type SYMBOL)
	)

	(multislot user
		(type SYMBOL)
		(default ?NONE)
		(cardinality 1 ?VARIABLE)
	)

	(slot property
		(type SYMBOL)
		(default ?NONE)
	)

	(slot rating
		(type INTEGER)
	)

)


;; Rule(s)
;; ============================================================================

(defrule PREFS::init
	"Load stored user preferences."
	(declare (auto-focus TRUE)
)
=>
	(load-facts prefs.dat)
)

(defrule PREFS::save
	"Save user preferences."
	?cmd <- (save-prefs)
	
=>
	(retract ?cmd)
	(save-facts prefs.dat)
)
