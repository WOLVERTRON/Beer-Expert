;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:   login.clp       
;;	AUTHOR: Chris Wolverton
;;
;;	DESC:   Rules and templates pertaining to logging in.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule LOGIN
	"LOGIN module contains templates and rules related to user accounts."

	(import MAIN deftemplate initial-fact)
	(import USER deftemplate user)
	(import USER deftemplate create-user)

	(export deftemplate current-user)
	(export deftemplate login)
	(export deftemplate create-user)
)


;; Template(s)
;; ============================================================================

(deftemplate current-user
	(multislot name
		(type SYMBOL)
		(default ?NONE)
	)
	(slot age 
		(type INTEGER)
	)
)


;; Rule(s)
;; ============================================================================
(defrule init
=>
	(assert (login-prompt))
)


(defrule login-prompt
	"Prompt user for name, which corresponds to user account."
	?cmd <- (login-prompt)
=>
	(retract ?cmd)
	(printout t crlf vtab "What is your login name?  ")
	(assert (login (readline)))
)


(defrule login-match
	"User exists, so load information."
	?cmd <- (login ?name)
	(user
		(name ?name)
		(age ?age)
	)
=>
	(retract ?cmd)
	(assert (current-user (name ?name) (age ?age)))
	(printout t
		crlf "Welcome, " ?name "!"
		crlf vtab "(Press enter to continue...)"
	)
	(get-char t)
)


(defrule login-unmatched
	"User does not exist. Verify correct input."
	(login ?name)
	(not (user (name ?name)))
=>
	(printout t
		crlf vtab "The user \"" ?name "\" does not exist."
		crlf "Would you like to create this account (yes/no)? "
	)
	(assert (create-account (lowcase (read))))
)


(defrule create-account-no
	"User does not wish to create a new account. (i.e. They typo'd their name.)"
	?inp <- (create-account ~yes)
	?cmd <- (login ?)
=>
	(retract ?inp ?cmd)
	(assert (login-prompt))
)


(defrule create-account-yes
	"User wishes to create an account."
	?inp <- (create-account yes)
	?cmd <- (login ?name)
=>
	(retract ?inp)
	(printout t
		crlf "Please enter your age: "
	)
	(assert 
		(create-user (name ?name) (age (read)))
	)
	(focus VIOLATIONS USER)
)


