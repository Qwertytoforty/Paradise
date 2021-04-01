/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"
	is_reflectable = TRUE

/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/tase.ogg'
	range = 7
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/item/projectile/energy/electrode/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, 1, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK, 33)
		if(HAS_TRAIT(C, TRAIT_HULK))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else if(C.status_flags & CANWEAKEN)
			spawn(5)
				C.do_jitter_animation(jitter)

/obj/item/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, 1, src)
	..()

/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	irradiate = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/item/projectile/energy/dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5
	range = 7

/obj/item/projectile/energy/shuriken
	name = "shuriken"
	icon_state = "toxin"
	damage = 10
	damage_type = TOX
	weaken = 5
	stutter = 5

/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	nodamage = 0
	weaken = 5
	stutter = 5

/obj/item/projectile/energy/bolt/large
	damage = 20

/obj/item/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 10 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/zap_range = 3
	var/power = 10000

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/energy/shock_revolver/P = BB
	spawn(1)
		P.chain = P.Beam(user, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 1000, maxdistance = 30)

/obj/item/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	tesla_zap(src, zap_range, power, zap_flags)
	qdel(src)

/obj/item/projectile/energy/bsg
	name = "orb of pure bluespace energy"
	icon_state = "bluespace"
	impact_effect_type = /obj/effect/temp_visual/bsg_kaboom
	damage = 60
	damage_type = BURN
	range = 9
	weaken = 5
	eyeblur = 5
	speed = 2
	alwayslog = TRUE

/obj/item/ammo_casing/energy/bsg/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/energy/bsg/P = BB
	spawn(1)
		P.chain = P.Beam(user, icon_state = "sm_arc_supercharged", icon = 'icons/effects/beam.dmi', time = 1000, maxdistance = 30)

/obj/item/projectile/energy/bsg/on_hit(atom/target)
	. = ..()
	kaboom()
	qdel(src)

/obj/item/projectile/energy/bsg/on_range()
	kaboom()
	..()

/obj/item/projectile/energy/bsg/proc/kaboom()
	playsound(src, 'sound/weapons/bsg_explode.ogg', 75, TRUE)
	for(var/mob/living/M in hearers(7, src))
		var/floored = FALSE
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/gun/energy/bsg/N = locate() in H
			if(N)
				to_chat(H, "<span class='notice'>[N] deploys an energy shield to project you from the [src]'s explosion.</span>")
				continue
		if(prob(min(400 / (1 + get_dist(M, src)), 100)))
			if(prob(min(150 / (1 + get_dist(M, src)), 100)))
				M.Weaken(rand(1,3))
				floored = TRUE
			M.apply_damage((rand(15,30) * (1.1 - (get_dist(M, src)) / 10)), BURN) //reduced by 10% per tile
			add_attack_logs(src, M, "Hit heavily by [src]")
			if(floored)
				to_chat(M, "<span class='danger'>You see a flash of briliant blue light as [src] explodes, knocking you to the ground and burning you!</span>")
			else
				to_chat(M, "<span class='danger'>You see a flash of briliant blue light as [src] explodes, burning you!</span>")
		else
			to_chat(M, "<span class='danger'>You feel the heat of the explosion of the [src], but the blast mostly misses you.</span>")
			add_attack_logs(src, M, "Hit lightly by [src]")
			M.apply_damage(rand(1, 5), BURN)

/obj/item/projectile/energy/toxplasma
	name = "plasma bolt"
	icon_state = "energy"
	damage = 20
	damage_type = TOX
	irradiate = 20
