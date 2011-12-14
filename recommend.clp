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
	(import EXPLORE deftemplate questionnaire-input)
	(export deftemplate score)
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
	"Maps quantifies the rating scale."
	; Ratings
	(score-map 	hate		 -15.0)	; "Reaction to unpleasant > great"
	(score-map 	dislike		  -7.0)
	(score-map 	neutral		   2.0) ; "It's okay"
	(score-map 	like		   5.0)
	(score-map 	love		  10.0)
	
	; SPECIAL Bonus/Malus
	(score-map 	mega-bonus  1000.0)
	(score-map 	mega-malus -1000.0)
	
)

(deffacts factor-mapping
	"Maps a bonus factor from one property to another."
	(factor-map 	beer2brewer		.40)
	(factor-map 	brewer2beer		.55)
	(factor-map 	beer2style		.65)
	(factor-map 	style2beer		.55)
	(factor-map 	beer2aroma		.60)
	(factor-map 	aroma2beer		.40)
	(factor-map 	beer2head		.10)
	(factor-map 	head2beer		.10)
	(factor-map 	beer2body		.30)
	(factor-map 	body2beer		.20)
	(factor-map 	beer2flavor		.50)
	(factor-map		flavor2beer		.60)
	(factor-map 	beer2palate		.30)
	(factor-map 	palate2beer		.25)
	(factor-map		beer2region		.20)
	(factor-map		region2beer		.33)
	(factor-map		region2brewer	.70)	
	(factor-map		brewer2region	.15)
	(factor-map		wine2belgian	.65)

)


;; Rule(s): Calculations
;; ============================================================================

(defrule init
	"Initialize scoring."
=>
	(assert
		(reset-scores)
		(regen-scores)
	)
)

(defrule reset-scores
	"Eliminate all scores."
	?cmd <- (reset-scores)
	?s <- (score)
=>
	(retract ?s)
)


(defrule scores-reset
	"All scores removed, kill command."
	?cmd <- (reset-scores)
	(not (score))
=>
	(retract ?cmd)
)


(defrule gen-scores
	"Generate scores."
	?cmd <- (regen-scores)
	(not (reset-scores)) ; Can't fire until reset-scores is cleared.
	(not (calculate))
=>
	(retract ?cmd)
	(assert (calculate))
)


