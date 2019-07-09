//I will need to recode parts of this but I am way too tired atm
/obj/effect/blob
	name = "ravaging mass"
	desc = "A pulsating mass of interwoven tendrils."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob"
	light_outer_range = 2
	light_color = "#b5ff5b"
	density = 1
	opacity = 1
	anchored = 1
	mouse_opacity = 2
	obj_flags = OBJ_FLAG_DAMAGEABLE

	plane = BLOB_PLANE
	layer = BLOB_SHIELD_LAYER

	max_health = 30
	sound_destroyed = 'sound/effects/splat.ogg'
	var/regen_rate = 5
	var/brute_resist = 4
	var/fire_resist = 1
	var/laser_resist = 2	// Special resist for laser based weapons - Emitters or handheld energy weaponry. Damage is divided by this and THEN by fire_resist.
	var/expandType = /obj/effect/blob
	var/secondary_core_growth_chance = 5 //% chance to grow a secondary blob core instead of whatever was suposed to grown. Secondary cores are considerably weaker, but still nasty.
	var/damage_min = 20
	var/damage_max = 40
	var/pruned = FALSE
	var/product = /obj/item/weapon/blob_tendril

/obj/effect/blob/New(loc)
	health = max_health
	update_icon()
	return ..(loc)

/obj/effect/blob/CanPass(var/atom/movable/mover, vra/turf/target, var/height = 0, var/air_group = 0)
	if(air_group || height == 0)
		return 1
	return 0

/obj/effect/blob/ex_act(var/severity)
	switch(severity)
		if(1)
			take_damage(rand(100, 120) / brute_resist)
		if(2)
			take_damage(rand(60, 100) / brute_resist)
		if(3)
			take_damage(rand(20, 60) / brute_resist)

/obj/effect/blob/on_update_icon()
	if(health > max_health / 2)
		icon_state = "blob"
	else
		icon_state = "blob_damaged"

/obj/effect/blob/proc/regen()
	health = min(health + regen_rate, max_health)
	update_icon()

/obj/effect/blob/proc/expand(var/turf/T)
	if(istype(T, /turf/unsimulated/) || istype(T, /turf/space) || (istype(T, /turf/simulated/mineral) && T.density))
		return
	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/SW = T
		SW.take_damage(80)
		return
	var/obj/structure/girder/G = locate() in T
	if(G)
		if(prob(40))
			G.dismantle()
		return
	var/obj/structure/window/W = locate() in T
	if(W)
		W.kill()
		return
	var/obj/structure/grille/GR = locate() in T
	if(GR)
		qdel(GR)
		return
	for(var/obj/machinery/door/D in T) // There can be several - and some of them can be open, locate() is not suitable
		if(D.density)
			D.ex_act(2)
			return
	var/obj/structure/foamedmetal/F = locate() in T
	if(F)
		qdel(F)
		return
	var/obj/structure/inflatable/I = locate() in T
	if(I)
		I.deflate(1)
		return

	var/obj/vehicle/V = locate() in T
	if(V)
		V.ex_act(2)
		return
	var/obj/mecha/M = locate() in T
	if(M)
		M.visible_message("<span class='danger'>The blob attacks \the [M]!</span>")
		M.take_damage(40)
		return
	var/obj/machinery/camera/CA = locate() in T
	if(CA)
		CA.take_damage(30)
		return

	// Above things, we destroy completely and thus can use locate. Mobs are different.
	for(var/mob/living/L in T)
		if(L.stat == DEAD)
			continue
		var/blob_damage = pick(DAM_BLUNT, DAM_BURN)
		L.visible_message("<span class='danger'>A tendril flies out from \the [src] and smashes into \the [L]!</span>", "<span class='danger'>A tendril flies out from \the [src] and smashes into you!</span>")
		playsound(loc, 'sound/effects/attackblob.ogg', 50, 1)
		L.apply_damage(rand(damage_min, damage_max), blob_damage, used_weapon = "blob tendril")
		return
	if(!(locate(/obj/effect/blob/core) in range(T, 2)) && prob(secondary_core_growth_chance))
		new/obj/effect/blob/core/secondary(T)
	else
		new expandType(T, min(health, 30))

/obj/effect/blob/proc/pulse(var/forceLeft, var/list/dirs)
	regen()
	sleep(4)
	var/pushDir = pick(dirs)
	var/turf/T = get_step(src, pushDir)
	var/obj/effect/blob/B = (locate() in T)
	if(!B)
		if(prob(health))
			expand(T)
		return
	if(forceLeft)
		B.pulse(forceLeft - 1, dirs)

/obj/effect/blob/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return

	if(IsDamageTypeBrute(Proj.damtype))
		take_damage(Proj.force / brute_resist)
	else if(IsDamageTypeBurn(Proj.damtype))
		take_damage((Proj.force / laser_resist) / fire_resist)
	return 0

