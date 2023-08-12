/obj/item/clothing/head/helmet/space/time
	name = "time helmet"
	desc = "Though it possesses no special abilities of its own, this helmet is necessary to properly seal a time suit."
	icon_state = "time_helmet"
	item_state = "time_helmet"
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 25, BIO = INFINITY, RAD = 25, FIRE = INFINITY, ACID = INFINITY)
	siemens_coefficient = 0.6
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/head/helmet/space/time/equipped(mob/living/carbon/human/H, slot)
	..()
	if(item_action_slot_check(slot, H))
		var/obj/item/clothing/suit/space/time/T = H.get_item_by_slot(slot_wear_suit)
		if(istype(T))
			T.activate_suit(H)

/obj/item/clothing/head/helmet/space/time/item_action_slot_check(slot, mob/user)
	if(slot == slot_head)
		return 1

/obj/item/clothing/head/helmet/space/time/dropped(mob/user)
	..()
	var/obj/item/clothing/suit/space/time/T = user.get_item_by_slot(slot_wear_suit)
	if(istype(T))
		T.deactivate_suit(user)

/obj/item/clothing/suit/space/time
	name = "time suit"
	desc = "In addition to possessing various time-related abilities, this suit is capable of separating the flow of time inside it from the flow of time outside it, when properly sealed."
	icon_state = "time_suit"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 0
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 25, BIO = INFINITY, RAD = 25, FIRE = INFINITY, ACID = INFINITY)
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/gun, /obj/item/grenade)
	siemens_coefficient = 0.6
	var/suit_active = FALSE

/obj/item/clothing/suit/space/time/proc/activate_suit(mob/living/carbon/human/H)
	if(!istype(H))
		return
	suit_active = TRUE
	H.flags_2 |= TIMELESS_2
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/time_suit/timestop)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/time_suit/future)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/time_suit/past)
	playsound(src, 'sound/effects/timesuit_activate.ogg', 50)

/obj/item/clothing/suit/space/time/proc/deactivate_suit(mob/living/carbon/human/H)
	if(!istype(H))
		return
	suit_active = FALSE
	H.flags_2 &= ~TIMELESS_2
	H.mind.RemoveSpell(/obj/effect/proc_holder/spell/aoe/conjure/time_suit/timestop)
	H.mind.RemoveSpell(/obj/effect/proc_holder/spell/aoe/conjure/time_suit/future)
	H.mind.RemoveSpell(/obj/effect/proc_holder/spell/aoe/conjure/time_suit/past)
	playsound(src, 'sound/effects/timesuit_deactivate.ogg', 50)

/obj/item/clothing/suit/space/time/equipped(mob/living/carbon/human/H, slot)
	..()
	if(item_action_slot_check(slot, H))
		if(istype(H.get_item_by_slot(slot_head), /obj/item/clothing/head/helmet/space/time))
			activate_suit(H)

/obj/item/clothing/suit/space/time/item_action_slot_check(slot, mob/user)
	if(slot == slot_wear_suit)
		return 1

/obj/item/clothing/suit/space/time/dropped(mob/user)
	..()
	deactivate_suit(user)

/obj/effect/proc_holder/spell/aoe/conjure/time_suit/
	name = "ERROR"
	desc = "Report to coder"
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	invocation = null
	invocation_type = "NONE"
	summon_amt = 1
	action_icon_state = "time_stop"
	summon_type = list(/obj/effect/particle_effect/sparks)
	aoe_range = 0


/obj/effect/proc_holder/spell/aoe/conjure/time_suit/timestop
	name = "Stop Time"
	desc = "Halt the progression of time in a small area for 10 seconds."

/obj/effect/proc_holder/spell/aoe/conjure/time_suit/timestop/cast(list/targets, mob/living/user)
	. = ..()
	new /obj/effect/timestop/timeagent(get_turf(user), user, 10 SECONDS)

/obj/effect/proc_holder/spell/aoe/conjure/time_suit/future
	name = "Jump to Future"
	desc = "Jump ten seconds into the future."
	base_cooldown = 30 SECONDS
	action_icon_state = "time_future"

/obj/effect/proc_holder/spell/aoe/conjure/time_suit/future/cast(list/targets, mob/living/user)
	. = ..()
	future_rift(user, 10 SECONDS, 1, TRUE, TRUE)


/obj/effect/proc_holder/spell/aoe/conjure/time_suit/past
	name = "Jump to Past"
	desc = "Prepare the suit for a jump to the past and execute it after ten seconds."
	base_cooldown = 60 SECONDS
	action_icon_state = "time_past"

/obj/effect/proc_holder/spell/aoe/conjure/time_suit/past/cast(list/targets, mob/living/user)
	. = ..()
	past_rift(user, 10 SECONDS, 1, TRUE, TRUE)
