/obj/machinery/atmospherics/tvalve
	icon = 'icons/atmos/tvalve.dmi'
	icon_state = "map_tvalve0"

	name = "manual switching valve"
	desc = "A pipe valve."

	level = 1
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST

	var/state = 0 // 0 = go straight, 1 = go to side
	var/mirrored = FALSE

	// like a trinary component, node1 is input, node2 is side output, node3 is straight output
	var/obj/machinery/atmospherics/node3

	var/datum/pipe_network/network_node1
	var/datum/pipe_network/network_node2
	var/datum/pipe_network/network_node3

/obj/machinery/atmospherics/tvalve/bypass
	icon_state = "map_tvalve1"
	state = 1

/obj/machinery/atmospherics/tvalve/New()
	. = ..()
	ADD_SAVED_VAR(state)

/obj/machinery/atmospherics/tvalve/Destroy()
	loc = null

	if(node1)
		node1.disconnect(src)
		qdel(network_node1)
	if(node2)
		node2.disconnect(src)
		qdel(network_node2)
	if(node3)
		node3.disconnect(src)
		qdel(network_node3)

	node1 = null
	node2 = null
	node3 = null

	return ..()

/obj/machinery/atmospherics/tvalve/atmos_init()
	..()
	setup_initialize_directions()
	var/node1_dir
	var/node2_dir
	var/node3_dir

	node1_dir = turn(dir, 180)
	node2_dir = turn(dir, mirrored? 90 : -90)
	node3_dir = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
		if(target.initialize_directions & get_dir(target,src))
			if (check_connect_types(target,src))
				node1 = target
				break
	for(var/obj/machinery/atmospherics/target in get_step(src,node2_dir))
		if(target.initialize_directions & get_dir(target,src))
			if (check_connect_types(target,src))
				node2 = target
				break
	for(var/obj/machinery/atmospherics/target in get_step(src,node3_dir))
		if(target.initialize_directions & get_dir(target,src))
			if (check_connect_types(target,src))
				node3 = target
				break

	if(state)
		go_to_side() // 1
	else
		go_straight() // 2

	queue_icon_update()
	update_underlays()

/obj/machinery/atmospherics/tvalve/setup_initialize_directions()
	switch(dir)
		if(NORTH)
			initialize_directions = SOUTH|NORTH|EAST
		if(SOUTH)
			initialize_directions = NORTH|SOUTH|WEST
		if(EAST)
			initialize_directions = WEST|EAST|SOUTH
		if(WEST)
			initialize_directions = EAST|WEST|NORTH

/obj/machinery/atmospherics/tvalve/on_update_icon(animation)
	if(animation)
		flick("tvalve[src.state][!src.state]",src)
	else
		icon_state = "tvalve[state]"

/obj/machinery/atmospherics/tvalve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))

		if(istype(src, /obj/machinery/atmospherics/tvalve/mirrored))
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/tvalve/hide(var/i)
	update_underlays()

/obj/machinery/atmospherics/tvalve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network_node1 = new_network
		if(state)
			network_node2 = new_network
		else
			network_node3 = new_network
	else if(reference == node2)
		network_node2 = new_network
		if(state)
			network_node1 = new_network
	else if(reference == node3)
		network_node3 = new_network
		if(!state)
			network_node1 = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	if(state)
		if(reference == node1)
			if(node2)
				return node2.network_expand(new_network, src)
		else if(reference == node2)
			if(node1)
				return node1.network_expand(new_network, src)
	else
		if(reference == node1)
			if(node3)
				return node3.network_expand(new_network, src)
		else if(reference == node3)
			if(node1)
				return node1.network_expand(new_network, src)

	return null

/obj/machinery/atmospherics/tvalve/proc/go_to_side()

	if(state) return 0

	state = 1
	update_icon()

	if(network_node1)
		qdel(network_node1)
	if(network_node3)
		qdel(network_node3)
	build_network()

	if(network_node1&&network_node2)
		network_node1.merge(network_node2)
		network_node2 = network_node1

	if(network_node1)
		network_node1.update = 1
	else if(network_node2)
		network_node2.update = 1

	return 1

