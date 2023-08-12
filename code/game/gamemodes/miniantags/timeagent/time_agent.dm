/**
	Time agent

	You've got 25 minutes of playtime to do something weird

	If you succeed, the stations midrounds are more tame

	If you fail, something weird happens.

	Are you a bad enough dude to make sure a corgi, a rubber duck, and a bucket are in the same place at the same time?

**/


//#define istimeagent(H) (H.mind && (H.mind.GetRole(SPECIAL_ROLE_TIME_AGENT) || (H.mind.GetRole(SPECIAL_ROLE_TIME_AGENT_TWIN))))




/mob/living/carbon/human/proc/make_time_agent(give_default_objectives = TRUE, is_twin = FALSE)
	mind.assigned_role = SPECIAL_ROLE_TIME_AGENT
	mind.special_role = SPECIAL_ROLE_TIME_AGENT
	SSticker.mode.traitors |= mind
	to_chat(src, " <span class='danger'>You are a Time Agent.<br>Specifically you are a scientist by the name of John Beckett, having discovered a method to travel through time, and becoming lost to it. <br>\
			Now, you are forced to take responsibility for maintaining the time stream by the mysterious 'Time Agency'.<br>\
			You only have a limited amount of time before this timeline is deemed lost, in which case you will be forcibly extracted and the mission considered a failure.<br>\
			This may not be the first time you visit this timeline, and it may not be the last.</span>")

	to_chat(src, "<span class='danger'>Remember that the items you are provided with are largely non-expendable. Try not to lose them, especially the jump charge, as it is your ticket home.</span>")
	SEND_SOUND(src, sound('sound/magic/mutate.ogg'))
	if(give_default_objectives && is_twin == FALSE)
		message_admins("ADD OBJECTIVES")
		//AppendObjective(/datum/objective/target/locate)
		if(prob(30))
			message_admins("ADD OBJECTIVES")
		//	AppendObjective(/datum/objective/target/locate/rearrange)
		if(prob(30))
			message_admins("ADD OBJECTIVES")
		//	AppendObjective(/datum/objective/target/assassinate)
	message_admins("ADD OBJECTIVES")
	//	AppendObjective(/datum/objective/freeform/aid)
	if(is_twin)
		message_admins("TWINZIES")
	//STUFF
	equip_time_agent(src, is_twin)


/proc/equip_time_agent(mob/living/carbon/human/H, var/is_twin = FALSE)
	H.body_accessory = null
	H.set_species(/datum/species/human)
	H.cleanSE() //No fat/blind/colourblind/epileptic/whatever.
	H.overeatduration = 0
	H.flavor_text = null
	H.equipOutfit(/datum/outfit/time_agent, is_twin)
	H.real_name = "John Beckett"

/datum/outfit/time_agent
	var/is_twin = FALSE
	name = "Time Agent"

	back = /obj/item/storage/backpack/satchel_tox

	l_ear = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	shoes = /obj/item/clothing/shoes/combat
	mask = /obj/item/clothing/mask/gas
	suit = /obj/item/clothing/suit/space/time
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	belt = /obj/item/storage/belt/military/assault/chrono
	head = /obj/item/clothing/head/helmet/space/time


	backpack_contents = list(
		/obj/item/jump_charge,
		/obj/item/timeline_eraser,
		/obj/item/gun/projectile/automatic/wt550/rewind,
		/obj/item/chronocapture,
		/obj/item/pinpointer/advpinpointer,
	)

/datum/outfit/special/time_agent/pre_equip(var/mob/living/carbon/human/H, is_twin)
	if(is_twin)
		backpack_contents -= /obj/item/jump_charge
		backpack_contents += /obj/item/grenade/chronogrenade/future
		backpack_contents += /obj/item/grenade/chronogrenade/future
		backpack_contents += /obj/item/grenade/chronogrenade/future


/obj/item/chronocapture
	name = "chronocapture device"
	desc = "Used to confirm that everything is where it should be."
	icon = 'icons/obj/items.dmi'
	icon_state = "polaroid"
	item_state = "polaroid"
	w_class = WEIGHT_CLASS_SMALL
	var/triggered = FALSE

/obj/item/chronocapture/afterattack(atom/target, mob/user)
	triggered = TRUE
	playsound(loc, "polaroid", 75, 1, -3)
	spawn(3 SECONDS)
		triggered = FALSE
	//var/datum/objective/target/locate/L = locate() in user.mind.objectives
	//if(L)
	//	L.check(view(target,2))

/obj/item/gun/projectile/automatic/wt550/rewind
	name = "rewind rifle"
	desc = "Don't need to reload if you just rewind the bullets back into the gun."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "xcomlasergun"

/obj/item/gun/projectile/automatic/wt550/rewind/update_icon_state()
	icon_state = "xcomlasergun[magazine ? "-[CEILING(get_ammo(0)/5, 1)*5]" : ""]"

/obj/item/gun/projectile/automatic/wt550/rewind/attack_self(mob/living/user)
	return


