#define BLOOD_SPIKES 1
#define BLOOD_BOLTS 2
#define CHARGE_I_GUESS 3
#define DEMON_LUNG_BLEED_MODIFIER 4.5
#define TRUE_BLEED / DEMON_LUNG_BLEED_MODIFIER //This means if we wish the bleed to be 100, we can write it as 100 in file, instead of ~25 or whatever the define is

/**
 * # Elder Slaughter Demon
 *
 * An elder slaughter demon. While it has much more HP than it's younger self, and more skills, it has become afflicted with what all but the strongest demons are affected by, age and sickness.
 * As such, it constantly coughing up blood, and can not stay inside blood for long, and can only travel where blood exists. Don't expect it to be an easy fight, however.
 * It has less max hp (when not tumor shard revived) but heals itself on hits
 * ONLY a boosted elite. Not AI controlled.
 * It's attacks are as follows:
 * - Blood crawls for 5 seconds. Can only move through tiles with blood. During the last second, it will give a slight warning to anyone beside it, before damaging them when emerging.
 * - Spreads spikes through blood. Has recursion protection.
 * - Shoots bolts of blood that spread blood as they fly, and more on hit, however slightly damages the user (if not revived via tumor shard) Aoe blood and heal on direct hit.
 * - temp
 * explain how fight works here
 */

/mob/living/simple_animal/hostile/asteroid/elite/elder_demon
	name = "elder slaughter demon"
	desc = "An elder slaughter demon. Quite large, but also seems sick, luckily for you"
	icon_state = "TEMP_SPRITE"
	icon_living = "TEMP_SPRITE"
	icon_aggro = "TEMP_SPRITE"
	icon_dead = "pandora_dead" //NEED THIS
	icon_gib = "syndicate_gib" //prob fine delete comment

	maxHealth = 600 //IDK
	health = 600
	melee_damage_lower = 35
	melee_damage_upper = 35
	armour_penetration_percentage = 50
	attacktext = "wildly tears into"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	throw_message = "merely dinks off of the"
	ranged_cooldown_time = 20
	speed = 0.5 //test this shit
	move_to_delay = 3
	mouse_opacity = MOUSE_OPACITY_ICON
	death_sound = 'sound/misc/demon_dies.ogg'
	deathmessage = "'s lights flicker, before its top part falls down." //change
	loot_drop = /obj/item/organ/internal/lungs/elder_demon

	attack_action_types = list(/datum/action/innate/elite_attack/blood_spikes,
								/datum/action/innate/elite_attack/blood_bolts,
								/datum/action/innate/elite_attack/temp)

//put actions here

/datum/action/innate/elite_attack/blood_spikes
	name = "Blood Spikes"
	button_icon_state = "legionnaire_charge" //FUCK ME NEED TO SPRITE THESE
	chosen_message = "<span class='boldwarning'>You will send a wave of spiked blood through the blood you are standing on.</span>"
	chosen_attack_num = BLOOD_SPIKES

/datum/action/innate/elite_attack/blood_bolts
	name = "Blood Bolts"
	button_icon_state = "head_detach"
	chosen_message = "<span class='boldwarning'>You shoot orbs of blood that will help you spread blood. This hurts you, but landing a hit heals you.</span>"
	chosen_attack_num = BLOOD_BOLTS

/datum/action/innate/elite_attack/temp //REAL FUCKING TEMP
	name = "temp"
	button_icon_state = "bonfire_teleport"
	chosen_message = "<span class='boldwarning'>You will do nothing as I have not coded you.</span>"
	chosen_attack_num = CHARGE_I_GUESS

/mob/living/simple_animal/hostile/asteroid/elite/elder_demon/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)

/mob/living/simple_animal/hostile/asteroid/elite/elder_demon/OpenFire()
	if(client)
		switch(chosen_attack)
			if(BLOOD_SPIKES)
				blood_spikes()
			if(BLOOD_BOLTS)
				blood_bolts(target)
			if(CHARGE_I_GUESS)
				temp()
		return

/mob/living/simple_animal/hostile/asteroid/elite/elder_demon/Moved(atom/OldLoc, Dir, Forced = FALSE)
	if(Dir && !Forced)
		new /obj/effect/decal/cleanable/blood/bubblegum(loc)
	return ..()

/mob/living/simple_animal/hostile/asteroid/elite/elder_demon/proc/blood_spikes()
	for(var/obj/effect/decal/cleanable/blood/B in (get_turf(src)))
		B.blood_spike(src, rand(1, 1000))
		ranged_cooldown = world.time + 8 SECONDS * revive_multiplier()
		return