/obj/effect/blob/attackby(var/obj/item/weapon/W, var/mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(src)
	playsound(loc, 'sound/effects/attackblob.ogg', 50, 1)
	if(isWirecutter(W))
		if(prob(user.skill_fail_chance(SKILL_SCIENCE, 90, SKILL_EXPERT)))
			to_chat(user, SPAN_NOTICE("You fail to collect a sample from \the [src]."))
			return
		else	
			if(!pruned)
				to_chat(user, SPAN_NOTICE("You collect a sample from \the [src]."))
				new product(user.loc)
				pruned = TRUE
				return
			else
				to_chat(user, SPAN_NOTICE("\The [src] has already been pruned."))
				return

	var/damage = 0
	if(IsDamageTypeBrute(W.damtype))
		damage = (W.force / fire_resist)
		if(isWelder(W))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
	else if(IsDamageTypeBurn(W.damtype))
		damage = (W.force / brute_resist)
	take_damage(damage)
	return

/obj/effect/blob/core
	name = "master nucleus"
	desc = "A huge glowing nucleus surrounded by thick tendrils."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_core"
	max_health = 200
	brute_resist = 1
	fire_resist = 4
	regen_rate = 2

	layer = BLOB_CORE_LAYER

	damage_min = 30
	damage_max = 40
	expandType = /obj/effect/blob/shield
	product = /obj/item/weapon/blob_tendril/core
	var/blob_may_process = 1
	var/growth_range = 10 // Maximal distance for new blob pieces from this core.

// Rough icon state changes that reflect the core's health
/obj/effect/blob/core/on_update_icon()
	var/health_percent = (health / max_health) * 100
	switch(health_percent)
		if(66 to INFINITY)
			icon_state = "blob_core"
		if(33 to 66)
			icon_state = "blob_node"
		if(-INFINITY to 33)
			icon_state = "blob_factory"

/obj/effect/blob/core/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/blob/core/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/blob/core/Process()
	set waitfor = 0
	if(!blob_may_process)
		return
	blob_may_process = 0
	sleep(0)
	pulse(20, GLOB.alldirs)
	pulse(20, GLOB.alldirs)
	pulse(20, GLOB.alldirs)
	pulse(20, GLOB.alldirs)
	blob_may_process = 1

// Half the stats of a normal core. Blob has a very small probability of growing these when spreading. These will spread the blob further.
/obj/effect/blob/core/secondary
	name = "auxiliary nucleus"
	desc = "An interwoven mass of tendrils. A glowing nucleus pulses at its center."
	icon_state = "blob_node"
	max_health = 100
	regen_rate = 1
	growth_range = 3
	damage_min = 20
	damage_max = 30
	layer = BLOB_NODE_LAYER
	product = /obj/item/weapon/blob_tendril/core/aux

/obj/effect/blob/core/secondary/on_update_icon()
	icon_state = (health / max_health >= 0.5) ? "blob_node" : "blob_factory"

/obj/effect/blob/shield
	name = "shielding mass"
	desc = "A pulsating mass of interwoven tendrils. These seem particularly robust, but not quite as active."
	icon_state = "blob_idle"
	max_health = 60
	damage_min = 20
	damage_max = 35

/obj/effect/blob/shield/New()
	..()
	update_nearby_tiles()

/obj/effect/blob/shield/Destroy()
	set_density(0)
	update_nearby_tiles()
	..()

/obj/effect/blob/shield/on_update_icon()
	if(health > max_health * 2 / 3)
		icon_state = "blob_idle"
	else if(health > max_health / 3)
		icon_state = "blob"
	else
		icon_state = "blob_damaged"

/obj/effect/blob/shield/CanPass(var/atom/movable/mover, var/turf/target, var/height = 0, var/air_group = 0)
	return !density

/obj/item/weapon/blob_tendril
	name = "asteroclast tendril"
	desc = "A tendril removed from an asteroclast. It's entirely lifeless."
	icon = 'icons/mob/blob.dmi'
	icon_state = "tendril"
	item_state = "blob_tendril"
	w_class = ITEM_SIZE_LARGE
	attack_verb = list("smacked", "smashed", "whipped")
	var/is_tendril = TRUE
	var/types_of_tendril = list("solid", "fire")

/obj/item/weapon/blob_tendril/Initialize()
	. = ..()
	if(is_tendril)
		var/tendril_type
		tendril_type = pick(types_of_tendril)
		switch(tendril_type)
			if("solid")
				desc = "An incredibly dense tendril, removed from an asteroclast."
				force = 10
				color = COLOR_BRONZE
				origin_tech = list(TECH_MATERIAL = 2)
			if("fire")
				desc = "A tendril removed from an asteroclast. It's so hot that it almost hurts to hold onto it."
				damtype = DAM_BURN
				force = 15
				color = COLOR_AMBER
				origin_tech = list(TECH_POWER = 2)

/obj/item/weapon/blob_tendril/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(is_tendril && prob(50))
		force--
		if(force <= 0)
			visible_message("<span class='notice'>\The [src] crumbles apart!</span>")
			user.drop_from_inventory(src)
			new /obj/effect/decal/cleanable/ash(src.loc)
			qdel(src)

/obj/item/weapon/blob_tendril/core
	name = "asteroclast nucleus sample"
	desc = "A sample taken from an asteroclast's nucleus. It pulses with energy."
	icon_state = "core_sample"
	item_state = "blob_core"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_MATERIAL = 4, TECH_BLUESPACE = 5, TECH_BIO = 7)
	is_tendril = FALSE

/obj/item/weapon/blob_tendril/core/aux
	name = "asteroclast auxiliary nucleus sample"
	desc = "A sample taken from an asteroclast's auxiliary nucleus."
	icon_state = "core_sample_2"
	origin_tech = list(TECH_MATERIAL = 2, TECH_BLUESPACE = 3, TECH_BIO = 4)