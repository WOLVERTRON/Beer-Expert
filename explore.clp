;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:	explore.clp	
;;  AUTHOR:	Chris Wolverton
;;
;;  DESC:	Rules for the EXPLORE module. Focused on obtaining user pref's.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule EXPLORE 
	"Explore module discovers user preferences through user interrogation."
	(import MAIN deftemplate initial-fact)
	(import LOGIN deftemplate current-user)
	(import PREFS deftemplate pref)
)


(defrule explore-intro
	"Explain to user what the explore phase is all about."

=>
	(printout t 
		crlf vtab
		"In order to better recommend brews to you, we're going to explore "
		"what characteristics you enjoy in a beverage!"
		crlf vtab "(Press enter to continue...)"
	)
	(get-char t)
	(assert (explore menu))
)


(defrule explore-menu
	"Display explore menu, informing user of options. Collect input."

	?s <- (explore menu)
=>
	(system clear)
	(retract ?s)
	(printout t
        crlf "                                 .:.      .:.         .:.             "
        crlf "                               _oOoOo   _oOoOo       oOoOo_           "
        crlf "                              [_|||||  [_|||||       |||||_]          "
        crlf "                                |||||    |||||       |||||            "
        crlf "                                ~~~~~    ~~~~~       ~~~~~            "
		crlf "======================================================================"
		crlf "  E X P L O R E   -   Specify likes/dislikes in the following areas:"
		crlf "======================================================================"
		crlf vtab
		crlf tab "[ Style      ] - The type of beer."
		crlf tab "[ Appearance ] - How a beer looks."
		crlf tab "[ Aroma      ] - How a beer smells."
		crlf tab "[ Palate     ] - How a beer feels."
		crlf tab "[ Flavor     ] - How a beer tastes."
		crlf tab "[ Origin     ] - Where a beer is from."
		crlf
		crlf "----------------------------------------------------------------------"
		crlf
		crlf tab "[ Exit       ] - Exit Explore, and return to Main menu."
		crlf vtab
		"Which category would you like to explore?" crlf
	)
	(assert 
		(explore-menu-input (read))
	)	
)


(defrule explore-menu-input-lowcase
    "Make sure input is lowercased."
    ?s <- (explore-menu-input ?input & : (symbolp ?input))
=>
    (retract ?s)
    (assert (explore-menu-input-lowcase (lowcase ?input)))
)


(defrule explore-menu-input-valid
	"Validate user input on the explore menu."
	?s <- 
		(explore-menu-input-lowcase ?input 
				& style 
				| appearance 
				| aroma 
				| palate 
				| flavor 
				| origin
				| exit 
		)
=>
	(retract ?s)
	(assert (explore ?input))
)


(defrule explore-menu-input-invalid
	"Invalid user input on the explore menu. Reprompt."
	(or
		?s <- (explore-menu-input-lowcase ?input
			& ~style
			& ~appearance
			& ~aroma
			& ~palate
			& ~flavor
			& ~origin
			& ~exit
			)
		?s <- (explore-menu-input ?input & ~: (symbolp ?input))
	)
=>
	(retract ?s)
	(printout t
		crlf vtab "I'm sorry,\"" ?input "\" is not an option, please try again."
		crlf vtab "(Press enter to continue...)"
	)
	(get-char t)
	(assert (explore menu))	
)


(defrule explore-style
	"User wants to explore beer style preferences."
	?cmd <- (explore style)
=>
	(retract ?cmd)
	(printout t

		crlf vtab "You will rate on the following scale:"
		crlf tab "hate"
		crlf tab "dislike"
		crlf tab "neutral"
		crlf tab "like"
		crlf tab "love"

		crlf vtab "There are many different beer styles. Here are a few:"

		crlf tab "American Ale"
		crlf tab tab "Red Ale, American Barleywine, American Black Ale,"
		crlf tab tab "American Blonde Ale, American Brown Ale, American Dark Wheat Ale,"
		crlf tab tab "Imperial IPA, Imperial Stout,"
		crlf tab tab "American IPA, American Pale Ale, American Pale Wheat Ale,"
		crlf tab tab "American Porter, American Stout, American Strong Ale,"
		crlf tab tab "American Wild Ale, Pumpkin Ale, Rye Beer, Wheatwine"

		crlf tab "Belgian"
		crlf tab tab "Belgian Dark Ale, Belgian IPA, Belgian Pale Ale,"
		crlf tab tab "Belgian Strong Dark Ale, Belgian Strong Pale Ale"
		crlf tab tab "Dubbel, Faro, Flanders Oud Bruin, Flanders Red Ale"
		crlf tab tab "Gueuze, Lambic, Quad, Saison, Tripel, Witbier"

		crlf tab "English Ale"
		crlf tab tab "Baltic Porter, Braggot, English Barleywine, English Bitter,"
		crlf tab tab "English Brown Ale, English Dark Mild Ale, English IPA,"
		crlf tab tab "English Pale Ale, English Pale Mild Ale, English Porter,"
		crlf tab tab "English Stout, English Strong Ale, Oatmeal Stout, Old Ale,"
		crlf tab tab "Russian Imperial Stout, Winter Warmer"

		crlf tab "Finnish Ale"
		crlf tab tab "Sahti"

		crlf tab "German Ale"
		crlf tab tab "Altbier, Berliner Weissbier, Dunkelweizen, Gose, Hefeweizen"
		crlf tab tab "Kolsch, Kristalweizen, Roggenbier, Weizenbock"

		crlf tab "Irish Ale"
		crlf tab tab "Irish Dry Stout, Irish Red Ale"

		crlf tab "Russian Ale"
		crlf tab tab "Kvass"

		crlf tab "Scottish Ale"
		crlf tab tab "Scotch Ale, Scottish Gruit"

		crlf tab "American Lager"
		crlf tab tab "American Adjunct Lager, Red Lager," 
		crlf tab tab "Imperial Pilsner, American Malt Liquor,"
		crlf tab tab "American Pale Lager, Steam Beer, Light Lager, Low Alcohol Beer"

		crlf tab "Czech Lager"
		crlf tab tab "Czech Pilsener"
		
		crlf tab "European Lager"
		crlf tab tab "Euro Dark Lager, Euro Pale Lager, Euro Strong Lager"

		crlf tab "German Lager"
		crlf tab tab "Bock, Doppelbock, Dortmunder, Eispock, German Pilsener,"
		crlf tab tab "Keller Bier, Maibock, Marzen, Munich Dunkel Lager,"
		crlf tab tab "Munich Helles Lager, Rauchbier, Schwarzbier, Vienna Lager"

		crlf tab "Japanese Lager"
		crlf tab tab "Happoshu, Japanese Rice Lager"

		crlf tab "Hybrid"
		crlf tab tab "Fruit, Vegetable, Herbed, Spiced, Smoked"
	)
	(get-char t)
)