/obj/machinery/atmospherics/tvalve/proc/go_straight()

	if(!state)
		return 0

	state = 0
	update_icon()

	if(network_node1)
		qdel(network_node1)
	if(network_node2)
		qdel(network_node2)
	build_network()

	if(network_node1&&network_node3)
		network_node1.merge(network_node3)
		network_node3 = network_node1

	if(network_node1)
		network_node1.update = 1
	else if(network_node3)
		network_node3.update = 1

	return 1

/obj/machinery/atmospherics/tvalve/attack_ai(mob/user as mob)
	return

/obj/machinery/atmospherics/tvalve/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	update_icon(1)
	sleep(10)
	if (src.state)
		src.go_straight()
	else
		src.go_to_side()

/obj/machinery/atmospherics/tvalve/Process()
	..()
	return PROCESS_KILL

/obj/machinery/atmospherics/tvalve/build_network()
	if(!network_node1 && node1)
		network_node1 = new /datum/pipe_network()
		network_node1.normal_members += src
		network_node1.build_network(node1, src)

	if(!network_node2 && node2)
		network_node2 = new /datum/pipe_network()
		network_node2.normal_members += src
		network_node2.build_network(node2, src)

	if(!network_node3 && node3)
		network_node3 = new /datum/pipe_network()
		network_node3.normal_members += src
		network_node3.build_network(node3, src)

/obj/machinery/atmospherics/tvalve/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node1)
		return network_node1

	if(reference==node2)
		return network_node2

	if(reference==node3)
		return network_node3

	return null

/obj/machinery/atmospherics/tvalve/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network_node1 == old_network)
		network_node1 = new_network
	if(network_node2 == old_network)
		network_node2 = new_network
	if(network_node3 == old_network)
		network_node3 = new_network

	return 1

/obj/machinery/atmospherics/tvalve/return_network_air(datum/network/reference)
	return null

/obj/machinery/atmospherics/tvalve/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node1)
		qdel(network_node1)
		node1 = null

	else if(reference==node2)
		qdel(network_node2)
		node2 = null

	else if(reference==node3)
		qdel(network_node3)
		node2 = null

	update_underlays()

	return null

//
// Digital Tvalve
//
/obj/machinery/atmospherics/tvalve/digital		// can be controlled by AI
	name 				= "digital switching valve"
	desc 				= "A digitally controlled valve."
	icon 				= 'icons/atmos/digital_tvalve.dmi'
	//Radio
	id_tag 				= null
	frequency 			= null
	radio_filter_in 	= RADIO_ATMOSIA
	radio_filter_out 	= RADIO_ATMOSIA
	radio_check_id 		= TRUE

/obj/machinery/atmospherics/tvalve/digital/bypass
	icon_state = "map_tvalve1"
	state = 1

/obj/machinery/atmospherics/tvalve/digital/on_update_icon()
	..()
	if(!powered())
		icon_state = "tvalvenopower"

/obj/machinery/atmospherics/tvalve/digital/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/atmospherics/tvalve/digital/attack_hand(mob/user as mob)
	if(!powered())
		return
	if(!src.allowed(user))
		to_chat(user, SPAN_WARNING("Access denied."))
		return
	return ..()

/obj/machinery/atmospherics/tvalve/digital/OnSignal(datum/signal/signal)
	if(!..())
		return

	switch(signal.data["command"])
		if("valve_open")
			if(!state)
				go_to_side()

		if("valve_close")
			if(state)
				go_straight()

		if("valve_toggle")
			if(state)
				go_straight()
			else
				go_to_side()

