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

(defrule gen-pref-scores
	"Generate scores for preferences."
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




;		(appearance-body $? ?body $?)
;	)


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

