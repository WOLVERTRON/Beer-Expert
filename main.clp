;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:		main.clp       
;;	AUTHOR:     Chris Wolverton
;;
;;  DESC:       Rules for the MAIN  module. Focused on driving application..
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule MAIN
	(export ?ALL)
)


(defrule main-intro
	"Explain to user what the Beer Expert system is."

=>
	(system clear)
	(printout t	crlf vtab
		crlf "======================================================================"
		crlf "    B E E R   E X P E R T    -    version 1.0                         "
		crlf "======================================================================"
		crlf "             _, . '__ .                                               "  
		crlf "          '_(_0o),(__)o().             Programmer: Chris Wolverton    "
		crlf "        ,o(__),_)o(_)O,(__)o           Expert:     Kris Wilke         "
		crlf "      o(_,-o(_ )(),(__(_)oO)_          Professor:  Dr. Minor          "
		crlf "      .O(__)o,__).(_ )o(_)Oo_)         Course:     CS782              "
		crlf "  .----|   |   |   |   |   |_)0        Semester:   Fall 2011          "
		crlf " /  .--|   |   |   |   |   |,_)                                       "
		crlf "|  /   |   |   |   |   |   |o(_)       Description:                   "
		crlf "|  |   |   |   |   |   |   |_/`)           The BEER EXPERT will offer "
		crlf "|  |   |   |   |   |   |   |O_)        beer recommendations based on  "
		crlf "|  |   |   |   |   |   |   |           user preferences as determined "
		crlf "|  \\   |   |   |   |   |   |           by exploratory questions, and  "
		crlf " \\  '--|   |   |   |   |   |           direct input.                  "
		crlf "  '----|   |   |   |   |   |                                          "
		crlf "       |   |   |   |   |   |           (Press enter to continue...) "
		crlf "       \\   \\   \\   /   /   /                                       "
		crlf "        `'''''''''''''''''`                                           "
		crlf "======================================================================"
		crlf vtab
	)
	(focus LOGIN)
	(get-char t)
	(assert (show-menu))
)


(defrule show-menu
	"Display main menu options for user, and process input."

	?s <- (show-menu)
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
 		crlf "  M A I N   M E N U "
 		crlf "======================================================================"
		crlf vtab
		crlf "[ Explore   ] - Answer exploratory questions to help discover your"
		crlf "                personal taste."
		crlf
		crlf "[ Recommend ] - Get recommendations for beer based on what we"
		crlf "                currently know about your preferences."
		crlf
		crlf "[ Check     ] - Do your known preferences indicate you will enjoy a"
		crlf "                particular beer? Check!"
		crlf
		crlf "[ Query     ] - Look up information on known beers and styles."
		crlf
		crlf "----------------------------------------------------------------------"
		crlf
		crlf "[ Exit      ] - Quit the Beer Expert."
		crlf vtab
		crlf "Your choice? " crlf
	)
	(assert (menu-input (read)))
)

(defrule menu-input-lowcase
	"Make sure input is lowercased."
	?s <- (menu-input ?input & : (symbolp ?input))
=>
	(retract ?s)
	(assert (menu-input-lowcase (lowcase ?input)))
)


(defrule menu-input-valid
	"Validate user input on main menu."
	?s <- (menu-input-lowcase ?input
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
	(or 
		?s <- (menu-input-lowcase ?input
			& ~explore
			& ~recommend
			& ~check
			& ~query
			& ~exit
			)
		?s <- (menu-input ?input & ~: (symbolp ?input))
	)
=>
	(retract ?s)
	(printout t
		crlf vtab "I'm sorry, \"" ?input "\" is not an option, please try again."
		crlf vtab "(Press enter to continue...)"
	)
	(get-char t)
	(assert (show-menu))
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
	(printout t
		crlf vtab "Goodbye, and thanks for using the BEER EXPERT!"
		crlf vtab
	)
	(exit)
)
