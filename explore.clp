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

	(import MAIN	deftemplate initial-fact current-user)
	(import PREFS	deftemplate pref save-prefs)
	
	; Error Checking
	(export deftemplate pref-user-input pref-input)
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

	?cmd <- (explore menu)
=>
	(system clear)
	(retract ?cmd)
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
		crlf tab "[ Beer            ] - Preferences for known beers."
		crlf tab "[ Style           ] - The style, or type of beer."
		crlf tab "[ Head-Appearance ] - How a beer's head looks."
		crlf tab "[ Body-Appearance ] - How a beer's body looks."
		crlf tab "[ Aroma           ] - How a beer smells."
		crlf tab "[ Palate          ] - How a beer feels."
		crlf tab "[ Flavor          ] - How a beer tastes."
		crlf tab "[ Region          ] - Beers made from a given area."
		crlf tab "[ Brewer          ] - Beers made by certain breweries."
		crlf
		crlf "----------------------------------------------------------------------"
		crlf
		crlf tab "[ Exit            ] - Exit Explore, and return to Main menu."
		crlf vtab
		"Which category would you like to explore? " 
	)
	(assert (explore-menu-input (read)))	
)


(defrule explore-menu-lowcase-input
    "Make sure input is lowercased."
    ?inp <- (explore-menu-input ?input & : (symbolp ?input))
=>
    (retract ?inp)
    (assert (explore-menu (lowcase ?input)))
)


(defrule explore-menu-input-valid
	"Validate user input on the explore menu."
	?inp <- 
		(explore-menu ?input 
				& beer
				| style 
				| head-appearance 
				| body-appearance
				| aroma 
				| palate 
				| flavor 
				| region
				| brewer
				| exit 
		)
=>
	(retract ?inp)
	(assert (explore ?input))
)


(defrule explore-menu-input-invalid
	"Invalid user input on the explore menu. Reprompt."
	(or
		; Either they picked an invalid choice...
		?inp <- (explore-menu ?input
			& ~beer
			& ~style
			& ~head-appearance
			& ~body-appearance
			& ~aroma
			& ~palate
			& ~flavor
			& ~region
			& ~brewer
			& ~exit
			)
		; ... or they didn't enter a symbol we could check.
		?inp <- (explore-menu-input ?input & ~: (symbolp ?input))
	)
=>
	(retract ?inp)
	(printout t
		crlf vtab "I'm sorry,\"" ?input "\" is not an option, please try again."
		crlf vtab "(Press enter to continue...)"
	)
	(get-char t)
	(assert (explore menu))	
)

; ----------------------------------------------------------------------------

