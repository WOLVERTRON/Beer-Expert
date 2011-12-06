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
	(import MAIN ?ALL)
)


(defrule explore-intro
	"Explain to user what the explore phase is all about."

=>
	(printout t 
		"In order to better recommend brews to you, we're going to explore "
		"what characteristics you enjoy in a beverage!"
		crlf vtab
		(assert (explore menu))
	)
)


(defrule explore-menu
	"Display explore menu, informing user of options. Collect input."

	?s <- (explore menu)
=>
	(retract ?s)
	(printout t
		crlf "These are the areas we can work with: "
		crlf vtab
		crlf tab "Style     " 	tab "- The type of beer."
		crlf tab "Appearance"	tab "- How a beer looks."
		crlf tab "Aroma     "	tab "- How a beer smells."
		crlf tab "Palate    "	tab "- How a beer feels."
		crlf tab "Flavor    "	tab "- How a beer tastes."
		crlf tab "Origin    "	tab "- Where a beer is from."
		crlf
		crlf tab "Exit      "	tab "- Exit Explore, and return to Main menu."
		crlf vtab
		"Which would you like to explore?" crlf
	)
	(assert 
		(explore-menu-input (lowcase (read)))
	)	
)


(defrule explore-menu-input-valid
	"Validate user input on the explore menu."
	?s <- 
		(explore-menu-input ?input 
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
	?s <-
		(explore-menu-input ?input
			& ~style
			& ~appearance
			& ~aroma
			& ~palate
			& ~flavor
			& ~origin
			& ~exit
		)
=>
	(retract ?s)
	(printout t
		crlf "I'm sorry,\"" ?input "\" is not an option, please try again."
		crlf
	)
	(assert
		(explore menu)
	)	
)


(defrule explore-style
	"User wants to explore beer style preferences."
	?s <- (explore style)
=>
	(retract ?s)
	(printout t
		crlf
		"TODO: Explore style! Returning to explore menu..."
		crlf
	)
	(assert
		(explore menu)
	)
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
	)
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
	)
	(assert
		(explore menu)
	)
)


(defrule explore-flavor
	"User wants to explore beer flavor preferences."
	?s <- (explore flavor)
=>
	(retract ?s)
	(printout t
		crlf
		"TODO: Explore flavor! Returning to explore menu..."
		crlf
	)
	(assert
		(explore menu)
	)
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
	)
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
	)
	(assert
		(explore menu)
	)
)


(defrule explore-exit
	"User wishes to end the explore phase. Return them to main menu."
	?s <- (explore exit)
=>
	(retract ?s)
	(focus MAIN)
	(assert
		(main menu)
	)
)


















