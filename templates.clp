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


(deftemplate likes

	(multislot user
		(type SYMBOL)
		(default ?NONE)
		(cardinality 1 ?VARIABLE)
	)

	(slot category
		(type SYMBOL)
		(default ?NONE)
		(allowed-values
			appearance
			aroma
			palate
			flavor
			style
			misc
		)

	(slot attribute
		(type SYMBOL)
		(default ?NONE)
		(allowed-values
			
	)

	(multislot aspect
		(type SYMBOL)
		(default ?NONE
