;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:   login.clp       
;;	AUTHOR: Chris Wolverton
;;
;;	DESC:   Rules and templates pertaining to logging in.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule LOGIN
	"LOGIN module contains templates and rules related to user accounts."
	(export ?ALL)
	(import MAIN deftemplate initial-fact)
	(import MAIN deftemplate current-user)
)


(deftemplate LOGIN::user

        (multislot name
                (type SYMBOL)
                (default ?NONE)
        )

        (slot age
                (type INTEGER)
                (range 0 130)
        )

)


(defrule LOGIN::init
	"Load stored users, initiate login process."
=>
	(assert (load-users) (login))
)


(defrule LOGIN::load-users
	"Load existing users into memory."
	?s <- (load-users)
=>
	(retract ?s)
	(load-facts users.dat)
	(assert (users-loaded))
)


(defrule LOGIN::login
	"Prompt user for name, which corresponds to user account."
	?s <- (login)
	(users-loaded)
=>
	(retract ?s)
	(printout t crlf vtab "What is your name? ")
	(assert (input-name (explode$ (readline))))
)


(defrule LOGIN::login-valid
	"User exists, so load information."
	?s <- (input-name $?name)
	(user
		(name $?name)
		(age ?age)
	)
=>
	(retract ?s)
	(pop-focus)
	(assert (current-user (name $?name) (age ?age)))
	(printout t
		crlf "Welcome, " (implode$ $?name) "!"
		crlf vtab "(Press enter to continue...)"
	)
	(get-char t)
)


(defrule LOGIN::login-invalid
	"User does not exist. Verify correct input."
	(input-name $?name)
	(not (user (name $?name)))
=>
	(printout t
		crlf vtab "The user \"" (implode$ $?name) "\" does not exist."
		crlf "Would you like to create this account (yes/no)? "
	)
	(assert (create-account (lowcase (read))))
)


(defrule LOGIN::create-account-no
	"User does not wish to create a new account. (i.e. They typo'd their name.)"
	?s1 <- (create-account ~yes)
	?s2 <- (input-name $?)
=>
	(retract ?s1 ?s2)
	(assert (login))
)


(defrule LOGIN::create-account-yes
	"User wishes to create an account."
	(create-account yes)
	(input-name $?name)
=>
	(assert (prompt-age))
)


(defrule LOGIN::prompt-age
	"Prompt user for age."
	?s <- (prompt-age)
=>
	(retract ?s)
	(printout t crlf "Please enter your age: ")
	(assert (input-age (read)))
)


(defrule LOGIN::input-age-valid
	"User has entered in a real age."
	?s <- (input-age ?age 
		& : (integerp ?age)
		& : (< 0 ?age 130)
		)
=>
	(retract ?s)
	(assert (input-age-valid ?age))
)


(defrule LOGIN::input-age-invalid
	"User has entered an invalid age."
	?s <- (input-age ?age
		& ~: (integerp ?age)
		| ~: (< 0 ?age 130)
		)
=>
	(retract ?s)
	(printout t "Invalid age input!")
	(assert (prompt-age))
)


(defrule LOGIN::create-account-complete
	"All user data collected. Create account."
	?s1 <- (create-account yes)
	?s2 <- (input-name $?name)
	?s3 <- (input-age-valid ?age)
=>
	(retract ?s1 ?s2 ?s3)
	(assert (user (name $?name) (age ?age)))
	(save-facts users.dat)
	(assert (input-name $?name)) ; Mimic valid login.
)



