/datum/uplink_item/special
	category = "Special Offers"
	cant_discount = TRUE
	surplus = 0
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST, UPLINK_TYPE_TRAITOR, UPLINK_TYPE_SIT)

/datum/uplink_item/special/autosurgeon
	name = "Syndicate Autosurgeon"
	desc = "A multi-use autosurgeon for implanting whatever you want into yourself. Rip that station apart and make it part of you."
	reference = "SACR"
	item = /obj/item/autosurgeon/organ/syndicate
	cost = 25

/datum/uplink_item/special/autosurgeon/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		excludefrom -= UPLINK_TYPE_TRAITOR
