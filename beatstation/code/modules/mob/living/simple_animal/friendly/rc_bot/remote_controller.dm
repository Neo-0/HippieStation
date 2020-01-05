//Remote controller
/obj/item/drone_controller
	name = "remote controller"
	desc = "A remote for steering robots."
	icon_state = "remote_control"
	icon = 'beatstation/icons/obj/device.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/mob/living/simple_animal/remote_control/RC
	var/linked = FALSE

/obj/item/drone_controller/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(RC && RC == A && linked)
		to_chat(user, "<span class='notice'>[src] is already linked to [A].</span>")
		return
	if(istype(A, /mob/living/simple_animal/remote_control))
		var/mob/living/simple_animal/remote_control/takeover = A
		if(takeover.remote || takeover.pilot)
			to_chat(user, "<span class='notice'>[takeover] is already under someone elses control. You attempt to reset it...</span>")
			if(do_after(user, 50, target = takeover))
				to_chat(takeover, "<span class='warning'>Someone has hacked [takeover]! Your remote has lost its link.</span>")
				takeover.eject_pilot()
				takeover.pilot = null
				takeover.remote = null
				linked = FALSE
				to_chat(user, "<span class='notice'>You've disconnected [takeover]. It is no longer linked to any remotes.</span>")
		to_chat(user, "<span class='notice'>You link [takeover] to your remote. You may now control it.</span>")
		if(!linked)
			linked = TRUE
		RC = takeover
		takeover.remote = src
		return
	
	return ..()

/obj/item/drone_controller/attack_self(mob/user)
	if(!RC)
		to_chat(user, "<span class='notice'>The remote isn't currently linked to anything. Use it on a controllable robot to sync the remote.</span>")
		return
	if(RC.wrapped)
		to_chat(user, "<span class='warning'>You cannot use [src] while [RC] is wrapped!</span>")
		return
	if(!RC.check_dist())
		return
	if(linked && RC && !RC.wrapped)
		RC.assume_control(user)

/obj/item/drone_controller/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/F = I
		RC.access_card.access = null // just a double check, so it won't store double access anyway
		RC.access_card.access = F.access
		to_chat(user, "<span class='notice'>[src] takes access from [I]</span>")

/obj/item/drone_controller/examine(mob/user)
	. = ..()
	if(linked)
		if(RC.wrapped)
			. += "<span class='bold'><font color='#002AFF'>[RC] is currently wrapped!</font></span>"
		. += "<span class='bold'>It is currently synced with [RC].</span>"
		. += "<span class='bold'>[RC] Integrity: <font color='#990e0e'>[RC.health]/[RC.maxHealth]</font></span>"
	else
		. += "The remote is currently not synced with anything."
