// the basics of rc bots
/mob/living/simple_animal/remote_control/basic
	desc = "A simple remote controlled robot. The pilot is probably nearby."
	ventcrawler = 0 // probably?
	possible_a_intents = null
	melee_damage_lower = 0
	melee_damage_upper = 0
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 2
	minbodytemp = 250
	maxbodytemp = 350
	dextrous = FALSE
	dextrous_hud_type = /datum/hud/remote_bot
	see_in_dark = 2
	held_items = list(null)
	var/list/upgrades = list()

/mob/living/simple_animal/remote_control/basic/Move()
	check_dist()
	. = ..()

/mob/living/simple_animal/remote_control/basic/attackby(obj/item/I, mob/living/user, params)
	for(var/B in upgrades)
		if(I == B)
			to_chat(user, "<span class='warning'>[src] already have this upgrade!</span>")
			return
	/*if(I in upgrades)
		to_chat(user, "<span class='warning'>[src] already have this upgrade!</span>")
		return*/
	if(istype(I, /obj/item/rc_upgrade/mechanic_arms))
		var/obj/item/rc_upgrade/mechanic_arms/A = I
		to_chat(user, "<span class='notice'>You succeful install [A] to [src].</span>")
		dextrous = TRUE
		create_mob_hud()
		upgrades.Add(A)
		qdel(I)
		return
	else if(istype(I, /obj/item/rc_upgrade/range_upgrade))
		var/obj/item/rc_upgrade/range_upgrade/A = I
		to_chat(user, "<span class='notice'>You succeful install [A] to [src].</span>")
		range = 15
		upgrades.Add(A)
		qdel(I)
		return
	else if(istype(I, /obj/item/rc_upgrade/range_upgrade/adv))
		var/obj/item/rc_upgrade/range_upgrade/adv/A = I
		to_chat(user, "<span class='notice'>You succeful install [A] to [src].</span>")
		range = 20
		upgrades.Add(A)
		qdel(I)
		return
	else if(istype(I, /obj/item/rc_upgrade/speed_upgrade))
		var/obj/item/rc_upgrade/speed_upgrade/A = I
		to_chat(user, "<span class='notice'>You succeful install [A] to [src].</span>")
		speed = -1
		update_simplemob_varspeed()
		upgrades.Add(A)
		qdel(I)
		return
	return ..()

/mob/living/simple_animal/remote_control/basic/UnarmedAttack(atom/A)
	A.attack_animal(src)

/mob/living/simple_animal/remote_control/basic/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(check_click_intercept(params,A))
		return

	if(notransform)
		return

	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, params) & COMSIG_MOB_CANCEL_CLICKON)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(next_move > world.time)
		return

	var/obj/item/W = get_active_held_item()

	if(W == A)
		W.attack_self(src)
		update_inv_hands()
		return

	if(A in DirectAccess())
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A)
		return

	if(!loc.AllowClick())
		return

	if(CanReach(A,W))
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A,1)
	else
		if(W)
			W.afterattack(A,src,0,params)
