//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

//Returns the thing in our active hand
/mob/proc/get_active_hand()
	if(hand)	return l_hand
	else		return r_hand

/// Specal proc for special mobs that use "hands" in weird ways
/mob/proc/special_get_hands_check()
	return

/mob/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1


	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_quick_equip)))

///proc extender of [/mob/verb/quick_equip] used to make the verb queuable if the server is overloaded
/mob/proc/run_quick_equip()
	var/obj/item/I = get_active_hand()
	if(I)
		I.equip_to_best_slot(src)

/mob/proc/is_in_active_hand(obj/item/I)
	var/obj/item/item_to_test = get_active_hand()

	return item_to_test && item_to_test.is_equivalent(I)

/// Check if an item is in one of our hands
/mob/proc/is_holding(obj/item/I)
	return istype(I) && (I == r_hand || I == l_hand)

//Checks if we're holding an item of type: typepath
/mob/proc/is_holding_item_of_type(typepath)
	for(var/obj/item/I in list(l_hand, r_hand))
		if(istype(I, typepath))
			return I
	return FALSE

//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	if(hand)	return r_hand
	else		return l_hand

/mob/proc/is_in_inactive_hand(obj/item/I)
	var/obj/item/item_to_test = get_inactive_hand()

	return item_to_test && item_to_test.is_equivalent(I)

//Returns if a certain item can be equipped to a certain slot.
// Currently invalid for two-handed items - call obj/item/mob_can_equip() instead.
/mob/proc/can_equip(obj/item/I, slot, disable_warning = 0)
	return 0

// Because there's several different places it's stored.
/mob/proc/get_multitool(if_active=0)
	return null

/mob/proc/put_in_hand(obj/item/I, slot)
	switch(slot)
		if(SLOT_HUD_LEFT_HAND)
			return put_in_l_hand(I)
		if(SLOT_HUD_RIGHT_HAND)
			return put_in_r_hand(I)

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(obj/item/W, skip_blocked_hands_check = FALSE)
	if(!put_in_hand_check(W, skip_blocked_hands_check))
		return FALSE
	if(!l_hand && has_left_hand())
		W.forceMove(src)		//TODO: move to equipped?
		l_hand = W
		W.layer = ABOVE_HUD_LAYER	//TODO: move to equipped?
		W.plane = ABOVE_HUD_PLANE	//TODO: move to equipped?
		W.equipped(src, SLOT_HUD_LEFT_HAND)
		if(pulling == W)
			stop_pulling()
		update_inv_l_hand()
		return TRUE
	return FALSE

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(obj/item/W, skip_blocked_hands_check = FALSE)
	if(!put_in_hand_check(W, skip_blocked_hands_check))
		return 0
	if(!r_hand && has_right_hand())
		W.forceMove(src)
		r_hand = W
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		W.equipped(src,SLOT_HUD_RIGHT_HAND)
		if(pulling == W)
			stop_pulling()
		update_inv_r_hand()
		return 1
	return 0

/mob/proc/put_in_hand_check(obj/item/W, skip_blocked_hands_check)
	if(!istype(W) || QDELETED(W))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_ABSTRACT_HANDS) && !(W.flags & ABSTRACT))
		return FALSE
	return TRUE

/mob/living/put_in_hand_check(obj/item/W, skip_blocked_hands_check)
	. = ..()
	if(!skip_blocked_hands_check && HAS_TRAIT(src, TRAIT_HANDS_BLOCKED) && !(W.flags & ABSTRACT))
		. = FALSE

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(obj/item/W)
	if(hand)
		return put_in_l_hand(W)
	else
		return put_in_r_hand(W)

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(obj/item/W)
	if(hand)	return put_in_r_hand(W)
	else		return put_in_l_hand(W)

//Puts the item our active hand if possible. Failing that it tries our inactive hand. Returns 1 on success.
//If both fail it drops it on the floor and returns 0.
//This is probably the main one you need to know :)
//Just puts stuff on the floor for most mobs, since all mobs have hands but putting stuff in the AI/corgi/ghost hand is VERY BAD.
/mob/proc/put_in_hands(obj/item/W)
	W.forceMove(drop_location())
	W.layer = initial(W.layer)
	W.plane = initial(W.plane)
	W.dropped(src)

/mob/proc/drop_item_v()		//this is dumb.
	if(stat == CONSCIOUS && isturf(loc))
		SEND_SIGNAL(usr, COMSIG_MOB_WILLINGLY_DROP)
		return drop_item()
	return 0

//Drops the item in our left hand
/mob/proc/drop_l_hand(force = FALSE)
	return unEquip(l_hand, force) //All needed checks are in unEquip

//Drops the item in our right hand
/mob/proc/drop_r_hand(force = FALSE)
	return unEquip(r_hand, force) //Why was this not calling unEquip in the first place jesus fuck.

//Drops the item in our active hand.
/mob/proc/drop_item()
	if(hand)
		return drop_l_hand()
	else
		return drop_r_hand()

//Here lie unEquip and before_item_take, already forgotten and not missed.

