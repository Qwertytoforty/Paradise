/obj/item/implant/emp
	name = "emp bio-chip"
	desc = "Triggers an EMP."
	icon_state = "emp"
	origin_tech = "biotech=3;magnets=4;syndicate=1"
	uses = 2
	implant_data = /datum/implant_fluff/emp
	implant_state = "implant-syndicate"

/obj/item/implant/emp/activate()
	uses--
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(empulse), get_turf(imp_in), 3, 5, 1)
	if(!uses)
		qdel(src)

/obj/item/implanter/emp
	name = "bio-chip implanter (EMP)"
	implant_type = /obj/item/implant/emp

/obj/item/implantcase/emp
	name = "bio-chip case - 'EMP'"
	desc = "A glass case containing an EMP bio-chip."
	implant_type = /obj/item/implant/emp


/obj/item/implant/mail
	name = "mail bio-chip"
	desc = "Triggers an EMP."
	icon_state = "emp"
	origin_tech = "biotech=3;magnets=4;syndicate=1"
	uses = -1
	implant_data = /datum/implant_fluff/emp
	implant_state = "implant-syndicate"

/obj/item/implant/mail/activate()
	if(!ishuman(imp_in))
		return
	var/mob/living/carbon/human/C = imp_in
	var/tag = input("Select the desired destination.", "Set Mail Tag", null) as null|anything in GLOB.TAGGERLOCATIONS

	if(!tag || GLOB.TAGGERLOCATIONS[tag])
		C.mail_destination = 0
		return

	to_chat(C, "<span class='notice'>You configure your internal beacon, tagging yourself for delivery to '[tag]'.</span>")
	C.mail_destination = GLOB.TAGGERLOCATIONS.Find(tag)

	//Auto flush if we use this verb inside a disposal chute.
	var/obj/machinery/disposal/D = C.loc
	if(istype(D))
		to_chat(C, "<span class='notice'>\The [D] acknowledges your signal.</span>")
		D.flush_count = D.flush_every_ticks
	return

/obj/item/implanter/mail
	name = "bio-chip implanter (mail)"
	implant_type = /obj/item/implant/mail

/obj/item/implantcase/mail
	name = "bio-chip case - 'mail'"
	desc = "A glass case containing an mail bio-chip."
	implant_type = /obj/item/implant/mail
