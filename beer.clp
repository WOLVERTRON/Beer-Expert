;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:	beer.clp
;;	AUTHOR:	Chris Wolverton
;;
;;	DESC:	Templates and rules for managing information on beer.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule BEER
	"BEER module contains templates and rules related to beer information." 
	(import MAIN deftemplate initial-fact)	
	(export deftemplate beer brewer save-beer)
)


;; Template(s)
;; ============================================================================

(deftemplate beer

	(multislot name
		;(type LEXEME)
		(default ?NONE)
		(cardinality 1 ?VARIABLE)
	)

	(multislot brewer
		(type SYMBOL)
	)

	(multislot style
		(type SYMBOL)
	)

	; Alcohol by Volume
	(slot abv
		(type NUMBER)
	)

	(multislot serving-temp
		(type NUMBER)
		(cardinality 2 2) ; range: 40-45
	)	

	; BASIC VERSION
	
	; Aroma
	(multislot aroma)

	; Appearance
	(multislot appearance-head)
	(multislot appearance-body)

	; Flavor
	(multislot flavor)

	; Palate
	(multislot palate)

)



(deftemplate brewer

	(multislot name
		(type SYMBOL)
		(default ?NONE)
		(cardinality 1 ?VARIABLE)
	)

	(multislot region
		(type SYMBOL)
	)

)



;; Rule(s)
;; ============================================================================

(defrule init
	"Load stored beer, brewers."
	(declare (auto-focus TRUE))

=>
	(load-facts beer.dat)
)

(defrule save
	"Save beers and brewers."
	
	?cmd <- (save-beer)
=>
	(retract ?cmd)
	(save-facts beer.dat)
)

