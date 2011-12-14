;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FILE:	recommend.clp       
;;	AUTHOR:	Chris Wolverton
;;
;;	DESC:	Beer recommendation rules.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule RECOMMEND
	(import MAIN defglobal ?ALL)
	(import MAIN deftemplate initial-fact current-user score-map factor-map)
	(import BEER deftemplate beer brewer)
	(import PREFS deftemplate pref)

)


;; Template(s)
;; ============================================================================

(deftemplate score
	(slot id (default-dynamic (gensym*)))
	(slot category)
	(multislot property)
	(slot score (type NUMBER))
)

;; Rule(s): Calculations
;; ============================================================================

(defrule init
	"Initialize scoring."
	(declare (salience ?*priority-interrupt*))
=>
	(assert
		(reset-scores)
		(regen-scores)
	)
)

(defrule reset-scores
	"Eliminate all scores."
	(declare (salience ?*priority-command*))
	?cmd <- (reset-scores)
	?s <- (score)
=>
	(retract ?s)
)


(defrule scores-reset
	"All scores removed, kill command."
	(declare (salience ?*priority-command*))
	?cmd <- (reset-scores)
	(not (score))
=>
	(retract ?cmd)
)


(defrule gen-scores
	"Generate scores."
	(declare (salience ?*priority-command*))
	?cmd <- (regen-scores)
	(not (reset-scores)) ; Can't fire until reset-scores is cleared.
=>
	(retract ?cmd)
	(assert (calculate))
	
)


(defrule regen-scores
	"Regenerate scores."
	(declare (salience ?*priority-command*))
	?cmd <- (regen-scores)
	(not (reset-scores)) ; Can't fire until reset-scores is cleared.
	?calc <- (calculate)
=>
	(retract ?cmd ?calc)
	(assert (calculate))
	
)



(defrule gen-pref-scores
	"Generate scores for preferences."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category ?category)
		(property $?property)
		(rating ?rating)
	)
	(score-map ?rating ?score)
=>
	(assert
		(score
			(category ?category)
			(property $?property)
			(score ?score)
		)
	)
)

(defrule accumulate-scores
	"Sum scores with the same category and property."
	(calculate)
	?s1 <-	(score 
				(id ?id1)
				(category ?category) 
				(property $?property) 
				(score ?score1)
			)
			
	?s2 <-	(score
				(id ?id2 & ~?id1)
				(category ?category)
				(property $?property)
				(score ?score2)
			)
=>
	(retract ?s1 ?s2)
	(assert
		(score
			(category ?category)
			(property $?property)
			(score (+ ?score1 ?score2))
		)
	)

)

;; Rule(s): Suggestions
;; ============================================================================

(defrule under-age_non-alcoholic-bonus
	"Underaged persons should drink non-alcoholic beverages."
	(calculate)
	(current-user (age ?age & : (< ?age ?*legal-age*)))
	(beer
		(abv 0)
		(name $?beer)
	)
	(score-map mega-bonus ?score)
=>
	(assert
		(score 
			(category beer)
			(property $?beer)
			(score ?score)
		)
	)
)


(defrule under-age_alcoholic-malus
	"Underaged person should not drink alcoholic berages."
	(calculate)
	(current-user (age ?age & : (< ?age ?*legal-age*)))	
	(beer
		(abv ?abv & :(< 0 ?abv))
		(name $?beer)
	)
	(score-map mega-malus ?score)
=>
	(assert
		(score
			(category beer)
			(property $?beer)
			(score ?score)
		)
	)
)


(defrule beer-to-brewer-modifier
	"Liking a specific beer means they may like the brewery."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category beer) 
		(property $?beer)
		(rating ?rating)
	)
	(beer
		(name $?beer)
		(brewer $?target)
	)
	(score-map ?rating ?score)
	(factor-map ?cat & brewer ?factor)
=>
	(assert
		(score
			(category ?cat)
			(property $?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule beer-to-style-modifier
	"Liking a specific beer means they may like the brew style."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category beer)
		(property $?beer)
		(rating ?rating)
	)
	(beer
		(name $?beer)
		(style $?target)
	)
	(score-map ?rating ?score)
	(factor-map ?cat & style ?factor)
=>
	(assert
		(score
			(category ?cat)
			(property $?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule beer-to-aroma-modifier
	"Liking a specific beer means they may like the aromas of this brew."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category beer)
		(property $?beer)
		(rating ?rating)
	)
	(beer
		(name $?beer)
		(aroma $? ?target $?)
	)
	(score-map ?rating ?score)
	(factor-map ?cat & aroma ?factor)
=>
	(assert
		(score
			(category ?cat)
			(property ?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule beer-to-head-appearance-modifier
	"Liking a specific beer means they may like the look of the brew head."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category beer)
		(property $?beer)
		(rating ?rating)
	)
	(beer
		(name $?beer)
		(appearance-head $? ?target $?)
	)
	(score-map ?rating ?score)
	(factor-map ?cat & appearance-head ?factor)
=>
	(assert
		(score
			(category ?cat)
			(property ?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule beer-to-body-appearance-modifier
	"Liking a specific beer means they may like the look of the brew body."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category beer)
		(property $?beer)
		(rating ?rating)
	)
	(beer
		(name $?beer)
		(appearance-body $? ?target $?)
	)
	(score-map ?rating ?score)
	(factor-map ?cat & appearance-body ?factor)
=>
	(assert
		(score
			(category ?cat)
			(property ?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule beer-to-flavor-modifier
	"Liking a specific beer means they may like individual flavors."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category beer)
		(property $?beer)
		(rating ?rating)
	)
	(beer
		(name $?beer)
		(flavor $? ?target $?)
	)
	(score-map ?rating ?score)
	(factor-map ?cat & flavor ?factor)
=>
	(assert
		(score
			(category ?cat)
			(property ?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule beer-to-palate-modifier
	"Liking a specific beer means they may like the palate components."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category beer)
		(property $?beer)
		(rating ?rating)
	)
	(beer
		(name $?beer)
		(palate $? ?target $?)
	)
	(score-map ?rating ?score)
	(factor-map ?cat & palate ?factor)
=>
	(assert
		(score
			(category ?cat)
			(property ?target)
			(score (* ?score ?factor))
		)
	)
)


; style => beer score bonus
; aroma => beer score bonus
; appearance => beer score bonus
; flavor => beer score bonus
; palate => beer score bonus
; brewer => beer score bonus
; region => beer score bonus
; beer => aroma/appearance/flavor/palate/brewer/region/style score bonus
; 

; NEED TO ENCODE THIS KIND OF INFO BELOW! Perhaps in explore section...
; or just wing it with flavor prefs for now? Or make explore rules that enforce
; flavor prefs! Yes. Make a questionairre!

;(defrule :wine-drinkers-like-belgian