/mob/proc/canUnEquip(obj/item/I, force)
	if(!I)
		return TRUE
	if((I.flags & NODROP) && !force)
		return FALSE

	if((SEND_SIGNAL(I, COMSIG_ITEM_PRE_UNEQUIP, force) & COMPONENT_ITEM_BLOCK_UNEQUIP) && !force)
		return FALSE

	return TRUE

/mob/proc/unEquip(obj/item/I, force, silent = FALSE) //Force overrides NODROP for things like wizarditis and admin undress.
	if(!I) //If there's nothing to drop, the drop is automatically succesfull. If(unEquip) should generally be used to check for NODROP.
		return 1

	if(!canUnEquip(I, force))
		return 0

	if(I == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if(I == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if(I in tkgrabbed_objects)
		var/obj/item/tk_grab/tkgrab = tkgrabbed_objects[I]
		unEquip(tkgrab, force)

	if(I)
		if(client)
			client.screen -= I
		I.forceMove(drop_location())
		I.dropped(src, silent)
		if(I)
			I.layer = initial(I.layer)
			I.plane = initial(I.plane)
	return 1


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(obj/O)
	unEquip(O)
	O.screen_loc = null
	return 1


//Outdated but still in use apparently. This should at least be a human proc.
//Daily reminder to murder this - Remie.
/mob/proc/get_equipped_items(include_pockets = FALSE)
	var/list/items = list()
	if(back)
		items += back
	if(wear_mask)
		items += wear_mask
	return items

/mob/living/carbon/get_equipped_items(include_pockets = FALSE)
	var/list/items = ..()
	if(wear_suit)
		items += wear_suit
	if(head)
		items += head
	return items

/mob/living/carbon/human/get_equipped_items(include_pockets = FALSE)
	var/list/items = ..()
	if(belt)
		items += belt
	if(l_ear)
		items += l_ear
	if(r_ear)
		items += r_ear
	if(glasses)
		items += glasses
	if(gloves)
		items += gloves
	if(shoes)
		items += shoes
	if(wear_id)
		items += wear_id
	if(wear_pda)
		items += wear_pda
	if(w_uniform)
		items += w_uniform
	if(include_pockets)
		if(l_store)
			items += l_store
		if(r_store)
			items += r_store
		if(s_store)
			items += s_store
	return items

/mob/living/proc/unequip_everything()
	var/list/items = list()
	items |= get_equipped_items(TRUE)
	for(var/I in items)
		unEquip(I)
	drop_l_hand()
	drop_r_hand()

/obj/item/proc/equip_to_best_slot(mob/M)
	if(src != M.get_active_hand())
		to_chat(M, "<span class='warning'>You are not holding anything to equip!</span>")
		return FALSE

	if(M.equip_to_appropriate_slot(src))
		if(M.hand)
			M.update_inv_l_hand()
		else
			M.update_inv_r_hand()
		return TRUE

	if(M.s_active && M.s_active.can_be_inserted(src, TRUE))	//if storage active insert there
		M.s_active.handle_item_insertion(src, M)
		return TRUE

	var/obj/item/storage/S = M.get_inactive_hand()
	if(istype(S) && S.can_be_inserted(src, M, TRUE))	//see if we have box in other hand
		S.handle_item_insertion(src, M)
		return TRUE

	S = M.get_item_by_slot(SLOT_HUD_WEAR_ID)
	if(istype(S) && S.can_be_inserted(src, TRUE))		//else we put in a wallet
		S.handle_item_insertion(src, M)
		return TRUE

	S = M.get_item_by_slot(SLOT_HUD_BELT)
	if(istype(S) && S.can_be_inserted(src, TRUE))		//else we put in belt
		S.handle_item_insertion(src, M)
		return TRUE

	var/obj/item/O = M.get_item_by_slot(SLOT_HUD_BACK)	//else we put in backpack
	if(istype(O, /obj/item/storage))
		S = O
		if(S.can_be_inserted(src, TRUE))
			S.handle_item_insertion(src, M)
			playsound(loc, "rustle", 50, TRUE, -5)
			return TRUE
	if(ismodcontrol(O))
		var/obj/item/mod/control/C = O
		if(C.can_be_inserted(src, TRUE))
			C.handle_item_insertion(src, M)
			playsound(loc, "rustle", 50, TRUE, -5)
			return TRUE

	to_chat(M, "<span class='warning'>You are unable to equip that!</span>")
	return FALSE

/mob/proc/get_all_slots()
	return list(wear_mask, back, l_hand, r_hand)

/mob/proc/get_id_card()
	for(var/obj/item/I in get_all_slots())
		. = I.GetID()
		if(.)
			break

/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_HUD_WEAR_MASK)
			return wear_mask
		if(SLOT_HUD_BACK)
			return back
		if(SLOT_HUD_LEFT_HAND)
			return l_hand
		if(SLOT_HUD_RIGHT_HAND)
			return r_hand
	return null

//search for a path in inventory and storage items in that inventory (backpack, belt, etc) and return it.
/mob/proc/find_item(path)
	var/list/L = get_contents()

	for(var/obj/B in L)
		if(B.type == path)
			return B
