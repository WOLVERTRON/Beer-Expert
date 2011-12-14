;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:	main.clp       
;;	AUTHOR:	Chris Wolverton
;;
;;	DESC:	Rules for the MAIN  module. Focused on driving application.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Global(s)
;; ============================================================================

(defglobal
	 
	; Salience
	?*priority-interrupt*	= 100
	?*priority-file*		= 50
	?*priority-command*		= 10

	; Age related constants.
	?*min-age* 		= 0
	?*legal-age* 	= 21
	?*max-age* 		= 120

	; Score modifiers
;	?*score-hate*		=  -10
;	?*score-dislike*	=   -3
;	?*score-neutral*	=    0
;	?*score-like* 		=    3
;	?*score-love* 		=   10
;	?*score-mega-bonus*	=  100
;	?*score-mega-malus* = -100

)

(deffacts score-mapping
	"Maps a score to it's value."
	; Ratings
	(score-map hate		-10)
	(score-map dislike	 -3)
	(score-map neutral	  0)
	(score-map like		  3)
	(score-map love		 10)
	
	; Bonus/Malus
	(score-map mega-bonus  1000)
	(score-map mega-malus -1000)
	
)

(deffacts factor-mapping
	"Maps a factor to it's value."
	(factor-map 	brewer			.30)
	(factor-map 	style			.60)
	(factor-map 	aroma			.50)
	(factor-map 	appearance-head	.10)
	(factor-map 	appearance-body	.20)
	(factor-map 	flavor			.50)
	(factor-map 	palate			.30)
)

(defmodule MAIN
	(export ?ALL)
)


;; Template(s)
;; ============================================================================

(deftemplate current-user
	(slot name
		(type STRING)
		(default ?NONE)
	)
	(slot age 
		(type INTEGER)
	)
)

;; Rule(s)
;; ============================================================================

(defrule intro
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
	(assert (show-main-menu))
)


(defrule show-main-menu
	"Display main menu options for user, and process input."

	?cmd <- (show-main-menu)
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
 		crlf "  M A I N   M E N U  "
 		crlf "======================================================================"
		crlf vtab
		crlf "[ Explore   ] - Answer exploratory questions to help discover your"
		crlf "                personal taste."
		crlf
		crlf "[ Recommend ] - Get recommendations for beer based on what we"
		crlf "                currently know about your preferences."
		crlf
		crlf "[ Query     ] - Look up information on known beers and styles."
		crlf
		crlf "----------------------------------------------------------------------"
		crlf
		crlf "[ Exit      ] - Quit the Beer Expert."
		crlf vtab
		crlf "Your choice? " crlf
	)
	(assert (main-menu-input (read)))
)


(defrule menu-input-lowcase
	"Lowercase user input."
	?inp <- (main-menu-input ?input & : (symbolp ?input))
=>
	(retract ?inp)
	(assert (main-menu (lowcase ?input)))
)


(defrule main-menu-explore
	"User wishes to begin explore phase."
	?cmd <- (main-menu explore)
=>
	(retract ?cmd)
	(focus EXPLORE)
	(assert 
		(show-explore-menu)
		(show-main-menu)
	)	
)


(defrule main-menu-recommend
	"User wishes to begin recommendation phase."
	?cmd <- (main-menu recommend)
=>
	(retract ?cmd)
	(focus RECOMMEND)
	(refresh RECOMMEND::init)
	(printout t crlf vtab "DO STUFF NOW!" crlf vtab)
)


(defrule main-menu-exit
	"User wishes to exit program."
	?cmd <- (main-menu exit)
=>
	(retract ?cmd)
	(printout t	crlf vtab "Goodbye, and thanks for using the BEER EXPERT!"
				crlf vtab
	)
	(halt);(exit)
)
