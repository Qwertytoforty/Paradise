
//malfunctioning combat drones
/mob/living/simple_animal/hostile/malf_drone
	name = "combat drone"
	desc = "An automated combat drone armed with state of the art weaponry and shielding."
	icon_state = "drone3"
	icon_living = "drone3"
	icon_dead = "drone_dead"
	mob_biotypes = MOB_ROBOTIC
	ranged = TRUE
	rapid = 3
	retreat_distance = 3
	minimum_distance = 3
	speak_chance = 5
	turns_per_move = 3
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("ALERT.", "Hostile-ile-ile entities dee-twhoooo-wected.", "Threat parameterszzzz- szzet.", "Bring sub-sub-sub-systems uuuup to combat alert alpha-a-a.")
	emote_see = list("beeps menacingly.", "whirrs threateningly.", "scans for targets.")
	a_intent = INTENT_HARM
	stop_automated_movement_when_pulled = FALSE
	health = 200
	maxHealth = 200
	speed = 8
	projectiletype = /obj/item/projectile/beam/immolator/weak/hitscan
	projectilesound = 'sound/weapons/laser3.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("malf_drone")
	deathmessage = "suddenly breaks apart."
	del_on_death = TRUE
	advanced_bullet_dodge_chance = 15 // This will be adjusted when active, vs deactivated. Randomises on hit if it is zero.
	var/passive_mode = TRUE // if true, don't target anything.

/mob/living/simple_animal/hostile/malf_drone/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(create_trail))
	update_icons()

/mob/living/simple_animal/hostile/malf_drone/proc/create_trail(datum/source, atom/oldloc, _dir, forced)
	var/turf/T = get_turf(oldloc)
	if(!has_gravity(T))
		new /obj/effect/particle_effect/ion_trails(T, _dir)

