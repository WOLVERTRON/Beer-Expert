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
	(export deftemplate beer)
	(export deftemplate brewer)
)


;; Template(s)
;; ============================================================================

(deftemplate BEER::beer

	(multislot name
		(type SYMBOL)
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



(deftemplate BEER::brewer

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

(defrule BEER::init
	"Load stored beer, brewers."
	(declare (auto-focus TRUE))

=>
	(load-facts beer.dat)
)

(defrule BEER::save
	"Save beers and brewers."
	?cmd <- (save-beer)
=>
	(retract ?cmd)
	(save-facts beer.dat)
)

