;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;      FILE:	recommend.clp       
;;      AUTHOR:	Chris Wolverton
;;
;;		DESC:	Beer recommendation rules.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmodule RECOMMEND)


(deftemplate RECOMMEND::bonus
	(multislot user)
	(multislot reason)
	(slot category)
	(multislot value)
	(slot modifier)
)


(defrule RECOMMEND::style-bonus
	"Instantiate bonuses based on style for each qualifying beer."
	(bonus 
		(user $?user) 
		(reason $?reason) 
		(category style)
		(value $?style)
		(modifier ?mod)
	)
	(beer
		(name $?beer)
		(style $?style)
	)
=>
	(assert
		(bonus
			(user $?user)
			(reason $?reason)
			(category beer)
			(value $?beer)
			(modifier ?mod)
		)
	)
)
		

(defrule RECOMMEND::rule001-under21
        "Minors are not allowed to drink alcohol!"
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



(defrule RECOMMEND::rule002-wine-drinker-likes-belgian
	"Those who like wine may enjoy the flavor of Belgian beers."
    (likes (user $?user) (attribute wine))
=>
	(assert
		(bonus
			(user $?user)
            (reason wine-drinker)
			(category style)
            (value belgian)
            (modifier 10)
        )
    )
)

