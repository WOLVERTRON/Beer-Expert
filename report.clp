;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:	report.clp       
;;	AUTHOR:	Chris Wolverton
;;
;;	DESC:	Beer report rules.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule REPORT
	(import MAIN defglobal ?ALL)
	(import MAIN deftemplate initial-fact current-user)
	(import BEER deftemplate beer brewer)
	(import RECOMMEND deftemplate score)

)


;; Rule(s): Reporting
;; ============================================================================

(defrule init
	"Initialize reporting."
=>
	(assert
		(reset-reports)
		(regen-reports)
	)
)


(defrule reset-reports
	"Eliminate existing report values."
	?cmd	<-	(reset-reports)
	(or 
		?s		<-	(high-score)
		?s		<-	(category-high-score)
	)
=>
	(retract ?s)
)


(defrule reports-reset
	"All report values reset."
	?cmd	<-	(reset-reports)
	(not 
		(or 
			(high-score) 
			(category-high-score)
		)
	)
=>
	(retract ?cmd)
)


(defrule gen-reports
	"Generate report values."
	?cmd <- (regen-reports)
	(not (reset-reports))
	(not (report))
=>
	(retract ?cmd)
	(assert (report))
)


(defrule regen-reports
	"Regenerate report values."
	?cmd <- (regen-reports)
	(not (reset-reports))
	?flag <- (report)
=>
	(retract ?cmd ?flag)
	(assert (report))
)


(defrule get-high-score
	"Report the highest score for the given category."
	(report)
	?cmd <-	(get-high-score ?category)
	?p   <-	(score
				(category ?category)
				(id ?id)
				(score ?score1)
			)
		
	(not 
		(score
			(category ?category)
			(score ?score2 & : (> ?score2 ?score1))
		)
	)
=>
	(retract ?cmd)
	(assert (category-high-score ?category ?score1))
)


(defrule get-high-score-properties
	"Once we know the highest score, retrieve properties."
	(report)
	?s <-	(category-high-score ?category ?score1)	
	?p <-	(score 
				(category ?category)
				(score ?score2 & : (= ?score2 ?score1))
				(property $?property)
			)
=>
	(assert (high-score ?category ?score2 $?property))
)


(defrule get-high-score-all
	"Call get-high-score on all categories."
	?cmd <- (report)
=>
	(assert
		(get-high-score beer)
		(get-high-score brewer)
		(get-high-score region)
		(get-high-score style)
		(get-high-score appearance-head)
		(get-high-score appearance-body)
		(get-high-score aroma)
		(get-high-score flavor)
		(get-high-score palate)
	)
)


(defrule print-high-score
	"Report the highest scoring properties of each category."
	(report)
	?s <- (high-score ?category ?score $?property)
=>
	;(retract ?s)
	(printout t 
		crlf "High " ?category " score (" ?score "): " (implode$ $?property)
	)
)

(defrule prompt-to-continue
	"Pause after reporting done."
	(declare (salience ?*priority-done*))

=>
	(printout t crlf vtab "(Press enter to continue...)" )
	(readline)

)