/mob/living/simple_animal/hostile/malf_drone/Process_Spacemove(check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/malf_drone/ListTargets()
	if(passive_mode)
		return list()
	return ..()

/mob/living/simple_animal/hostile/malf_drone/AttackingTarget()
	OpenFire(target) // prevents it pointlessly nuzzling its target in melee if its cornered

/mob/living/simple_animal/hostile/malf_drone/update_icons()
	if(passive_mode)
		icon_state = "drone_dead"
	else if(health / maxHealth > 0.9)
		icon_state = "drone3"
	else if(health / maxHealth > 0.7)
		icon_state = "drone2"
	else if(health / maxHealth > 0.5)
		icon_state = "drone1"
	else
		icon_state = "drone0"

/mob/living/simple_animal/hostile/malf_drone/adjustHealth(damage, updating_health)
	do_sparks(3, 1, src)
	passive_mode = FALSE
	update_icons()
	if(!advanced_bullet_dodge_chance)
		advanced_bullet_dodge_chance = rand(15, 30)
	. = ..() // this will handle finding a target if there is a valid one nearby

/mob/living/simple_animal/hostile/malf_drone/Life(seconds, times_fired)
	. = ..()
	if(.) // mob is alive. We check this just in case Life() can fire for qdel'ed mobs.
		if(times_fired % 15 == 0) // every 15 cycles, aka 30 seconds, 50% chance to switch between modes
			scramble_settings()

/mob/living/simple_animal/hostile/malf_drone/proc/scramble_settings()
	if(prob(50))
		do_sparks(3, 1, src)
		passive_mode = !passive_mode
		if(passive_mode)
			visible_message("<span class='notice'>[src] retracts several targetting vanes.</span>")
			advanced_bullet_dodge_chance = 0
			if(target)
				LoseTarget()
		else
			visible_message("<span class='warning'>[src] suddenly lights up, and additional targetting vanes slide into place.</span>")
			advanced_bullet_dodge_chance = rand(15, 30)
		update_icons()

///We overide the basic effect, as malfunctioning drones are in space, and use jets to dodge. Also lets us do cool effects.
/mob/living/simple_animal/hostile/malf_drone/advanced_bullet_dodge(mob/living/source, obj/item/projectile/hitting_projectile)
	if(HAS_TRAIT(source, TRAIT_IMMOBILIZED))
		return NONE
	if(source.stat != CONSCIOUS)
		return NONE
	if(!prob(advanced_bullet_dodge_chance))
		return NONE

	source.visible_message(
		"<span class='danger'>[source]'s jets [pick("boost", "propell", "pulse", "flare up and move", "shudders and pushes")] it out'[hitting_projectile]'s way!</span>",
		"<span class='userdanger'>You evade [hitting_projectile]!</span>",
	)
	playsound(source, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/effects/refill.ogg'), 75, TRUE)
	var/dir_to_avoid = angle2dir_cardinal(hitting_projectile.Angle)
	var/list/potential_first_directions = list(NORTH, SOUTH, EAST, WEST)
	potential_first_directions -= dir_to_avoid
	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	step(source, pick(potential_first_directions))
	if(prob(50))
		addtimer(VARSET_CALLBACK(source, advanced_bullet_dodge_chance, advanced_bullet_dodge_chance), 0.25 SECONDS)
		advanced_bullet_dodge_chance = 0
	return ATOM_PREHIT_FAILURE

/mob/living/simple_animal/hostile/malf_drone/emp_act(severity)
	adjustHealth(100 / severity) // takes the same damage as a mining drone from emp

/mob/living/simple_animal/hostile/malf_drone/drop_loot()
	do_sparks(3, 1, src)

	var/turf/T = get_turf(src)

	//shards
	var/obj/O = new /obj/item/shard(T)
	step_to(O, get_turf(pick(view(7, src))))
	if(prob(75))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))
	if(prob(50))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))
	if(prob(25))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))

	//rods
	var/obj/item/stack/K = new /obj/item/stack/rods(T)
	step_to(K, get_turf(pick(view(7, src))))
	K.amount = pick(1, 2, 3, 4)
	K.update_icon()

	//plasteel
	K = new /obj/item/stack/sheet/plasteel(T)
	step_to(K, get_turf(pick(view(7, src))))
	K.amount = pick(1, 2, 3, 4)
	K.update_icon()

	//also drop dummy circuit boards deconstructable for research (loot)
	var/obj/item/circuitboard/C

	//spawn 1-4 boards of a random type
	var/spawnees = 0
	var/num_boards = rand(1, 4)
	var/list/options = list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512)
	for(var/i=0, i<num_boards, i++)
		var/chosen = pick(options)
		options.Remove(options.Find(chosen))
		spawnees |= chosen

	if(spawnees & 1)
		C = new(T)
		C.name = "Drone CPU motherboard"
		C.origin_tech = "programming=[rand(3, 6)]"

	if(spawnees & 2)
		C = new(T)
		C.name = "Drone neural interface"
		C.origin_tech = "biotech=[rand(3, 6)]"

	if(spawnees & 4)
		C = new(T)
		C.name = "Drone suspension processor"
		C.origin_tech = "magnets=[rand(3, 6)]"

	if(spawnees & 8)
		C = new(T)
		C.name = "Drone shielding controller"
		C.origin_tech = "bluespace=[rand(3, 6)]"

	if(spawnees & 16)
		C = new(T)
		C.name = "Drone power capacitor"
		C.origin_tech = "powerstorage=[rand(3, 6)]"

	if(spawnees & 32)
		C = new(T)
		C.name = "Drone hull reinforcer"
		C.origin_tech = "materials=[rand(3, 6)]"

	if(spawnees & 64)
		C = new(T)
		C.name = "Drone auto-repair system"
		C.origin_tech = "engineering=[rand(3, 6)]"

	if(spawnees & 128)
		C = new(T)
		C.name = "Drone plasma overcharge counter"
		C.origin_tech = "plasmatech=[rand(3, 6)]"

	if(spawnees & 256)
		C = new(T)
		C.name = "Drone targetting circuitboard"
		C.origin_tech = "combat=[rand(3, 6)]"

	if(spawnees & 512)
		C = new(T)
		C.name = "Corrupted drone morality core"
		C.origin_tech = "syndicate=[rand(3, 6)]"
