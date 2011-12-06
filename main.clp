;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:		main.clp       
;;	AUTHOR:     Chris Wolverton
;;
;;  DESC:       Rules for the MAIN  module. Focused on driving application..
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule MAIN
	"Explore module discovers user preferences through user interrogation."
	(export ?ALL)
)


(defrule main-intro
	"Explain to user what the Beer Expert system is."

=>
	(printout t
		crlf vtab
crlf "======================================================================"
crlf "    B E E R   E X P E R T    -    version 1.0                         "
crlf "======================================================================"
crlf "             _, . '__ .         " tab 
crlf "          '_(_0o),(__)o().      " tab "Programmer: Chris Wolverton  "
crlf "        ,o(__),_)o(_)O,(__)o    " tab "Expert:     Kris Wilke"
crlf "      o(_,-o(_ )(),(__(_)oO)_   " tab "Professor:  Dr. Minor"
crlf "      .O(__)o,__).(_ )o(_)Oo_)  " tab "Course:     CS782"
crlf "  .----|   |   |   |   |   |_)0 " tab "Due:        December 12, 2011"
crlf " /  .--|   |   |   |   |   |,_) "
crlf "|  /   |   |   |   |   |   |o(_)" tab "Description:"
crlf "|  |   |   |   |   |   |   |_/`)" tab "    The BEER EXPERT will offer"
crlf "|  |   |   |   |   |   |   |O_) " tab "beer recommendations based on "
crlf "|  |   |   |   |   |   |   |    " tab "user preferences as determined"
crlf "|  \\   |   |   |   |   |   |    " tab "by exploratory questions, and "
crlf " \\  '--|   |   |   |   |   |    " tab "direct input."
crlf "  '----|   |   |   |   |   |    "
crlf "       |   |   |   |   |   |    "
crlf "       \\   \\   \\   /   /   /    "
crlf "        `'''''''''''''''''`     "
crlf "======================================================================"
crlf vtab
	)
	(assert (main  menu))
)


(defrule main-menu
	"Display main menu options for user, and process input."

	?s <- (main menu)
=>
	(retract ?s)
	(printout t
		crlf "Main Menu:"
		crlf vtab
		crlf "Explore   - Answer exploratory questions to help discover"
		crlf "            your personal taste."
		crlf
		crlf "Recommend - Get recommendations for beer based on what we"
		crlf "            currently know about your preferences."
		crlf
		crlf "Check     - Do your known preferences indicate you will "
		crlf "            enjoy a particular beer? Check!"
		crlf
		crlf "Query     - Look up information on known beers and styles."
		crlf
		crlf "Exit      - Quit the Beer Expert."
		crlf vtab
		crlf "Your choice? " crlf
	)
	(assert
		(menu-input (lowcase (read)))
	)
)


(defrule menu-input-valid
	"Validate user input on main menu."
	?s <-
		(menu-input ?input
			& explore
			| recommend
			| check
			| query
			| exit
		)
=>
	(retract ?s)
	(assert (menu ?input))
)


(defrule menu-input-invalid
	"Invalid user input on the main menu. Reprompt."
	?s <-
		(menu-input ?input
			& ~explore
			& ~recommend
			& ~check
			& ~query
			& ~exit
		)
=>
	(retract ?s)
	(printout t
		crlf "I'm sorry, \"" ?input "\" is not an option, please try again."
		crlf
	)
	(assert
		(main menu)
	)
)


(defrule menu-explore
	"User wishes to begin explore phase."
	?s <- (menu explore)
=>
	(retract ?s)
	(focus EXPLORE)
)


(defrule menu-exit
	"User wishes to exit program."
	?s <- (menu exit)
=>
	(retract ?s)
	(exit)
)
