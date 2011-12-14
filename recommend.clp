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
	(import MAIN deftemplate initial-fact current-user)
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

;; Some facts used as constants!
;; ============================================================================

(deffacts score-mapping
	"Maps a score to it's value."
	; Ratings
	(score-map 	hate		 -10.0)
	(score-map 	dislike		  -5.0)
	(score-map 	neutral		   2.0) ; "It's okay"
	(score-map 	like		   5.0)
	(score-map 	love		  10.0)
	
	; Bonus/Malus
	(score-map 	mega-bonus  1000.0)
	(score-map 	mega-malus -1000.0)
	
)

(deffacts factor-mapping
	"Maps a factor to it's value."
	(factor-map 	brewer			.40)
	(factor-map 	style			.60)
	(factor-map 	aroma			.50)
	(factor-map 	appearance-head	.10)
	(factor-map 	appearance-body	.30)
	(factor-map 	flavor			.50)
	(factor-map 	palate			.30)
	(factor-map		region			.20)
)


;; Rule(s): Calculations
;; ============================================================================

(defrule init
	"Initialize scoring."
;	(declare (salience ?*priority-interrupt*))
=>
	(assert
		(reset-scores)
		(regen-scores)
	)
)

(defrule reset-scores
	"Eliminate all scores."
;	(declare (salience ?*priority-command*))
	?cmd <- (reset-scores)
	?s <- (score)
=>
	(retract ?s)
)


(defrule scores-reset
	"All scores removed, kill command."
;	(declare (salience ?*priority-command*))
	?cmd <- (reset-scores)
	(not (score))
=>
	(retract ?cmd)
)


(defrule gen-scores
	"Generate scores."
;	(declare (salience ?*priority-command*))
	?cmd <- (regen-scores)
	(not (reset-scores)) ; Can't fire until reset-scores is cleared.
=>
	(retract ?cmd)
	(assert (calculate))
	
)


(defrule regen-scores
	"Regenerate scores."
;	(declare (salience ?*priority-command*))
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


;; Rule(s): Reporting
;; ============================================================================

(defrule get-highest-score
	"Report the highest scoring property for the given category."
	?cmd <- (get-highest-score ?category)
	?p  <- (score
				(category ?category)
				(id ?id)
				(score ?score1)
				(property $?property1)
			)
	(not 
		(score
			(category ?category)
			(score ?score2 & : (> ?score2 ?score1))
		)
	)
=>
	(retract ?cmd)
	(assert (highest-score ?category ?score1 ?id))
)

(defrule tied-highest-score
	"Once we know the highest score, search for matching scores."
	?s <- (highest-score ?category ?score1 ?id1)
	?tied <- (score 
				(category ?category)
				(id ?id2 & ~?id1)
				(score ?score2 & : (= ?score2 ?score1))
			 )
=>
	(assert (highest-score ?category ?score2 ?id2))
)

(defrule get-highest-score-all
	"Call get-highest-score on all categories."
	?cmd <- (get-highest-score-all)
=>
	(retract ?cmd)
	(assert
		(get-highest-score beer)
		(get-highest-score brewer)
		(get-highest-score region)
		(get-highest-score style)
		(get-highest-score appearance-head)
		(get-highest-score appearance-body)
		(get-highest-score aroma)
		(get-highest-score flavor)
		(get-highest-score palate)
	)
)

(defrule combine-highest)
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


(defrule beer-to-region-modifier
	"Liking a specific beer may imply liking beers from its region of origin."
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
		(brewer $?brewery)
	)
	(brewer
		(name $?brewery)
		(region $?target)
	)
	(score-map ?rating ?score)
	(factor-map ?cat & region ?factor)
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

