;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:	violations.clp
;;	AUTHOR:	Chris Wolverton
;;
;;	DESC:	Module containing all the error checking interrupts, cleaning up
;;			the code in other modules.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule VIOLATIONS
	"VIOLATIONS module contains interrupts to clean up user input."

	; Globals
	(import MAIN defglobal ?ALL)

	; Templates used for input that we check for errors.
	
	; MAIN
	(import MAIN deftemplate main-menu main-menu-input)

	; USER
	(import USER deftemplate create-user)

	; LOGIN
	(import LOGIN deftemplate login-input)
	
	; EXPLORE
	(import EXPLORE deftemplate pref-user-input pref-input)
)


;; Rule(s): USER Exceptions
;; ============================================================================

(defrule USER_create-user_invalid-age
	"User input for user's age is not valid."
	(declare (auto-focus TRUE)(salience ?*priority-interrupt*))
 
	?cmd <- (create-user 
				(age ?age
					& ~: (integerp ?age)
					| ~: (<= ?*min-age* ?age ?*max-age*)
				)
				(name ?name)
			)
=>
	(retract ?cmd)
	(printout t 
		crlf "ERROR: Invalid age: \"" ?age "\"" 
		crlf "Please enter a whole number between " 
		?*min-age* " and " ?*max-age* ": "
	)
	(assert (create-user (name ?name) (age (read))))
)


(defrule USER_create-user_invalid-name
	"User input for user's name is not valid."
	(declare (auto-focus TRUE)(salience ?*priority-interrupt*))

	?cmd <- (create-user
				(name ?name
					& ~: (stringp ?name)
					|  : (eq ?name "")
				)
				(age ?age)
			)
=>
	(retract ?cmd)
	(printout t
		crlf "ERROR: Invalid name: \"" ?name "\""
		crlf "Please enter a valid name: ")
	(assert 
		(create-user 
			(name (implode$ (explode$ (readline))))
			(age ?age)
		)
	)
)


;; Rule(s): LOGIN Exceptions
;; ============================================================================

(defrule LOGIN_login_invalid-name
	"User input for login name is not valid."
	(declare (auto-focus TRUE)(salience ?*priority-interrupt*))

	?cmd <- (login-input ?name 
				& ~: (stringp ?name) 
				|  : (eq ?name "")
			)
=>
	(retract ?cmd)
	(printout t
		crlf "ERROR: Invalid login name: \"" ?name "\""
		crlf "Please enter a valid name: ")
	(assert (login-input (implode$ (explode$ (readline)))))
)


;; Rule(s): MAIN Exceptions
;; ============================================================================

(defrule MAIN_main-menu_invalid-input
	"Invalid user input on the main menu."
	(declare (auto-focus TRUE)(salience ?*priority-interrupt*))
	(or
		?inp <- (main-menu ?input
					& ~explore 
					& ~recommend 
					& ~query 
					& ~exit
				)
		?inp <- (main-menu-input ?input & ~: (symbolp ?input))
	)
=>
	(retract ?inp)
	(printout t
		crlf vtab "ERROR: \"" ?input "\" is not a menu option."
		crlf tab "Please make another selection: "
	)
	(assert (main-menu-input (read)))
)


;; Rule(s): EXPLORE Exceptions
;; ============================================================================

(defrule EXPLORE_pref-input_invalid
	"User input for preferences is invalid."
	(declare (auto-focus TRUE)(salience ?*priority-interrupt*))
	?inp <- (pref-user-input ?category ?input & ~: (stringp ?input))
=>
	(retract ?inp)
	(printout t
		crlf vtab "ERROR: \"" ?input "\" is not a valid preference input."
		crlf tab "Please enter valid preferences: "
	)
	(assert (pref-user-input ?category (readline)))
)


(defrule EXPLORE_pref-input_rating-invalid
	"User input rating for preference is invalid."
	(declare (auto-focus TRUE)(salience ?*priority-interrupt*))
	?inp <- (pref-input
				?category
				?rating 
					& ~hate 
					& ~dislike 
					& ~neutral 
					& ~like 
					& ~love
				$?rest
			)
=>
	(retract ?inp)
	(printout t
		crlf vtab "ERROR: \"" ?rating "\" is not a valid rating for "
		crlf "\"" $?rest "\""
		crlf tab "Please enter valid preferences: "
	)
	(assert (pref-user-input ?category (readline)))
)