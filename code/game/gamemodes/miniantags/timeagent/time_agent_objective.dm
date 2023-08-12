
GLOBAL_LIST_INIT(time_anomaly_list, list())

/datum/objective/time_agent_extract
	name = "extract through anomaly"
	var/obj/effect/time_anomaly/anomaly
	var/extracted = FALSE

/datum/objective/time_agent_extract/find_target(list/target_blacklist)
	if(length(GLOB.time_anomaly_list) == 0)
		new /obj/effect/time_anomaly(pick(GLOB.xeno_spawn))
	else
		anomaly = GLOB.time_anomaly_list[1]
	explanation_text = format_explanation()
	return TRUE

/datum/objective/time_agent_extract/check_completion()
	if(extracted)
		return TRUE

/datum/objective/time_agent_extract/proc/format_explanation()
	return "Escape through [anomaly], located in [format_text(get_area(anomaly).name)] ([anomaly.x], [anomaly.y], [anomaly.z]). Use your jump charge to activate it."

/obj/effect/time_anomaly
	name = "anomaly"
	desc = "A hole in time and space.<br><span class = 'sinister'>Looking into it is like looking at a picture of yourself looking at a picture of yourself ad infinitum. Looking further, you swear one or two turn their head to look back at you.</span>"
	icon = 'icons/effects/effects.dmi'
	icon_state = "time_anomaly" //TODO: Something that DOESNT LOOK SHIT
	anchored = 1
	mouse_opacity = 1
	flags_2 = TIMELESS_2
	var/last_effect

/obj/effect/time_anomaly/New()
	..()

	START_PROCESSING(SSobj, src)
	last_effect = world.time
	playsound(loc, 'sound/effects/portal_open.ogg', 60, 1)
	set_light(3, l_color = LIGHT_COLOR_CYAN)
	GLOB.time_anomaly_list += src

/obj/effect/time_anomaly/process()
	if(world.time >= last_effect + 30 SECONDS)
		last_effect = world.time
		if(prob(60))
			new /obj/effect/timestop(loc)
		else
			past_rift(src, rand(7, 15) SECONDS, rand(3, 5))

/obj/effect/time_anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	playsound(loc,'sound/effects/portal_close.ogg',60,1)
	GLOB.time_anomaly_list -= src
	..()

/obj/effect/time_anomaly/proc/extract(mob/user)
	showrift(user, 1)
	qdel(user)
