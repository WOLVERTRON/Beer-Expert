;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  FILE:   user.clp       
;;  AUTHOR: Chris Wolverton
;;
;;  DESC:   Rules and templates pertaining to user information.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule USER
	"USER module contains templates and rules related to user accounts."

	(import MAIN deftemplate initial-fact)

	(export deftemplate user create-user)
)


;; Template(s)
;; ============================================================================

(deftemplate user

	(slot name
		(type STRING)
		(default ?NONE)
	)

	(slot age
		(type INTEGER)
	)

	; Date of Birth (e.g. 7 20 1982)
	; TODO: system command to retrieve system date, then use to calc age.
	; (multislot dob 
	; 	(type integer) 
	;	(cardinality 3 3)
	; )
)


(deftemplate create-user
	(slot name)
	(slot age)
)

;; Rule(s)
;; ============================================================================

(defrule init
	"Load stored user information."
	(declare (auto-focus TRUE))

=>
	(load-facts user.dat)
)


(defrule save-users
	"Save user information."
	
	?cmd <-(save-users)
=>
	(retract ?cmd)
	(save-facts user.dat)
)


(defrule create-user
	"Create a new user account."
	
	?cmd <- (create-user (name ?name) (age ?age))
=>
	(retract ?cmd)
	(assert
		(user (name ?name) (age ?age))
		(save-users)
	)
)
		