(defrule regen-scores
	"Regenerate scores."
	?cmd <- (regen-scores)
	(not (reset-scores)) ; Can't fire until reset-scores is cleared.
	?flag <- (calculate)
=>
	(retract ?cmd ?flag)
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
	(factor-map beer2brewer ?factor)
=>
	(assert
		(score
			(category brewer)
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
	(factor-map beer2region ?factor)
=>
	(assert
		(score
			(category region)
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
	(factor-map beer2style ?factor)
=>
	(assert
		(score
			(category style)
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
	(factor-map beer2aroma ?factor)
=>
	(assert
		(score
			(category aroma)
			(property ?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule beer-to-head-modifier
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
	(factor-map beer2head ?factor)
=>
	(assert
		(score
			(category appearance-head)
			(property ?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule beer-to-body-modifier
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
	(factor-map beer2body ?factor)
=>
	(assert
		(score
			(category appearance-body)
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
	(factor-map beer2flavor ?factor)
=>
	(assert
		(score
			(category flavor)
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
	(factor-map beer2palate ?factor)
=>
	(assert
		(score
			(category palate)
			(property ?target)
			(score (* ?score ?factor))
		)
	)
)


(defrule brewer-to-beer-modifier
	"Liking a brewer improves chances of liking any of their beer."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category brewer)
		(property $?brewer)
		(rating ?rating)
	)
	(beer
		(name $?beer)
		(brewer $?brewer)
	)
	(score-map ?rating ?score)
	(factor-map brewer2beer ?factor)
=>
	(assert
			(score
				(category beer)
				(property ?beer)
				(score (* ?score ?factor))
			)
	)
)


(defrule style-to-beer-modifier
	"Liking a style improves chances of liking a beer in that style."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category style)
		(property $?style)
		(rating ?rating)
	)
	(beer
		(style $?style)
		(name $?beer)
	)
	(score-map ?rating ?score)
	(factor-map style2beer ?factor)
=>
	(assert
			(score
				(category beer)
				(property ?beer)
				(score (* ?score ?factor))
			)
	)
)


(defrule aroma-to-beer-modifier
	"Liking an aroma improves chances of liking a utilizing beer."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category aroma)
		(property $?aroma)
		(rating ?rating)
	)
	(beer
		(aroma $? $?aroma $?)
		(name $?beer)
	)
	(score-map ?rating ?score)
	(factor-map aroma2beer ?factor)
=>
	(assert
			(score
				(category beer)
				(property ?beer)
				(score (* ?score ?factor))
			)
	)
)


(defrule head-to-beer-modifier
	"Appearance of head pref's may affect opinion of a given beer."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category appearance-head)
		(property $?head)
		(rating ?rating)
	)
	(beer
		(appearance-head $? $?head $?)
		(name $?beer)
	)
	(score-map ?rating ?score)
	(factor-map head2beer ?factor)
=>
	(assert
			(score
				(category beer)
				(property ?beer)
				(score (* ?score ?factor))
			)
	)
)


(defrule body-to-beer-modifier
	"Appearance of body pref's may affect opinion of a given beer."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category appearance-body)
		(property $?body)
		(rating ?rating)
	)
	(beer
		(appearance-body $? $?body $?)
		(name $?beer)
	)
	(score-map ?rating ?score)
	(factor-map body2beer ?factor)
=>
	(assert
			(score
				(category beer)
				(property ?beer)
				(score (* ?score ?factor))
			)
	)
)


(defrule flavor-to-beer-modifier
	"opinion on flavors will impact beer enjoyment."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category flavor)
		(property $?flavor)
		(rating ?rating)
	)
	(beer
		(flavor $? $?flavor $?)
		(name $?beer)
	)
	(score-map ?rating ?score)
	(factor-map flavor2beer ?factor)
=>
	(assert
			(score
				(category beer)
				(property ?beer)
				(score (* ?score ?factor))
			)
	)
)


(defrule palate-to-beer-modifier
	"opinion on palate will impact beer enjoyment."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category palate)
		(property $?palate)
		(rating ?rating)
	)
	(beer
		(flavor $? $?palate $?)
		(name $?beer)
	)
	(score-map ?rating ?score)
	(factor-map palate2beer ?factor)
=>
	(assert
			(score
				(category beer)
				(property ?beer)
				(score (* ?score ?factor))
			)
	)
)


(defrule region-to-beer-modifier
	"Liking a region may cause a regional preference."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category region) 
		(property $?region)
		(rating ?rating)
	)
	(brewer
		(region $?region)
		(name $?brewery)
	)
	(beer
		(brewer $?brewery)
		(name $?beer)
	)
	(score-map ?rating ?score)
	(factor-map region2beer ?factor)
=>
	(assert
		(score
			(category beer)
			(property $?beer)
			(score (* ?score ?factor))
		)
	)
)


(defrule region-to-brewer-modifier
	"Liking a region may cause a regional brewer preference."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category region) 
		(property $?region)
		(rating ?rating)
	)
	(brewer
		(region $?region)
		(name $?brewery)
	)
	(score-map ?rating ?score)
	(factor-map region2brewer ?factor)
=>
	(assert
		(score
			(category brewer)
			(property $?brewery)
			(score (* ?score ?factor))
		)
	)
)


(defrule brewer-to-region-modifier
	"Liking a brewer may show a regional preference."
	(calculate)
	(current-user (name ?user))
	(pref
		(user ?user)
		(category brewer) 
		(property $?brewery)
		(rating ?rating)
	)
	(brewer
		(name $?brewery)
		(region $?region)
	)
	(score-map ?rating ?score)
	(factor-map brewer2region ?factor)
=>
	(assert
		(score
			(category region)
			(property $?region)
			(score (* ?score ?factor))
		)
	)
)


