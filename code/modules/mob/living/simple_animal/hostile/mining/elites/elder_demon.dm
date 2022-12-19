#define BLOOD_CRAWL 1
#define BLOOD_SPIKES 2
#define BLOOD_BOLTS 3
#define CHARGE_I_GUESS 4
#define DEMON_LUNG_BLEED_MODIFIER 4
#define TRUE_BLEED / DEMON_LUNG_BLEED_MODIFIER //This means if we wish the bleed to be 100, we can write it as 100 in file, instead of 25

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
	speed = 1
	move_to_delay = 10
	mouse_opacity = MOUSE_OPACITY_ICON
	death_sound = 'sound/misc/demon_dies.ogg'
	deathmessage = "'s lights flicker, before its top part falls down."
	loot_drop = /obj/item/clothing/accessory/necklace/pandora_hope

	//attack_action_types = list(/datum/action/innate/elite_attack/chaser_burst,
							//	/datum/action/innate/elite_attack/magic_box,
						//		/datum/action/innate/elite_attack/pandora_teleport,
						//		/datum/action/innate/elite_attack/aoe_squares)

//put actions here


/obj/item/organ/internal/lungs/elder_demon //We have too many magic hearts. Time for magic sick lungs //pls don't shoot me balance team.
	name = "engorged bloody lungs"
	desc = "Sickly looking lungs filled with blood. I know you guys put strange things in you for science, but at some point..."
	icon_state = "lungs-c-u" //make something gross
	origin_tech = "biotech=6" //not giving bio 7 out to lead to xray, 6 is fine

/obj/item/organ/internal/lungs/elder_demon/prepare_eat()
	return // Just so people don't accidentally waste it

/obj/item/organ/internal/lungs/elder_demon/attack_self(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_BLOODCOUGH))
		to_chat(user, "<span class='warning'>You are sick to your stomach after eatting the lungs last time... you can't even stomach eating it again.</span>")
		return TRUE

	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!</span>", \
						 "<span class='danger'>An unnatural hunger consumes you. You raise [src] to your mouth and devour it!</span>")
	playsound(user, 'sound/misc/demon_consume.ogg', 50, 1)

	// Install the lungs
	user.visible_message("<span class='warning'>[user] begins to cough up blood!</span>", \
					 "<span class='userdanger'>You feel a strange power seep into your body... and you feel violently ill!</span>")
	user.drop_item()
	user.custom_emote(EMOTE_VISIBLE, "coughs up lots of blood!")
	insert(user)
	return TRUE

/obj/item/organ/internal/lungs/elder_demon/insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind && ishuman(M))
		var/mob/living/carbon/human/H = M
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
		H.physiology.bleed_mod /= DEMON_LUNG_BLEED_MODIFIER // time to B L E E D

/obj/item/organ/internal/lungs/elder_demon/on_life()
	if(!ishuman(owner))
		return
	if(prob(33))
		owner.bleed(5 TRUE_BLEED) //Constantly bleeding, fuck the janitor, also easy trail for sec to follow
		if(prob(33))
			owner.custom_emote(EMOTE_VISIBLE, "coughs up blood!")
	if(owner.blood_volume > BLOOD_VOLUME_NORMAL / 100 * 80)
		owner.bleed(5 TRUE_BLEED)
	else
		owner.blood_volume += 7 // On average regens blood
	if(owner.blood_volume < BLOOD_VOLUME_SAFE)
		owner.adjustOxyLoss(-1) //Less suffering from low blood.
	return ..()


/obj/effect/proc_holder/spell/ethereal_jaunt/blood_cough
	name = "Sanguine Pool"
	desc = "You shift your form into a pool of blood, making you invulnerable and able to move through anything that's not a wall or space. You leave a trail of blood behind you when you do this."
	gain_desc = "You have gained the ability to shift into a pool of blood, allowing you to evade pursuers with great mobility."
	jaunt_duration = 5 SECONDS //idk
	clothes_req = FALSE
	school = "demon"
	action_icon_state = "blood_pool"
	jaunt_type_path = /obj/effect/dummy/spell_jaunt/blood_cough
	jaunt_water_effect = FALSE
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/cult/phase/out
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/cult/phase
	jaunt_in_time = 1 // test
	sound1 = 'sound/misc/enter_blood.ogg' //sure

/obj/effect/proc_holder/spell/ethereal_jaunt/blood_cough/do_jaunt(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(100 TRUE_BLEED)
	return ..()


#undef BLOOD_CRAWL
#undef BLOOD_SPIKES
#undef BLOOD_BOLTS
#undef CHARGE_I_GUESS
#undef DEMON_LUNG_BLEED_MODIFIER
#undef TRUE_BLEED
