/obj/item/documents
	name = "secret documents"
	desc = "\"Top Secret\" documents printed on special copy-protected paper."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/documents/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(alert_admins_on_destroy))

/obj/item/documents/nanotrasen
	desc = "\"Top Secret\" Nanotrasen documents printed on special copy-protected paper. It is filled with complex diagrams and lists of names, dates and coordinates."
	icon_state = "docs_verified"

/obj/item/documents/nanotrasen/dvorak_blackbox
	name = "\improper D.V.O.R.A.K Blackbox Disk"
	desc = "This disk contains all the information D.V.O.R.A.K likely listend to overtime, not to mention what may have went wrong. NT might be interested in this."
	icon = 'icons/obj/module.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_state = "card-id"
	icon_state = "holodisk"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'

/obj/item/documents/syndicate
	desc = "\"Top Secret\" documents printed on special copy-protected paper. It details sensitive Syndicate operational intelligence."

/obj/item/documents/syndicate/red
	name = "'Red' secret documents"
	desc = "\"Top Secret\" documents printed on special copy-protected paper. It details sensitive Syndicate operational intelligence. These documents are marked \"Red\"."
	icon_state = "docs_red"

/obj/item/documents/syndicate/blue
	name = "'Blue' secret documents"
	desc = "\"Top Secret\" documents printed on special copy-protected paper. It details sensitive Syndicate operational intelligence. These documents are marked \"Blue\"."
	icon_state = "docs_blue"

/obj/item/documents/syndicate/yellow
	name = "'Yellow' secret documents"
	desc = "\"Top Secret\" documents printed on special copy-protected paper. It details sensitive Syndicate operational intelligence. These documents are marked \"Yellow\"."
	icon_state = "docs_yellow"
	resistance_flags = NONE

/obj/item/documents/syndicate/yellow/trapped
	desc = "\"Top Secret\" documents printed on special copy-protected paper. It details sensitive Syndicate operational intelligence. These documents are marked \"Yellow\", and have a thin film of clear material covering their surface."
	var/poison_type = "amanitin"
	var/poison_dose = 20
	var/poison_total = 60

/obj/item/documents/syndicate/mining
	desc = "\"Top Secret\" documents detailing Syndicate plasma mining operations."

/obj/item/documents/syndicate/yellow/trapped/pickup(user)
	if(ishuman(user) && poison_total > 0)
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(poison_type, poison_dose)
			poison_total -= poison_dose
			add_attack_logs(src, user, "Picked up [src], the trapped syndicate documents")
	return ..()