(defrule wine-drinkers-like-belgian-ales1
	"People who like wine tend to like belgian style beers."
	(calculate)
	(pref
		(user ?user)
		(category flavor) 
		(property wine)
		(rating ?rating & neutral | like | love)
	)
	(beer
		(style $?style
				& : (eq $?style (create$ belgian dark ale))
				| : (eq $?style (create$ belgian ipa))
				| : (eq $?style (create$ belgian pale ale))
				| : (eq $?style (create$ belgian strong dark ale))
				| : (eq $?style (create$ belgian strong pale ale))
				| : (eq $?style (create$ biere de champagne))
				| : (eq $?style (create$ biere brut))
				| : (eq $?style (create$ biere de champagne biere brut))
				| : (eq $?style (create$ biere de garde))
				| : (eq $?style (create$ dubbel))
				| : (eq $?style (create$ faro))
				| : (eq $?style (create$ flanders oud bruin))
				| : (eq $?style (create$ flanders red ale))
				| : (eq $?style (create$ gueuze))
				| : (eq $?style (create$ lambic))
				| : (eq $?style (create$ lambic fruit))
				| : (eq $?style (create$ lambic unblended))
				| : (eq $?style (create$ quad))
				| : (eq $?style (create$ quadrupel))
				| : (eq $?style (create$ saison))
				| : (eq $?style (create$ farmhouse ale))
				| : (eq $?style (create$ saison farmhouse ale))
				| : (eq $?style (create$ tripel))
				| : (eq $?style (create$ witbier))
		)
		(name $?beer)
	)
	(score-map ?rating ?score)
	(factor-map wine2belgian ?factor)
=>
	(assert
		(score
			(category beer)
			(property $?beer)
			(score (* ?score ?factor))
		)
	)
)


(defrule wine-drinkers-like-belgian-ales2
	"People who like wine tend to like belgian style beers."
	(calculate)
	(questionnaire-input wine yes)
	(beer
		(style $?style
			& : (eq $?style (create$ belgian dark ale))
			| : (eq $?style (create$ belgian ipa))
			| : (eq $?style (create$ belgian pale ale))
			| : (eq $?style (create$ belgian strong dark ale))
			| : (eq $?style (create$ belgian strong pale ale))
			| : (eq $?style (create$ biere de champagne))
			| : (eq $?style (create$ biere brut))
			| : (eq $?style (create$ biere de champagne biere brut))
			| : (eq $?style (create$ biere de garde))
			| : (eq $?style (create$ dubbel))
			| : (eq $?style (create$ faro))
			| : (eq $?style (create$ flanders oud bruin))
			| : (eq $?style (create$ flanders red ale))
			| : (eq $?style (create$ gueuze))
			| : (eq $?style (create$ lambic))
			| : (eq $?style (create$ lambic fruit))
			| : (eq $?style (create$ lambic unblended))
			| : (eq $?style (create$ quad))
			| : (eq $?style (create$ quadrupel))
			| : (eq $?style (create$ saison))
			| : (eq $?style (create$ farmhouse ale))
			| : (eq $?style (create$ saison farmhouse ale))
			| : (eq $?style (create$ tripel))
			| : (eq $?style (create$ witbier))
		)
		(name $?beer)
	)
	(score-map like ?score)
	(factor-map wine2belgian ?factor)
=>
	(assert
		(score
			(category beer)
			(property $?beer)
			(score (* ?score ?factor))
		)
	)
)


(defrule wine-drinkers-like-belgian-ales-style1
	"People who like wine tend to like belgian style beers."
	(calculate)
	(pref
		(user ?user)
		(category flavor) 
		(property wine)
		(rating ?rating & neutral | like | love)
	)
	(score-map ?rating ?score)
	(factor-map wine2belgian ?factor)	
=>	
	(assert
		(score
			(category style)
			(property belgian dark ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property belgian ipa)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property belgian pale ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property belgian strong dark ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property belgian strong pale ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property biere de champagne)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property biere brut)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property biere de champagne biere brut)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property biere de garde)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property dubbel)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property faro)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property flanders oud bruin)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property flanders red ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property gueuze)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property lambic)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property lambic fruit)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property lambic unblended)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property quad)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property quadrupel)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property saison)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property farmhouse ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property saison farmhouse ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property tripel)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property witbier)
			(score (* ?score ?factor))
		)
	)
)


(defrule wine-drinkers-like-belgian-ales-style2
	"People who like wine tend to like belgian style beers."
	(calculate)
	(questionnaire-input wine yes)
	(score-map like ?score)
	(factor-map wine2belgian ?factor)	
=>	
	(assert
		(score
			(category style)
			(property belgian dark ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property belgian ipa)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property belgian pale ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property belgian strong dark ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property belgian strong pale ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property biere de champagne)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property biere brut)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property biere de champagne biere brut)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property biere de garde)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property dubbel)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property faro)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property flanders oud bruin)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property flanders red ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property gueuze)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property lambic)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property lambic fruit)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property lambic unblended)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property quad)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property quadrupel)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property saison)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property farmhouse ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property saison farmhouse ale)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property tripel)
			(score (* ?score ?factor))
		)
		(score
			(category style)
			(property witbier)
			(score (* ?score ?factor))
		)
	)
)
