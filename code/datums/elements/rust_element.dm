/**
 * Adding this element to an atom will have it automatically render an overlay.
 */
/datum/element/rust
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	/// The rust image itself, since the icon and icon state are only used as an argument
	var/image/rust_overlay

/datum/element/rust/Attach(atom/target, rust_icon = 'icons/effects/rust_overlay.dmi', rust_icon_state = "rust_default")
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	rust_overlay = image(rust_icon, "rust[rand(1, 6)]")
	ADD_TRAIT(target, TRAIT_RUSTY, "rusted_turf")
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_rust_overlay))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(handle_examine))
	RegisterSignal(target, COMSIG_INTERACT_TARGET, PROC_REF(on_interaction))
	RegisterSignal(target, COMSIG_TOOL_ATTACK, PROC_REF(welder_tool_act))
	// Unfortunately registering with parent sometimes doesn't cause an overlay update
	target.update_appearance()

/datum/element/rust/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(source, COMSIG_TOOL_ATTACK)
	UnregisterSignal(source, COMSIG_INTERACT_TARGET)
	REMOVE_TRAIT(source, TRAIT_RUSTY, "rusted_turf")
	source.cut_overlays()
	source.update_appearance()

/datum/element/rust/proc/handle_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER //COMSIG_PARENT_EXAMINE

	examine_list += "<span class='notice'>[source] is very rusty, you could probably <b>burn</b> it off.</span>"

/datum/element/rust/proc/apply_rust_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER //COMSIG_ATOM_UPDATE_OVERLAYS

	if(rust_overlay)
		overlays += rust_overlay

/// Because do_after sleeps we register the signal here and defer via an async call
/datum/element/rust/proc/welder_tool_act(atom/source, obj/item/item, mob/user)
	SIGNAL_HANDLER // COMSIG_TOOL_ATTACK

	INVOKE_ASYNC(src, PROC_REF(handle_tool_use), source, item, user)
	return COMPONENT_CANCEL_TOOLACT

/// We call this from secondary_tool_act because we sleep with do_after
/datum/element/rust/proc/handle_tool_use(atom/source, obj/item/item, mob/user)
	switch(item.tool_behaviour)
		if(TOOL_WELDER)
			if(!item.tool_start_check(source, user, amount=1))
				return
			to_chat(user, "<span class='notice'>You start burning off the rust...</span>")

			if(!item.use_tool(source, user, 5 SECONDS, volume = item.tool_volume))
				return
			to_chat(user, "<span class='notice'>You burn off the rust!</span>")
			Detach(source)
			return

/// Prevents placing floor tiles on rusted turf
/datum/element/rust/proc/on_interaction(datum/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER // COMSIG_INTERACT_TARGET
	if(istype(tool, /obj/item/stack/tile) || istype(tool, /obj/item/stack/rods) || istype(tool, /obj/item/rcd))
		to_chat(user, "<span class='warning'>[source] is too rusted to build on!</span>")
		return ITEM_INTERACT_COMPLETE

/// For rust applied by heretics (if that ever happens) / revenants
/datum/element/rust/heretic

/datum/element/rust/heretic/Attach(atom/target, rust_icon, rust_icon_state)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return .
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/element/rust/heretic/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	UnregisterSignal(source, COMSIG_ATOM_EXITED)
	for(var/obj/effect/glowing_rune/rune_to_remove in source)
		qdel(rune_to_remove)
	for(var/mob/living/victim in source)
		victim.remove_status_effect(STATUS_EFFECT_RUST_CORRUPTION)

/datum/element/rust/heretic/proc/on_entered(turf/source, atom/movable/entered, ...)
	SIGNAL_HANDLER

	if(!isliving(entered))
		return
	var/mob/living/victim = entered
	if(istype(victim, /mob/living/simple_animal/revenant))
		return
	victim.apply_status_effect(STATUS_EFFECT_RUST_CORRUPTION)

/datum/element/rust/heretic/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!isliving(gone))
		return
	var/mob/living/leaver = gone
	leaver.remove_status_effect(STATUS_EFFECT_RUST_CORRUPTION)

// Small visual effect imparted onto rusted things by revenants.
/obj/effect/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = SIGIL_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/glowing_rune/Initialize(mapload)
	. = ..()
	pixel_y = rand(-6, 6)
	pixel_x = rand(-6, 6)
	icon_state = "small_rune_[rand(1, 12)]"
	update_appearance()


/obj/item/bikehorn/rubberducky/debug_pad
	name = "bitchass pad"
	desc = "fun fact this testing item is a subtype of a rubber duck"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "test_pad_base"

/obj/item/bikehorn/rubberducky/debug_pad/attack_self__legacy__attackchain(mob/user)
	new /obj/effect/debug_pad(get_turf(user))
	qdel(src)

