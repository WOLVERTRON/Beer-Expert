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
		crlf "  .----|   |   |   |   |   |_)0        Due:        December 12, 2011  "
		crlf " /  .--|   |   |   |   |   |,_)                                       "
		crlf "|  /   |   |   |   |   |   |o(_)       Description:                   "
		crlf "|  |   |   |   |   |   |   |_/`)           The BEER EXPERT will offer "
		crlf "|  |   |   |   |   |   |   |O_)        beer recommendations based on  "
		crlf "|  |   |   |   |   |   |   |           user preferences as determined "
		crlf "|  \\   |   |   |   |   |   |          by exploratory questions, and  "
		crlf " \\  '--|   |   |   |   |   |          direct input.                  "
		crlf "  '----|   |   |   |   |   |                                          "
		crlf "       |   |   |   |   |   |           (Press enter to continue...) "
		crlf "       \\   \\   \\   /   /   /                                       "
		crlf "        `'''''''''''''''''`                                           "
		crlf "======================================================================"
		crlf vtab
	)
	(load-facts users.dat)
	(assert (login))
	(get-char t)
)


(defrule login
	"Allow user to log-in to system, so we can individually track their preferences."
	?s <- (login)
=>
	(retract ?s)
	(printout t
		crlf vtab "What is your name? "
	)	
	(assert
		(login-name (explode$ (readline)))
	)
)


(defrule login-valid
	"If user exists, set as current."
	?s <- (login-name $?name)
	(user
		(name $?name)
		(age ?age)
	)
=>
	(retract ?s)
	(assert
		(current-user $?name)
	)
	(printout t "Welcome back, " $?name "!")
	(get-char t)
)


(defrule login-invalid
	"Login name does not exist. Verify if this was the intended name."
	?s <- (login-name $?name)
	(not (user (name $?name)))
=>
	(retract ?s)
	(printout t
		crlf vtab "The user \"" (implode$ $?name) "\" does not currently exist."
	)

	(assert
		(create-account $?name)
	)
		
)


(defrule create-account
	"Confirm user wants to create an account."
	(create-account $?name)
=>
	(printout t
		crlf "Do you wish to create an account for \"" (implode$ $?name) "\"? "
	)
	(assert (create-account-response (lowcase (read))))
)


(defrule create-account-no
	?s1 <- (create-account-response ~yes)
	?s2 <- (create-account $?name)
=>
	(retract ?s1 ?s2)
	(assert (login))
)

(defrule create-account-yes
	?s1 <- (create-account-response yes)
	?s2 <- (create-account $?name)
=>
	(retract ?s1 ?s2)
	(assert
		(current-user $?name)
		(user (name $?name))
		;(ask-age)
		(main menu) ; temp for here.
	)
)


(defrule main-menu
	"Display main menu options for user, and process input."

	?s <- (main menu)
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
		crlf vtab "I'm sorry, \"" ?input "\" is not an option, please try again."
		crlf vtab "(Press enter to continue...)"
	)
	(get-char t)
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
	(printout t
		crlf vtab "Goodbye, and thanks for using the BEER EXPERT!"
		crlf vtab
	)
	(exit)
)