/obj/item/gun/projectile/automatic/wt550/rewind/examine(mob/user)
	. = ..()
	. += "<span class='info'>This state-of-the-art rewind rifle engages its rewind mechanism only when firing, which takes between 10 and 15 seconds to finalize. When it rewinds it will end up in your possession if you held it at the time of firing."

/obj/item/gun/projectile/automatic/wt550/rewind/send_to_past(duration)
	..()
	if(istype(loc, /mob))
		var/mob/owner = loc
		spawn(duration)
			owner.put_in_hands(src)

///obj/item/gun/projectile/automatic/rewind/special_check(var/mob/M)
//	return istimeagent(M)

/obj/item/gun/projectile/automatic/wt550/rewind/process_fire()
	attempt_past_send(rand(10,15) SECONDS)
	return ..()

/obj/item/jump_charge
	name = "jump charge"
	desc = "A strange button."
	icon_state = "jump_charge"
	w_class = WEIGHT_CLASS_SMALL
	flags_2 = TIMELESS_2
	var/triggered = FALSE
	var/disarmed = FALSE //If toggled on, will delete itself without respawning
	var/times_respawned = 0 //A metric for how many times it respawned. You know, for fun.

/obj/item/jump_charge/examine(mob/user, size, show_name)
	. = ..()
	. += "<span class='info'>As a time agent, you know that you need this in order to go back through the time anomaly. Its extremely advanced technology allows it to regenerate in case of destruction, and in a pinch you can use it to send anything into the future after 3 seconds.</span>"
	if(triggered)
		. +=  "<span class='warning'>It is still recharging.</span>"
	switch(times_respawned)
		if(-INFINITY to -1) //Not that it would happen outside of bus shenanigans, but who knows?
			. += "<span class='sinister'>Somehow this device feels off, likely due to the tamperings of Bluespace Technicians.</span>"
		if(0)
			. += "<span class='info'>This device is as pristine as it was in the day it was made.</span>"
		if(1)
			. += "<span class='info'>This device looks a bit roughed up, likely as a result of undergoing temporal regeneration. You might want to keep it more safe.</span>"
		if(2 to 4)
			. += "<span class='info'>This device has seen some better days. It has already undergone temporal regeneration several times, likely as a result of careless destruction. The Time Agency might make you go through Jump Charge Usage Orientation again...</span>"
		if(5 to 10)
			. += "<span class='info'>This device is in a seriously rough shape. It has been destroyed enough times that the button feels sticky and you're worried about its internal components. At this point it is more likely that it was deliberately destroyed repeatedly rather than out of accident. The Time Agency might ask you a few questions about this.</span>"
		if(11 to INFINITY)
			. += "<span class='info'>This device has been destroyed many, many times and it shows. Through sheer luck or just extremely advanced technology it still thankfully works as intended, but such damage will raise a brow or two, or three, or the entirety of the Time Agency's.</span>"
//Behavior shamelessly stolen from nuclear disks

/obj/item/jump_charge/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/jump_charge/Destroy()
	STOP_PROCESSING(SSobj, src)
	replace_jump_charge()
	return ..()

/obj/item/jump_charge/proc/replace_jump_charge()
	if(length(GLOB.nukedisc_respawn) > 0 && !disarmed) //Does it really have to be blobstart? Feel free to replace with a more sane "anywhere on the station" list
		var/picked_turf = get_turf(pick(GLOB.nukedisc_respawn))
		var/obj/item/jump_charge/J = new(picked_turf)
		J.times_respawned = times_respawned + 1
		disarmed = TRUE
		qdel(src)

/obj/item/jump_charge/process()
	var/turf/T = get_turf(src)
	if(!T)
		qdel(src)

/obj/item/jump_charge/afterattack(atom/movable/AM, mob/user, flag)
	if(!flag)
		return
	if(istype(AM, /obj/effect/time_anomaly))
		var/datum/objective/time_agent_extract/TAE = locate() in user.mind.objectives
		if(TAE && AM == TAE.anomaly)
			var/time_agency_panic = FALSE
			if(times_respawned > 10)
				time_agency_panic = TRUE
			//if(user.mind.GetRole(TIMEAGENT))
			//	to_chat(user, "<span class = 'notice'>New anomaly discovered. Welcome back, [user.real_name]. Moving to ne[time_agency_panic ? "-WHAT THE HELL HAPPENED TO THE JUMP CHARGE?!" : "w co-ordinates."]</span>")
			//if(user.mind.GetRole(TIMEAGENTTWIN))
			//	to_chat(user, "<span class='notice'>As the time anomaly sizzles and refracts, you wonder what awaits you now as a fugitive from the Time Agency. One thing is for certain, you are going to cause chaos.")
			TAE.anomaly.extract(user)
			TAE.extracted = TRUE
			TAE.anomaly = null
			disarmed = TRUE
			qdel(src)
			qdel(AM)
		else
			to_chat(user, "<span class='warning'>Your work is not over yet!</span>")
		return
	if(triggered)
		to_chat(user, "<span class='warning'>It is still recharging!</span>")
		return
	if(!triggered)
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		icon_state = "jump_charge_firing"
		to_chat(user, "<span class = 'warning'>Jump charge armed and calibrated onto \the [AM]. Firing in 3 seconds.</span>")
		triggered = TRUE
		spawn(3 SECONDS)
			icon_state = "jump_no_charge"
			future_rift(AM, 10 SECONDS, 1)
			spawn(10 SECONDS)
				icon_state = initial(icon_state)
				triggered = FALSE

