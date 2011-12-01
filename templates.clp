(deftemplate user

	(multislot name
		(type SYMBOL)
		(default ?NONE)
	)

	(slot age
		(type INTEGER)
		(range 0 120)
	)

)

(deftemplate beer
	(multislot name
		(type SYMBOL)
		(default ?NONE)
		(cardinality 1 ?VARIABLE)
	)

	(multislot brewer
		(type SYMBOL)
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

	; Aroma
	(multislot aroma-malt	(type SYMBOL))
	(multislot aroma-hops	(type SYMBOL))
	(multislot aroma-yeast	(type SYMBOL))
	(multislot aroma-misc	(type SYMBOL))

	; Appearance
	(multislot appear-head-initial		(type SYMBOL))
	(multislot appear-head-color		(type SYMBOL))
	(multislot appear-head-lacing		(type SYMBOL))
	(multislot appear-head-longevity	(type SYMBOL))
	(multislot appear-body-clarity		(type SYMBOL))
	(multislot appear-body-particles	(type SYMBOL))
	(multislot appear-body-hue			(type SYMBOL))

	; Flavor
	(multislot flavor-initial	;single or multislot?
		(type SYMBOL)
		(allowed-values
			sweet-light
			sweet-moderate
			sweet-heavy
			sweet-harsh
			acidic-light
			acidic-moderate
			acidic-heavy
			acidic-harsh
			bitter-light
			bitter-moderate
			bitter-heavy
			bitter-harsh
			acetic
			sour
			salty
		)
	)

	(multislot flavor-finish	;single or multislot?
        (type SYMBOL)
        (allowed-values
            sweet-light
            sweet-moderate
            sweet-heavy
            sweet-harsh
            acidic-light
            acidic-moderate
            acidic-heavy
            acidic-harsh
            bitter-light
            bitter-moderate
            bitter-heavy
            bitter-harsh
            acetic
            sour
            salty
        )
    )

	(slot flavor-duration
		(type SYMBOL)
		(allowed-values
			short 
			average 
			long
		)
	)

	; Palate
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


(deftemplate like-appearance

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

