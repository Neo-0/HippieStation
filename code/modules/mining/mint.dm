/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/economy.dmi'
	icon_state = "coinpress0"
	density = TRUE
	input_dir = EAST
	ui_x = 300
	ui_y = 250

	var/produced_coins = 0 // how many coins the machine has made in it's last cycle
	var/processing = FALSE
	var/chosen = MAT_METAL //which material will be used to make coins

/obj/machinery/mineral/mint/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_PLASMA, MAT_SILVER, MAT_GOLD, MAT_URANIUM, MAT_DIAMOND, MAT_BANANIUM), MINERAL_MATERIAL_AMOUNT * 50, FALSE, /obj/item/stack)



/obj/machinery/mineral/mint/process()
	var/turf/T = get_step(src, input_dir)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	for(var/obj/item/stack/O in T)
		var/inserted = materials.insert_item(O)
		if(inserted)
			qdel(O)

	if(processing)
		var/datum/material/M = chosen

		if(!M)
			processing = FALSE
			icon_state = "coinpress0"
		return

		icon_state = "coinpress1"
		var/coin_mat = MINERAL_MATERIAL_AMOUNT

		for(var/sheets in 1 to 2)
			if(materials.use_amount_mat(coin_mat, chosen))
				for(var/coin_to_make in 1 to 5)
					create_coins()
					produced_coins++
			else
				var/found_new = FALSE
				for(var/datum/material/inserted_material in materials.materials)
					var/amount = materials.get_material_amount(inserted_material)

					if(amount)
						chosen = inserted_material
						found_new = TRUE

				if(!found_new)
					processing = FALSE
	else
		icon_state = "coinpress0"

/obj/machinery/mineral/mint/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mint", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/mineral/mint/ui_data()
	var/list/data = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	for(var/datum/material/inserted_material in materials.materials)
		var/amount = materials.get_material_amount(inserted_material)

		if(!amount)
			continue

		data["inserted_materials"] += list(list(
			"material" = inserted_material.name,
			"amount" = amount
		))

		if(chosen == inserted_material)
			data["chosen_material"] = inserted_material.name

	data["produced_coins"] = produced_coins
	data["processing"] = processing

	return data;

/obj/machinery/mineral/mint/ui_act(action, params, datum/tgui/ui)
	switch(action)
		if ("startpress")
			if (!processing)
				produced_coins = 0
			processing = TRUE
		if ("stoppress")
		processing = FALSE
		if ("changematerial")
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			for(var/datum/material/mat in materials.materials)
				if (params["material_name"] == mat.name)
					chosen = mat

/obj/machinery/mineral/mint/proc/create_coins(P)
	var/turf/T = get_step(src,output_dir)
	if(T)
		var/obj/item/O = new P(src)
		var/obj/item/storage/bag/money/M = locate(/obj/item/storage/bag/money, T)
		if(!M)
			M = new /obj/item/storage/bag/money(src)
			unload_mineral(M)
		O.forceMove(M)