(defrule explore-beer
	"User wants to explore beer preferences."
	?cmd <- (explore beer)
=>
	(retract ?cmd)
	(printout t
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example beer choices:"
        crlf tab "Pliny The Younger, The Abyss, Parabola, Coors Light,"
		crlf tab "Blue Moon Belgian White, Guinness Extra Stout"
		crlf tab "etc..."

		crlf vtab "Input as follows: [rating] [1 beer]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like corona extra\""
		crlf tab "type \"love franziskaner hefe-weisse dunkel\""
		crlf tab "type \"hate miller light\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref beer))
)


(defrule explore-style
	"User wants to explore beer style preferences."
	?cmd <- (explore style)
=>
	(retract ?cmd)
	(printout t
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example style choices:"
        crlf tab "Ale, Lager, IPA, Porter, Stout, Belgian, Amber,"
        crlf tab "Hefeweizen, Dunkelweizen"
		crlf tab "etc..."

		crlf vtab "Input as follows: [rating] [1 style]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like hefeweizen\""
		crlf tab "type \"love dunkelweizen\""
		crlf tab "type \"hate ipa\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref style))
)


(defrule explore-head-appearance
	"User wants to explore beer head appearance preferences."
	?cmd <- (explore head-appearance)
=>
	(retract ?cmd)
	(printout t 
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example head appearance choices:"
		crlf tab "small, average, large, huge,"
		crlf tab "rocky, creamy, frothy, fizzy, none,"
		crlf tab "white, cream, tan, lacing, lasting, diminishing"
		crlf tab "etc..."

		crlf vtab "Input as follows: [rating] [multiple appearances]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like average creamy\""
		crlf tab "type \"love rocky\""
		crlf tab "type \"dislike small none diminishing\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref head-appearance))
)


(defrule explore-body-appearance
	"User wants to explore beer body appearance preferences."
	?cmd <- (explore body-appearance)
=>
	(retract ?cmd)
	(printout t 
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example body appearance choices:"
		crlf tab "clear, sparkling, normal, flat, cloudy, hazy, murky, muddy,"
		crlf tab "particles, thin, average, thick, light, medium, dark, "
		crlf tab "yellow, amber, orange, red, brown, black"
		crlf tab "etc..."

		crlf vtab "Input as follows: [rating] [multiple appearances]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like amber red\""
		crlf tab "type \"love brown hazy black\""
		crlf tab "type \"dislike particles orange\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref body-appearance))
)


(defrule explore-aroma
	"User wants to explore beer aroma preferences."
	?cmd <- (explore aroma)
=>
	(retract ?cmd)
	(printout t 
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example aroma choices:"
		crlf tab "bread, cookie, grain, hay, straw, cereal, toasted, roasted,"
		crlf tab "burnt, nutty, molasses, caramel, chocolate, coffee,"
		crlf tab "flowers, perfume, herbs, grass, pine, spruce, resin,"
		crlf tab "citrus, grapefruit, orange, lemon, lime, yeasty, soap,"
		crlf tab "earth, mold, meat, broth, banana, bubble-gum, grape,"
		crlf tab "raisin, plum, prune, date, apple, pear, peach, pineapple,"
		crlf tab "cherry, raspberry, cassis, wine, port, wood, cask, oak,"
		crlf tab "smoke, tar, charcoal, soy, toffee, butter, butterscotch,"
		crlf tab "honey, sugar, maple, syrup, coriander, ginger, allspice,"
		crlf tab "nutmeg, clove, cinnamon, vanilla, pepper, licorice, cola,"
		crlf tab "alcohol, dust, chalk, vegetable, corn, medicine, solvent,"
		crlf tab "vinegar, sulfur, skunk"
		crlf tab "etc..."

		crlf vtab "Input as follows: "
		crlf tab "[rating] [multiple aromas]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like nutty coffee earth\""
		crlf tab "type \"love bread cookie toasted coriander\""
		crlf tab "type \"dislike vinegar\""
		crlf tab "type \"hate licorice\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref aroma))
)


(defrule explore-flavor
	"User wants to explore beer flavor preferences."
	?cmd <- (explore flavor)
=>
	(retract ?cmd)
	(printout t 
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example flavor choices:"
		crlf tab "sweet, acidic, bitter, acetic, sour, salty"

		crlf vtab "Input as follows: "
		crlf tab "[rating] [multiple flavors]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like salty sweet\""
		crlf tab "type \"love sour\""
		crlf tab "type \"hate acetic\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref flavor))
)


(defrule explore-palate
	"User wants to explore beer palate preferences."
	?cmd <- (explore palate)
=>
	(retract ?cmd)
	(printout t 
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example palate choices:"
		crlf tab "light, medium, full, dry, watery, oily, creamy, syrupy,"
		crlf tab "fizzy, lively, soft, flat, metallic, chalky, astringent,"
		crlf tab "alcoholic"
		crlf tab "etc..."

		crlf vtab "Input as follows: "
		crlf tab "[rating] [multiple palates]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like soft\""
		crlf tab "type \"love full creamy\""
		crlf tab "type \"hate astringent\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref palate))
)


(defrule explore-brewer
	"User wants to explore beer brewery preferences."
	?cmd <- (explore brewer)
=>
	(retract ?cmd)
	(printout t 
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example brewer choices:"
		crlf tab "Deschutes Brewery, Goose Island Beer Company, "
		crlf tab "Dogfish Head Craft Brewery, Lagunitas Brewing Company"
		crlf tab "etc..."

		crlf vtab "Input as follows: "
		crlf tab "[rating] [1 brewer]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like lagunitas brewing co.\""
		crlf tab "type \"love rogue ales\""
		crlf tab "type \"hate anheuser-busch inc.\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref brewer))
)


(defrule explore-region
	"User wants to explore beer regional preferences."
	?cmd <- (explore region)
=>
	(retract ?cmd)
	(printout t 
		crlf vtab "Rating choices:"
		crlf tab "hate, dislike, neutral, like, love"

		crlf vtab "Example region choices:"
		crlf tab "SoCal, PacNW, Midwest, East-coast, South, Mountain"
		;crlf tab "Vegas" ; not really a region, but define availability?
		crlf tab "etc..."

		crlf vtab "Input as follows: "
		crlf tab "[rating] [multiple locations]"

		crlf vtab "EXAMPLE(S):"
		crlf tab "type \"like east-coast\""
		crlf tab "type \"love socal pacnw\""
		crlf tab "type \"dislike south\""

		crlf vtab "When you are finished, type \"done\"!"
	)
	(assert (prompt-pref region))
)


(defrule explore-exit
	"User wishes to end the explore phase. Return them to main menu."
	?cmd <- (explore exit)
=>
	(retract ?cmd)
	(pop-focus)
)

; ----------------------------------------------------------------------------

(defrule prompt-pref
	"Prompt user for preferences."
	?cmd <- (prompt-pref ?category)
	(not (pref-user-input $?))
	(not (pref-input $?))
=>
	(retract ?cmd)
	(printout t crlf tab "[" ?category "] preferences: ")
	(assert 
		; (pref-user-input ?category (explode$ (readline)))
		(pref-user-input ?category (readline))
		; Continue asking for pref's in this category.
		(prompt-pref ?category)
	)
)


(defrule pref-lowcase-input
	"Lowercase user preference input."
	?inp <- (pref-user-input ?category ?input & : (stringp ?input))
=>
	(retract ?inp)
	(assert (pref-input ?category (explode$ (lowcase ?input))))
)


(defrule pref-splitable-input-valid
	"User has input splitable preferences."
	?inp <- (pref-input
				?category & ~style & ~brewer & ~beer
				?rating & hate | dislike | neutral | like | love
				?property
				$?rest
			)
	(current-user (name ?name))
	(not (pref (category ?category) (user ?name) (property ?property)))
=>
	(retract ?inp)
	(assert 
		(pref
			(category ?category)
			(user ?name)
			(property ?property)
			(rating ?rating)
		)
		(pref-input
			?category
			?rating
			$?rest
		)
	)
)


(defrule pref-non-splitable-input-valid
	"User has input non-splitable preferences."
	?inp <- (pref-input
				?category & style | brewer | beer
				?rating & hate | dislike | neutral | like | love
				$?property
			)
	(current-user (name ?name))
	(not (pref (category ?category) (user ?name) (property $?property)))
=>
	(retract ?inp)
	(assert 
		(pref
			(category ?category)
			(user ?name)
			(property $?property)
			(rating ?rating)
		)
	)
)


(defrule remove-old-pref-splitable
	"There is an old preference for this particular property. Remove it!"
	?inp <- (pref-input 
				?category & ~brewer & ~style & ~beer
				?rating 
				?property 
				$?rest
			)
	(current-user (name ?name))
	?pref <- (pref 
                (category ?category) 
                (user ?name) 
                (property ?property)
             )
=>
	(retract ?pref)
)


(defrule remove-old-pref-non-splitable
	"There is an old preference for this particular property. Remove it!"
	?inp <- (pref-input 
				?category & brewer | style | beer
				?rating 
				$?property 
			)
	(current-user (name ?name))
	?pref <- (pref 
                (category ?category) 
                (user ?name) 
                (property $?property)
             )
=>
	(retract ?pref)
)


(defrule pref-input-list-processed
	"Fully processed a list of preference input. Clean up empty list."
	?inp <- (pref-input ?category ?rating & ~done) 
=>
	(retract ?inp)
)


(defrule pref-input-done
	"User is done with preference input."
	?inp <- (pref-input ? done)
	?cmd <- (prompt-pref $?)
=>
	(retract ?inp ?cmd)
    (assert (save-prefs)(explore menu))
	(focus VIOLATIONS PREFS)
)