/mob/living/simple_animal/hostile/asteroid/elite/elder_demon/proc/blood_bolts(target)
	return

/mob/living/simple_animal/hostile/asteroid/elite/elder_demon/proc/temp()
	return

// LUNGS
/obj/item/organ/internal/lungs/elder_demon //We have too many magic hearts. Time for magic sick lungs //pls don't shoot me balance team.
	name = "engorged bloody lungs"
	desc = "Sickly looking lungs filled with blood. I know you guys put strange things in you for science, but at some point..."
	icon_state = "lungs-c-u" //make something gross
	origin_tech = "biotech=6" //not giving bio 7 out to lead to xray, 6 is fine

/obj/item/organ/internal/lungs/elder_demon/prepare_eat()
	return // Just so people don't accidentally waste it

/obj/item/organ/internal/lungs/elder_demon/attack_self(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(NO_BLOOD in H.dna.species.species_traits)
			to_chat(H, "<span class='userdanger'>[src] is not compatible with your form!</span>") //Need to pay to play
			return
		if(HAS_TRAIT(H, TRAIT_BLOODCOUGH))
			to_chat(H, "<span class='warning'>You are sick to your stomach after eatting the lungs last time... you can't even stomach eating it again.</span>")
			return TRUE

		copy_lungs(H.get_organ_slot("lungs"))

		H.visible_message("<span class='warning'>[H] raises [src] to [H.p_their()] mouth and tears into it with [H.p_their()] teeth!</span>", \
							"<span class='danger'>An unnatural hunger consumes you. You raise [src] to your mouth and devour it!</span>")
		playsound(H, 'sound/misc/demon_consume.ogg', 50, 1)

		// Install the lungs
		H.visible_message("<span class='warning'>[H] begins to cough up blood!</span>", \
						"<span class='userdanger'>You feel a strange power seep into your body... and you feel violently ill!</span>")
		H.drop_item()
		H.vomit(0, 1)
		insert(H)
		return TRUE

/obj/item/organ/internal/lungs/elder_demon/proc/copy_lungs(obj/item/organ/internal/lungs/L)//Sorry for the following code. This is mainly to keep from fucking over vox, but also drask / ashwalkers / whatever other species get special snowflake lungs.
	if(!L) //Honestly maybe just make lungs that don't use air. Probably smarter. ANYWAY
		return
	safe_oxygen_min = L.safe_oxygen_min
	safe_oxygen_max = L.safe_oxygen_max
	safe_nitro_min = L.safe_nitro_min
	safe_nitro_max = L.safe_nitro_max
	safe_co2_min = L.safe_co2_min
	safe_co2_max = L.safe_co2_max
	safe_toxins_min = L.safe_toxins_min
	safe_toxins_max = L.safe_toxins_max
	SA_para_min = L.SA_para_min
	SA_sleep_min = L.SA_sleep_min
	oxy_breath_dam_min = L.oxy_breath_dam_min
	oxy_breath_dam_max = L.oxy_breath_dam_max
	oxy_damage_type = L.oxy_damage_type
	nitro_breath_dam_min = L.nitro_breath_dam_min
	nitro_breath_dam_max = L.nitro_breath_dam_max
	nitro_damage_type = L.nitro_damage_type
	co2_breath_dam_min = L.co2_breath_dam_min
	co2_breath_dam_max = L.co2_breath_dam_max
	co2_damage_type = L.co2_damage_type
	tox_breath_dam_min = L.tox_breath_dam_min
	tox_breath_dam_max = L.tox_breath_dam_max
	tox_damage_type = L.tox_damage_type
	cold_message = L.cold_message
	cold_level_1_threshold = L.cold_level_1_threshold
	cold_level_2_threshold = L.cold_level_2_threshold
	cold_level_3_threshold = L.cold_level_3_threshold
	cold_level_1_damage = L.cold_level_1_damage
	cold_level_2_damage = L.cold_level_2_damage
	cold_level_3_damage = L.cold_level_3_damage
	cold_damage_types = L.cold_damage_types
	hot_message = L.hot_message
	heat_level_1_threshold = L.heat_level_1_threshold
	heat_level_2_threshold = L.heat_level_2_threshold
	heat_level_3_threshold = L.heat_level_3_threshold
	heat_level_1_damage = L.heat_level_1_damage
	heat_level_2_damage = L.heat_level_2_damage
	heat_level_3_damage = L.heat_level_3_damage
	heat_damage_types = L.heat_damage_types

/obj/item/organ/internal/lungs/elder_demon/insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind && ishuman(M))
		var/mob/living/carbon/human/H = M
		if(NO_BLOOD in H.dna.species.species_traits)
			return //fuck you no implanting to get around attack_self
		H.bleed(100)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/ethereal_jaunt/blood_cough(null))
		ADD_TRAIT(H, TRAIT_BLOODCOUGH, "bloodcrawl")
		H.physiology.bleed_mod *= DEMON_LUNG_BLEED_MODIFIER // time to B L E E D

