//Remote Control Robot picking up mob system
/obj/item/remote_control_bot
	name = "bugged mob holder"
	desc = "You shouldn't be with that"
	icon = 'beatstation/icons/mob/rc-bot.dmi'
	icon_state = "remote_control_item"
	w_class = WEIGHT_CLASS_NORMAL
	var/mob/living/simple_animal/remote_control/held_mob
	var/destroying = FALSE

/obj/item/remote_control_bot/Initialize(mapload, mob/living/M)
	. = ..()
	deposito(M)

/obj/item/remote_control_bot/Destroy()
	destroying = TRUE
	if(held_mob)
		release_mob(FALSE)
	return ..()

/obj/item/remote_control_bot/attack_self(mob/user)
	if(held_mob)
		release_mob()

/obj/item/remote_control_bot/proc/deposito(mob/living/L)
	if(!istype(L))
		return FALSE
	L.setDir(SOUTH)
	update_visual(L)
	held_mob = L
	L.forceMove(src)
	name = "remote control bot"
	desc = "A wrapped remote controlled bot"
	return TRUE

/obj/item/remote_control_bot/proc/update_visual(mob/living/L)
	appearance = L.appearance
	var/mob/living/simple_animal/remote_control/D = L
	if(!D)
		return ..()
	icon = 'beatstation/icons/mob/rc-bot.dmi'
	icon_state = "remote_control_item"

/obj/item/remote_control_bot/proc/release_mob(del_on_release = TRUE)
	if(!held_mob)
		if(del_on_release && !destroying)
			qdel(src)
		return FALSE
	held_mob.forceMove(get_turf(held_mob))
	held_mob.wrapped = FALSE
	held_mob.reset_perspective()
	held_mob.setDir(SOUTH)
	held_mob.visible_message("<span class='warning'>[held_mob] unwrapped down!</span>")
	held_mob = null
	if(del_on_release && !destroying)
		qdel(src)
	return TRUE