/obj/effect/debug_pad
	name = "bitchass pad"
	desc = "fun fact this testing effect is not a subtype of a rubber duck"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "test_pad_deploy"

/obj/effect/debug_pad/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(blink_motherfucker)), 10 SECONDS)

/obj/effect/debug_pad/proc/blink_motherfucker()
	icon_state = "test_pad_blink"
	do_sparks(4, 0, src)
	addtimer(CALLBACK(src, PROC_REF(no_blink)), 5 SECONDS)

/obj/effect/debug_pad/proc/no_blink()
	icon_state = "test_pad_base"
	do_sparks(4, 0, src)
	set_light(3, 0.5, LIGHT_COLOR_DARKGREEN)
	new /obj/effect/funny_debug_effect(get_turf(src))

/obj/effect/funny_debug_effect
	icon = 'icons/obj/lighting.dmi'
	icon_state = "qpad-charge"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/funny_debug_effect/Initialize(mapload)
	. = ..()
	appearance_flags |= KEEP_TOGETHER
	var/icon/our_icon = icon('icons/obj/lighting.dmi', "qpad-charge")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") //Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) //Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	addtimer(CALLBACK(src, PROC_REF(bullshit)), 1 SECONDS)

/obj/effect/funny_debug_effect/proc/bullshit()
	new /obj/effect/funny_debug_effect_one_point_five(get_turf(src))
	qdel(src)

/obj/effect/funny_debug_effect_one_point_five
	icon = 'icons/obj/lighting.dmi'
	icon_state = "qpad-charge2"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/funny_debug_effect_one_point_five/Initialize(mapload)
	. = ..()
	appearance_flags |= KEEP_TOGETHER
	var/icon/our_icon = icon('icons/obj/lighting.dmi', "qpad-charge2")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") //Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) //Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	addtimer(CALLBACK(src, PROC_REF(sparky)), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(thank_you_next)), 24 SECONDS)


/obj/effect/funny_debug_effect_one_point_five/proc/sparky()
	new /obj/effect/funny_debug_portal(get_turf(src))
	do_sparks(4, 0, src)

/obj/effect/funny_debug_effect_one_point_five/proc/thank_you_next()
	new /obj/effect/funny_debug_effect_two(get_turf(src))


/obj/effect/funny_debug_portal
	icon_state = "bluespace"
	icon = 'icons/obj/projectiles.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 24

/obj/effect/funny_debug_portal/Initialize(mapload)
	. = ..()
	//transform *= 0.25
	appearance_flags |= KEEP_TOGETHER | PIXEL_SCALE
	var/icon/our_icon = icon('icons/obj/projectiles.dmi', "bluespace")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") //Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) //Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	addtimer(CALLBACK(src, PROC_REF(worms_my_hole)), 25 SECONDS)
	animate(src, transform = matrix().Scale(0.25), time = 0.1 SECONDS)
	animate(transform = matrix().Scale(1, 2), time = 24 SECONDS)
	animate(transform = matrix().Scale(0.5), time = 0.9 SECONDS)

/obj/effect/funny_debug_portal/proc/worms_my_hole()
	new /obj/effect/funny_debug_portal_two(get_turf(src))
	do_sparks(4, 0, src)
	qdel(src)

/obj/effect/funny_debug_portal_two
	icon_state = "kinesis"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 24

/obj/effect/funny_debug_portal_two/Initialize(mapload)
	. = ..()
	set_light(5, 2, LIGHT_COLOR_DARKGREEN)
	//transform *= 0.25
	var/obj/effect/warp_effect/bsg/warp = new /obj/effect/warp_effect/bsg(get_turf(src))
	warp.pixel_y = 24
	appearance_flags |= KEEP_TOGETHER | PIXEL_SCALE
	var/icon/our_icon = icon('icons/effects/effects.dmi', "kinesis")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") //Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) //Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
	animate(src, transform = matrix().Scale(0.66), time = 0.1 SECONDS)
	animate(transform = matrix().Scale(1, 1.22), time = 5 SECONDS)
	animate(transform = matrix().Scale(1.2, 1.66), time = 15 SECONDS)

/obj/effect/funny_debug_effect_two
	icon = 'icons/obj/lighting.dmi'
	icon_state = "qpad-beam"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/funny_debug_effect_two/Initialize(mapload)
	. = ..()
	appearance_flags |= KEEP_TOGETHER
	var/icon/our_icon = icon('icons/obj/lighting.dmi', "qpad-beam")
	var/icon/alpha_mask
	alpha_mask = new('icons/effects/effects.dmi', "scanline") //Scanline effect.
	our_icon.AddAlphaMask(alpha_mask) //Finally, let's mix in a distortion effect.
	icon = our_icon
	color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0)
	var/mutable_appearance/theme_icon = mutable_appearance('icons/misc/pic_in_pic.dmi', "room_background", appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon
