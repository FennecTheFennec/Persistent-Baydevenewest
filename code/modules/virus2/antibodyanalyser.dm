/obj/machinery/disease2/antibodyanalyser
	name = "antibody analyser"
	desc = "An advanced machine that analyses pure antibody samples and stores the structure of them on the ExoNet in exchange for cargo points."
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1
	circuit_type = /obj/item/weapon/circuitboard/antibodyanalyser

	var/scanning = 0
	var/list/known_antibodies = list()
	var/obj/item/weapon/reagent_containers/container = null
	var/time_scanning_end

/obj/machinery/disease2/antibodyanalyser/New()
	..()
	ADD_SAVED_VAR(scanning)
	ADD_SAVED_VAR(known_antibodies)
	ADD_SAVED_VAR(container)
	ADD_SAVED_VAR(time_scanning_end)
	
	ADD_SKIP_EMPTY(known_antibodies)
	ADD_SKIP_EMPTY(container)
	ADD_SKIP_EMPTY(time_scanning_end)

/obj/machinery/disease2/antibodyanalyser/before_save()
	. = ..()
	//Convert to absolute time
	if(scanning && time_scanning_end)
		time_scanning_end = world.time - time_scanning_end

/obj/machinery/disease2/antibodyanalyser/after_load()
	. = ..()
	//Convert to relative time
	if(scanning && time_scanning_end)
		time_scanning_end = world.time + time_scanning_end

/obj/machinery/disease2/antibodyanalyser/Destroy()
	if(container)
		container.forceMove(get_turf(src))
		container = null
	. = ..()

/obj/machinery/disease2/antibodyanalyser/on_update_icon()
	if(scanning)
		icon_state = "analyser_processing"
	else
		icon_state = "analyser"

/obj/machinery/disease2/antibodyanalyser/attackby(var/obj/I as obj, var/mob/user as mob)
	if(default_deconstruction_screwdriver(user, I))
		return 1
	else if(default_deconstruction_crowbar(user, I))
		return 1
	else if(istype(I,/obj/item/weapon/reagent_containers))
		if(!container && user.unEquip(I))
			container = I
			I.forceMove(src)
			user.visible_message("[user] adds a sample to \the [src]!", "You add a sample to \the [src]!")

		if(container.reagents.has_reagent(/datum/reagent/antibodies))
			scanning = TRUE
			time_scanning_end = world.time + 5 SECONDS
			update_icon()
		else
			container.forceMove(get_turf(src))
			container = null
			src.state("\The [src] buzzes, \"Failed to identify a pure sample of antibodies in the solution.\"")
		return 1
	else 
		return ..()

/obj/machinery/disease2/antibodyanalyser/Process()
	if(inoperable())
		return
	if(scanning && world.time > time_scanning_end)
		scanning  = FALSE
		time_scanning_end = null
		finish_scan()
	return

/obj/machinery/disease2/antibodyanalyser/proc/finish_scan()
	if(!container.reagents.has_reagent(/datum/reagent/antibodies)) //if there are no antibody reagents, return false
		return 0
	else
		var/list/data = container.reagents.get_data(/datum/reagent/antibodies) //now that we know there are antibody reagents, get the data
		var/list/given_antibodies = data["antibodies"] //now check what specific antibodies it's holding
		var/list/common_antibodies = known_antibodies & given_antibodies
		var/list/unknown_antibodies = common_antibodies ^ given_antibodies
		if(unknown_antibodies.len)
			var/payout = unknown_antibodies.len * 45
			SSsupply.add_points_from_source(payout, "virology")
			ping("\The [src] pings, \"Successfully uploaded new antibodies to the ExoNet.\"")
			known_antibodies |= unknown_antibodies //Add the new antibodies to list
		else
			src.state("\The [src] buzzes, \"Failed to identify any new antibodies.\"")
		if(!given_antibodies.len) //return if no antibodies
			return 0

	container.forceMove(get_turf(src))
	container = null
	update_icon()