/obj/item/organ/internal/lungs/elder_demon/remove(mob/living/carbon/M, special = 0)
	..()
	if(M.mind && ishuman(M))
		var/mob/living/carbon/human/H = M
		REMOVE_TRAIT(H, TRAIT_BLOODCOUGH, "bloodcrawl")
		H.mind.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)
		H.physiology.bleed_mod /= DEMON_LUNG_BLEED_MODIFIER

/obj/item/organ/internal/lungs/elder_demon/on_life()
	if(!ishuman(owner))
		return
	if(prob(33))
		owner.bleed(5 TRUE_BLEED) //Constantly bleeding, fuck the janitor, also easy trail for sec to follow
		if(prob(10))
			owner.custom_emote(EMOTE_VISIBLE, "coughs up blood!")
	if(owner.blood_volume > BLOOD_VOLUME_NORMAL / 100 * 80)
		owner.bleed(10 TRUE_BLEED)
	else
		owner.blood_volume += 4 // With random bleeding, on average 90 seconds to recover from a use of blood crawl
	if(owner.blood_volume < BLOOD_VOLUME_SAFE)
		owner.adjustOxyLoss(-1.5) //Less suffering from low blood. Still will die slowly on low blood though, or instantly from below 20%
	return ..()


/obj/effect/proc_holder/spell/ethereal_jaunt/blood_cough
	name = "Sickly blood crawl"
	desc = "You sink into the blood, and can move through it for 5 seconds. You can only move on tiles that have blood. On harm intent, you hurt people around you on exiting blood."
	base_cooldown = 100
	jaunt_duration = 5 SECONDS //idk
	clothes_req = FALSE
	school = "demon"
	action_icon_state = "blood_pool"
	jaunt_type_path = /obj/effect/dummy/spell_jaunt/blood_cough
	jaunt_water_effect = FALSE
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/cult/phase/out
	jaunt_in_type = null
	jaunt_in_time = 3 //3 deciseconds to react, but chances are you know they are in the blood and are actively trying to run away
	sound1 = 'sound/misc/enter_blood.ogg' //sure
	sound2 = null //Play sound after they come out

/obj/effect/proc_holder/spell/ethereal_jaunt/blood_cough/do_jaunt(mob/living/target)
	target.see_invisible = SEE_INVISIBLE_HIDDEN_RUNES //Need to see where they are crawling, blood runes are easier to see when crawling I guess since they are made of blood.
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(120 TRUE_BLEED)
	target.visible_message("<span class='danger'>[target]'s vomits up blood and sinks into it!</span>",\
	"<span class='userdanger'>You collapse into the blood!</span>")
	for(var/turf/T in oview(1,target))
		target.add_splatter_floor(T)
	for(var/mob/living/carbon/human/H in oview(1,target))
		H.add_mob_blood(target)
	return ..()

/obj/effect/proc_holder/spell/ethereal_jaunt/blood_cough/exit_jaunt(mob/living/target)
	new /obj/effect/temp_visual/dir_setting/cult/phase(get_turf(target))
	playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)
	target.visible_message("<span class='danger'>[target] exits the blood!</span>",\
	"<span class='userdanger'>You exit out of the blood!</span>")
	target.see_invisible = initial(target.see_invisible)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.a_intent == INTENT_HELP)
			return
		var/obj/item/I = H.r_hand
		if(!I)
			I = H.l_hand
		if(!I)
			return
		for(var/mob/living/M in range(H, 1))
			if(H == M)
				continue
			I.melee_attack_chain(H, M)
	else
		for(var/mob/living/M in range(target, 1))
			if(target == M)
				continue
			target.UnarmedAttack(M)
			target.adjustBruteLoss(25) //Some armor peircing damage as it is hard to land.

/obj/effect/proc_holder/spell/ethereal_jaunt/blood_cough/jaunt_warning(mob/living/target)
	for(var/mob/living/M in range(target, 1))
		if(target == M)
			continue
		to_chat(M, "<span class='warning'>The blood starts to bubble under you...</span>")


#undef BLOOD_SPIKES
#undef BLOOD_BOLTS
#undef CHARGE_I_GUESS
#undef DEMON_LUNG_BLEED_MODIFIER
#undef TRUE_BLEED
