;; A potential phase changer, but I don't think I want it
;; to flow this way.

;(defrule change-phase
;	?s <- (phase ?next $?rest)
;=>
;	(focus ?next)
;	(retract ?s)
;	(assert (phase $?rest ?next))
;)



(deftemplate MAIN::user

	(multislot name
		(type SYMBOL)
		(default ?NONE)
	)

	(slot age
		(type INTEGER)
		(range 0 120)
	)

)

(deftemplate MAIN::beer
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

	(slot abv	; alcohol by volume
		(type NUMBER)
	)

	(slot price
		(type SYMBOL)
		(allowed-values
			cheap
			inexpensive
			average
			moderate
			expensive
			exorbitant
		)
	)

	(multislot serving-temp
		(type NUMBER)
		(cardinality 2 2) ; range
	)	

	; Aroma
	(multislot aroma)

	; Appearance
	(multislot appearance-head)
	(multislot appearance-body)

	; Flavor
	(multislot flavor)

	(multislot flavor-initial)
	(multislot flavor-finish)
	(slot flavor-duration
		(type SYMBOL)
		(allowed-values
			short 
			average 
			long
		)
	)

	; Palate
	(multislot palate)

	(slot palate-body
		(type SYMBOL)
		(allowed-values
			light
			light-medium
			medium
			medium-full
			full
		)
	)
	
	(slot palate-texture
		(type SYMBOL)
		(allowed-values
			dry
			watery
			oily
			creamy
			syrupy
		)
	)

	(slot palate-carbonation
		(type SYMBOL)
		(allowed-values
			fizzy
			lively
			soft
			flat
		)
	)

	(slot palate-finish
		(type SYMBOL)
		(allowed-values
			metallic
			chalky
			astringent-light
			astringent-moderate
			astringent-heavy
			astringent-harsh
			alcoholic-light
			alcoholic-moderate
			alcoholic-heavy
			alcoholic-harsh
		)
	)
)


(deftemplate MAIN::like

	(slot category
		(type SYMBOL)
	)

	(multislot user
		(type SYMBOL)
		(default ?NONE)
		(cardinality 1 ?VARIABLE)	; Not multiple, just names. e.g. Chris Wolverton
	)

	(slot attribute
		(type SYMBOL)
		(default ?NONE)
	)

	(slot rating
		(type INTEGER)
		(range -2 2)	; hate dislike indifferent like love
		(default 0)
	)

)

