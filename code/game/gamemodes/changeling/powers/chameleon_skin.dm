/datum/action/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Our skin pigmentation rapidly changes to suit our current environment. Costs 20 chemicals."
	helptext = "Allows us to become invisible after a few seconds of standing still. Can be toggled on and off."
	button_icon_state = "chameleon_skin"
	dna_cost = 2
	chemical_cost = 20
	req_human = 1

/datum/action/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/H = user //SHOULD always be human, because req_human = 1
	if(!istype(H)) // req_human could be done in can_sting stuff.
		return
	if(H.dna.GetSEState(GLOB.chameleonblock))
		H.dna.SetSEState(GLOB.chameleonblock, 0)
		genemutcheck(H, GLOB.chameleonblock, null, MUTCHK_FORCED)
	else
		H.dna.SetSEState(GLOB.chameleonblock, 1)
		genemutcheck(H, GLOB.chameleonblock, null, MUTCHK_FORCED)

	feedback_add_details("changeling_powers","CS")
	return TRUE

/datum/action/changeling/chameleon_skin/Remove(mob/user)
	var/mob/living/carbon/C = user
	if(C.dna.GetSEState(GLOB.chameleonblock))
		C.dna.SetSEState(GLOB.chameleonblock, 0)
		genemutcheck(C, GLOB.chameleonblock, null, MUTCHK_FORCED)
	..()
