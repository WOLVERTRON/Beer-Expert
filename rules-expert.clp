(defrule rule001-under21
	"Minors are not allowed to drink."
	(user
		(age ?age &:(< ?age 21))
		(name ?name)
	)
	=>
	(printout t "The consumption of alcoholic beverages is illegal for persons under the age of 21. As such, we can only recommend non-alcoholic beers." crlf)
	(assert (recommend-type non-alcoholic))
	(assert (recommend-beer Kaliber))
	(assert (recommend-beer St. Pauli N/A))
	(assert (recommend-beer Clausthaler))
	(assert (recommend-beer O'Doul's))
)
		
