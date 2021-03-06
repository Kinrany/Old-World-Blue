/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/r_n_d/protolathe
	name = "\improper Protolathe"
	icon_state = "protolathe"
	flags = OPENCONTAINER
	circuit = /obj/item/weapon/circuitboard/protolathe

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 5000

	max_material_storage = 100000 //All this could probably be done better with a list but meh.
	materials = list(
		DEFAULT_WALL_MATERIAL = 0,
		"glass" = 0,
		"gold" = 0,
		"silver" = 0,
		"phoron" = 0,
		"uranium" = 0,
		"diamond" = 0
	)

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		T += G.reagents.maximum_volume
	create_reagents(T)
	max_material_storage = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		max_material_storage += M.rating * 75000
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating
	mat_efficiency = 1 - (T - 2) / 8

/obj/machinery/r_n_d/protolathe/update_icon()
	if(panel_open)
		icon_state = "protolathe_t"
	else
		icon_state = "protolathe"

/obj/machinery/r_n_d/protolathe/proc/Build(var/datum/design/D)
	if(!canBuild(D))
		return 0
	busy = 1
	var/power = active_power_usage
	for(var/M in D.materials)
		power += round(D.materials[M] / 5)
	power = max(active_power_usage, power)

	var/key = usr.key	//so we don't lose the info during the spawn delay
	sleep(16)
	flick("protolathe_n",src)
	use_power(power)
	sleep(16)
	for(var/M in D.materials)
		materials[M] = max(0, materials[M] - D.materials[M] * mat_efficiency)

	for(var/C in D.chemicals)
		reagents.remove_reagent(C, D.materials[C] * mat_efficiency)

	if(D.build_path)
		var/obj/new_item = new D.build_path(loc)

		if( new_item.type == /obj/item/storage/backpack/holding )
			new_item.investigate_log("built by [key]","singulo")

		new_item.reliability = D.reliability
		if(mat_efficiency != 1) // No matter out of nowhere
			if(new_item.matter && new_item.matter.len > 0)
				for(var/i in new_item.matter)
					new_item.matter[i] = new_item.matter[i] * mat_efficiency
	busy = 0