/obj/machinery/atmospherics/tvalve/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(!isWrench(W))
		return ..()
	// if (istype(src, /obj/machinery/atmospherics/tvalve/digital))
	// 	to_chat(user, "<span class='warning'>You cannot unwrench \the [src], it's too complicated.</span>")
	// 	return 1
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		to_chat(user, "<span class='warnng'>You cannot unwrench \the [src], it too exerted due to internal pressure.</span>")
		add_fingerprint(user)
		return 1
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (do_after(user, 40, src))
		user.visible_message( \
			"<span class='notice'>\The [user] unfastens \the [src].</span>", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear a ratchet.")
		new /obj/item/pipe(loc, make_from=src)
		qdel(src)

/obj/machinery/atmospherics/tvalve/mirrored
	icon_state = "map_tvalvem0"
	mirrored = TRUE

/obj/machinery/atmospherics/tvalve/mirrored/bypass
	icon_state = "map_tvalvem1"
	mirrored = TRUE
	state = 1

/obj/machinery/atmospherics/tvalve/mirrored/setup_initialize_directions()
	switch(dir)
		if(NORTH)
			initialize_directions = SOUTH|NORTH|WEST
		if(SOUTH)
			initialize_directions = NORTH|SOUTH|EAST
		if(EAST)
			initialize_directions = WEST|EAST|NORTH
		if(WEST)
			initialize_directions = EAST|WEST|SOUTH

// /obj/machinery/atmospherics/tvalve/mirrored/atmos_init()
// 	..()
// 	var/node1_dir
// 	var/node2_dir
// 	var/node3_dir

// 	node1_dir = turn(dir, 180)
// 	node2_dir = turn(dir, 90)
// 	node3_dir = dir

// 	for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
// 		if(target.initialize_directions & get_dir(target,src))
// 			node1 = target
// 			break
// 	for(var/obj/machinery/atmospherics/target in get_step(src,node2_dir))
// 		if(target.initialize_directions & get_dir(target,src))
// 			node2 = target
// 			break
// 	for(var/obj/machinery/atmospherics/target in get_step(src,node3_dir))
// 		if(target.initialize_directions & get_dir(target,src))
// 			node3 = target
// 			break

// 	update_icon()
// 	update_underlays()

/obj/machinery/atmospherics/tvalve/mirrored/update_icon(animation)
	if(animation)
		flick("tvalvem[src.state][!src.state]",src)
	else
		icon_state = "tvalvem[state]"

/obj/machinery/atmospherics/tvalve/mirrored/digital		// can be controlled by AI
	name = "digital switching valve"
	desc = "A digitally controlled valve."
	icon = 'icons/atmos/digital_tvalve.dmi'
	//Radio
	id_tag 				= null
	frequency 			= null
	radio_filter_in 	= RADIO_ATMOSIA
	radio_filter_out 	= RADIO_ATMOSIA
	radio_check_id 		= TRUE
	mirrored 			= TRUE

/obj/machinery/atmospherics/tvalve/mirrored/digital/bypass
	icon_state = "map_tvalvem1"
	state = 1
	mirrored = TRUE

/obj/machinery/atmospherics/tvalve/mirrored/digital/update_icon()
	..()
	if(!powered())
		icon_state = "tvalvemnopower"

/obj/machinery/atmospherics/tvalve/mirrored/digital/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/atmospherics/tvalve/mirrored/digital/attack_hand(mob/user as mob)
	if(!powered())
		to_chat(user, SPAN_WARNING("The valve is unpowered!"))
		return
	if(!src.allowed(user))
		to_chat(user, SPAN_WARNING("Access denied."))
		return
	..()

/obj/machinery/atmospherics/tvalve/mirrored/digital/OnSignal(datum/signal/signal)
	if(!..())
		return 
	switch(signal.data["command"])
		if("valve_open")
			if(!state)
				go_to_side()

		if("valve_close")
			if(state)
				go_straight()

		if("valve_toggle")
			if(state)
				go_straight()
			else
				go_to_side()