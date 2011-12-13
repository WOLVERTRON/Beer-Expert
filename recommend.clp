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
	(slot score (type INTEGER))
)

;; Rule(s)
;; ============================================================================

(defrule gen-scores_pref-hate
	"Genereate scores for preferences rated hate."
	(current-user (name ?user))
	(pref
		(rating hate)
		(user ?user)
		(category ?category)
		(property $?property)
	)
=>
	(assert
		(score
			(category ?category)
			(property $?property)
			(score ?*hate*)
		)
	)
)

(defrule gen-scores_pref-dislike
	"Genereate scores for preferences rated dislike."
	(current-user (name ?user))
	(pref
		(rating dislike)
		(user ?user)
		(category ?category)
		(property $?property)
	)
=>
	(assert
		(score
			(category ?category)
			(property $?property)
			(score ?*dislike*)
		)
	)
)


(defrule gen-scores_pref-neutral
	"Genereate scores for preferences rated neutral."
	(current-user (name ?user))
	(pref
		(rating neutral)
		(user ?user)
		(category ?category)
		(property $?property)
	)
=>
	(assert
		(score
			(category ?category)
			(property $?property)
			(score ?*neutral*)
		)
	)
)


(defrule gen-scores_pref-like
	"Genereate scores for preferences rated like."
	(current-user (name ?user))
	(pref
		(rating like)
		(user ?user)
		(category ?category)
		(property $?property)
	)
=>
	(assert
		(score
			(category ?category)
			(property $?property)
			(score ?*like*)
		)
	)
)


(defrule gen-scores_pref-love
	"Genereate scores for preferences rated love."
	(current-user (name ?user))
	(pref
		(rating love)
		(user ?user)
		(category ?category)
		(property $?property)
	)
=>
	(assert
		(score
			(category ?category)
			(property $?property)
			(score ?*love*)
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

; under age => ONLY non-alcoholic
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

