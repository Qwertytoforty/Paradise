var/global/datum/controller/process/lighting/lighting_controller

/datum/controller/process/lighting/setup()
	name = "lighting"
	schedule_interval = LIGHTING_INTERVAL
	start_delay = 1
	lighting_controller = src

	create_lighting_overlays()

/datum/controller/process/lighting/statProcess()
	..()
	stat(null, "[last_light_count] lights, [last_overlay_count] overlays")

// Lighting process code located in modules\lighting\lighting_process.dm