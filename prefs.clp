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
	(export	deftemplate pref save-prefs)
)


;; Template(s)
;; ============================================================================

(deftemplate pref

	(slot category
		(type SYMBOL)
	)

	(slot user
		(type STRING)
		(default ?NONE)
	)

	(multislot property
		(type SYMBOL)
		(default ?NONE)
	)

	(slot rating
		(type SYMBOL)
	)

)


;; Rule(s)
;; ============================================================================

(defrule init
	"Load stored user preferences."
	(declare (auto-focus TRUE)
)
=>
	(load-facts prefs.dat)
)

(defrule save
	"Save user preferences."
	?cmd <- (save-prefs)
	
=>
	(retract ?cmd)
	(save-facts prefs.dat)
)