(defrule explore-appearance
	"User wants to explore beer appearance preferences."
	?s <- (explore appearance)
=>
	(retract ?s)
	(printout t
		crlf
		"TODO: Explore appearance! Returning to explore menu..."
		crlf
	)(get-char t)
	(assert
		(explore menu)
	)
)


(defrule explore-aroma
	"User wants to explore beer aroma preferences."
	?s <- (explore aroma)
=>
	(retract ?s)
	(printout t
		crlf
		"TODO: Explore aroma! Returning to explore menu..."
		crlf
	)(get-char t)
	(assert
		(explore menu)
	)
)


(defrule explore-flavor
	"User wants to explore beer flavor preferences."
	?cmd <- (explore flavor)
=>
	(retract ?cmd)
	(printout t 

		crlf vtab "You will rate on the following scale:"
		crlf tab "hate"
		crlf tab "dislike"
		crlf tab "neutral"
		crlf tab "like"
		crlf tab "love"

		crlf vtab "Beer flavor is typically broken down into the following categories:"
		crlf tab "sweet"
		crlf tab "acidic"
		crlf tab "bitter"
		crlf tab "acetic"
		crlf tab "sour"
		crlf tab "salty"

		crlf vtab "Please enter your feelings about particular flavors in the following way:"
		crlf "(hate|dislike|neutral|like|love) category1 category2 ..."

		crlf vtab "EXAMPLE:"
		crlf tab "type \"like salty sweet\""
		crlf tab "type \"love sour\""
		crlf tab "type \"hate acetic\""

		crlf vtab "Please enter your flavor preferences, or type \"done\"."
	)
	(assert (prompt-flavor-pref))
)


(defrule prompt-flavor-pref
	"Prompt user for flavor preferences."
	?cmd <- (prompt-flavor-pref)
	(not (flavor-pref-input $?))
=>
	(retract ?cmd)
	(printout t
		crlf vtab "Input preferences: "
	)
	(assert 
		(flavor-pref-input (explode$ (readline)))
		(prompt-flavor-pref)
	)
)


(defrule flavor-pref-input-valid
	"User has input flavor preferences."
	?inp <- (flavor-pref-input
				?rating & hate | dislike | neutral | like | love
				?prop & sweet | acidic | bitter | acetic | sour | salty
				$?rest
			)
	(current-user (name ?name))
	(not (pref (category flavor) (user ?name) (property ?prop)))
=>
	(retract ?inp)
	(assert 
		(pref
			(category flavor)
			(user ?name)
			(property ?prop)
			(rating ?rating)
		)
		(flavor-pref-input
			?rating
			$?rest
		)
	)
)


(defrule remove-old-flavor-pref
	"There is an old flavor preference for this particular property. Remove it!"
	?inp <- (flavor-pref-input ?rating ?prop $?)
	(current-user (name ?name))
	?pref <- (pref 
                (category flavor) 
                (user ?name) 
                (property ?prop)
             )
=>
	(retract ?pref)
)

(defrule flavor-pref-input-list-processed
	"Fully processed a list of flavor preferences, so clean up the hanging fact."
	?inp <- (flavor-pref-input ?last & ~done)
=>
	(retract ?inp)
)


(defrule flavor-pref-input-done
	"User is done with flavor preference input."
	?inp <- (flavor-pref-input done)
	?cmd <- (prompt-flavor-pref)
=>
	(retract ?inp ?cmd)
)





(defrule explore-palate
	"User wants to explore beer palate preferences."
	?s <- (explore palate)
=>
	(retract ?s)
	(printout t
		crlf
		"TODO: Explore palate! Returning to explore menu..."
		crlf
	)(get-char t)
	(assert
		(explore menu)
	)
)


(defrule explore-origin
	"User wants to explore beer origin preferences."
	?s <- (explore origin)
=>
	(retract ?s)
	(printout t
		crlf
		"TODO: Explore origin! Returning to explore menu..."
		crlf
	)(get-char t)
	(assert
		(explore menu)
	)
)


(defrule explore-exit
	"User wishes to end the explore phase. Return them to main menu."
	?s <- (explore exit)
=>
	(retract ?s)
	(pop-focus)
)






