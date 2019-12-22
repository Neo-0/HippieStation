/datum/hud/remote_bot/New(mob/living/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	static_inventory += using

	build_hand_slots()

	if(mymob.possible_a_intents)
		if(mymob.possible_a_intents.len == 4)
			// All possible intents - full intent selector
			action_intent = new /obj/screen/act_intent/segmented
		else
			action_intent = new /obj/screen/act_intent
			action_intent.icon = ui_style
		action_intent.icon_state = mymob.a_intent
		static_inventory += action_intent

	mymob.client.screen = list()

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

/datum/hud/remote_control/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/D = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in D.held_items)
			I.screen_loc = ui_hand_position(D.get_held_index_of_item(I))
			D.client.screen += I
	else
		for(var/obj/item/I in D.held_items)
			I.screen_loc = null
			D.client.screen -= I
