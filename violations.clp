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

	(import USER deftemplate create-user)
	(import LOGIN deftemplate create-user)
	(import LOGIN deftemplate login)
)


;; Rule(s): USER Exceptions
;; ============================================================================

(defrule USER_create-user_invalid-age
	"User input for user's age is not valid."
	(declare (auto-focus TRUE))
 
	?cmd <- (create-user 
				(age ?age
					& ~: (integerp ?age)
					| ~: (<= 0 ?age 130)
				)
				(name ?name)
			)
=>
	(retract ?cmd)
	(printout t 
		crlf "ERROR: Invalid age: \"" ?age "\"" 
		crlf "Please enter a whole number between 0 and 130: ")
	(assert (create-user (name ?name) (age (read))))
)


(defrule USER_create-user_invalid-name
	"User input for user's name is not valid."
	(declare (auto-focus TRUE))

	?cmd <- (create-user
				(name ?name
					& ~: (stringp ?name)
					| : (eq ?name "")
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
	(declare (auto-focus TRUE))

	?cmd <- (login ?name 
				& ~: (stringp ?name) 
				|  : (eq ?name "")
			)
=>
	(retract ?cmd)
	(printout t
		crlf "ERROR: Invalid login name: \"" ?name "\""
		crlf "Please enter a valid name: ")
	(assert
		(login (implode$ (explode$ (readline))))
	)
)