/obj/item/storage/belt/military/assault/chrono

/obj/item/storage/belt/military/assault/chrono/New()
	..()
	new /obj/item/grenade/chronogrenade(src)
	new /obj/item/grenade/chronogrenade(src)
	new /obj/item/grenade/chronogrenade/future(src)
	new /obj/item/grenade/chronogrenade/future(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/empgrenade(src)

/obj/item/timeline_eraser
	name = "timeline eraser"
	desc = "A strange button."
	icon_state = "jump_charge"
	w_class = WEIGHT_CLASS_SMALL
	flags_2 = TIMELESS_2
	var/in_process = FALSE
	var/charge = 5 //Will set to 0 and gradually increment to from 0 to 5 (10 seconds total), after which it can be used again

/obj/item/timeline_eraser/examine(mob/user, size, show_name)
	. = ..()
	. += "<span class='info'>As a time agent, you know that this device can erase nearly anything from reality. Erasing entities will take 10 seconds, erasing objects will take 5 seconds and erasing other time agents will take no time at all. People with temporal suits are protected from its effects.</span>"
	if(charge < 5)
		. += "<span class='warning'>It is still recharging.</span>"

/obj/item/timeline_eraser/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/timeline_eraser/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/timeline_eraser/process()
	if(charge >= 5)
		icon_state = "jump_charge"
	else
		charge++

/obj/item/timeline_eraser/afterattack(atom/movable/AM, mob/user, flag)
	if(!flag)
		return
	if(in_process)
		to_chat(user, "<span class='warning'>[src] is already erasing someone from reality!</span>")
		return
	if(charge < 5)
		to_chat(user, "<span class='warning'>[src] is still recharging!</span>")
		return
	if(istype(AM, /obj/item/jump_charge)) //It is already unaffected but leaving a message here for trying to soft-lock is funny
		to_chat(user, "<span class='warning'>Are you insane? You can't just erase such an important device!</span>")
		return
	if(AM.flags_2 & TIMELESS_2)
		to_chat(user, "<span class = 'warning'>The target is currently immune to temporal meddling.</span>")
		return
	. = 1
	var/duration = 10 SECONDS
	// TODO: Make the timestop, properly stop when the process is done
	if(istype(AM, /mob))
		var/mob/M = AM
		//if(istimeagent(M))
			//duration = 0
		duration = 9 SECONDS
	if(istype(AM, /obj))
		duration = 5 SECONDS
	to_chat(user, "<span class='warning'>You start erasing [AM] from existence...</span>")
	in_process = TRUE
	icon_state = "jump_charge_firing"
	if(do_after(user, duration, AM))
		delete_from_timeline(AM, user)
		charge = 0
		icon_state = "jump_no_charge"
	else
		to_chat(user, "<span class-'warning'>Erasing [AM] has been aborted.</span>")
		icon_state = "jump_charge"
	in_process = FALSE

/obj/item/timeline_eraser/proc/delete_from_timeline(atom/target, mob/user)
	//if(istimeagent(user))
	//	var/datum/role/R = user.mind.GetRole(TIMEAGENT)
	//	if(R)
	//		var/datum/objective/target/assassinate/erase/E = locate() in R.objectives.GetObjectives()
	//		if(E)
	//			E.check(target)
	if(istype(target, /mob))
		var/mob/M = target
		if(M.mind)
			message_admins("remove this check")
			//var/name = M.mind.name
			//for (var/list/L in list(data_core.general, data_core.medical, data_core.security,data_core.locked))
			//	if (L)
			//		var/datum/data/record/R = find_record("name", name, L)
		//			QDEL_NULL(R)
		//	for(var/obj/machinery/telecomms/server/S in telecomms_list)
		//		for(var/datum/comm_log_entry/C in S.log_entries)
		//			if(C.parameters["realname"] == name)
		//				S.log_entries.Remove(C)
		//				QDEL_NULL(C)
		//	for(var/obj/machinery/message_server/S in message_servers)
		//		for(var/datum/data_pda_msg/P in S.pda_msgs)
		//			if((P.sender == name) || (P.recipient == name))
		//				S.pda_msgs.Remove(P)
		//				QDEL_NULL(P)
		for(var/obj/item/I in M)
			user.unEquip(I)
	var/target_location = get_turf(target)
	message_admins("[user] ([user.ckey]) has ERASED [target] from existence at [formatJumpTo(target_location)]!")
	qdel(target)
	to_chat(user, "<span class='warning'>You erase [target] from existence.</span>")

