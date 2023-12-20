/obj/item/implant/shock
	name = "power bio-chip"
	desc = "A shockingly effective bio-chip for stunning or killing all those in your way. Do it."
	icon_state = "lighting_bolt"
	item_color = "r"
	origin_tech = "combat=5;magnets=3;biotech=4;syndicate=2"
	implant_data = /datum/implant_fluff/shock
	implant_state = "implant-syndicate" //
	var/enabled = TRUE
	var/old_mclick_override
	var/datum/middleClickOverride/shock_implant/mclick_override = new /datum/middleClickOverride/shock_implant
	var/last_shocked = 0
	var/shock_delay = 3 SECONDS
	var/unlimited_power = FALSE // Does this really need explanation?
	var/shock_range = 7


/obj/item/implant/shock/activate()
	enabled = !enabled
	to_chat(imp_in, "You toggle the implant [enabled? "on" : "off"]")
	if(enabled)
		if(imp_in.middleClickOverride)
			old_mclick_override = imp_in.middleClickOverride
		imp_in.middleClickOverride = mclick_override
	else
		if(old_mclick_override)
			imp_in.middleClickOverride = old_mclick_override
			old_mclick_override = null
		else
			imp_in.middleClickOverride = null

/obj/item/implant/shock/removed()
	if(old_mclick_override)
		imp_in.middleClickOverride = old_mclick_override
		old_mclick_override = null
	else
		imp_in.middleClickOverride = null
	return ..()

/obj/item/implanter/shock
	name = "bio-chip implanter (power)"
	implant_type = /obj/item/implant/shock

/obj/item/implantcase/shock
	name = "bio-chip case - 'power'"
	desc = "A glass case containing a power bio-chip."
	implant_type = /obj/item/implant/shock
