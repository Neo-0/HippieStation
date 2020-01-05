//Remote Control Robots
/mob/living/simple_animal/remote_control
	name = "remote control robot"
	desc = "A simple robot. The pilot is probably nearby."
	speak_emote = list("beeps")
	speech_span = SPAN_ROBOT
	icon_state = "remote_control"
	icon_living = "remote_control"
	icon = 'beatstation/icons/mob/rc-bot.dmi'
	ventcrawler = VENTCRAWLER_ALWAYS
	gender = NEUTER
	speed = 0
	wander = 0
	density = FALSE
	bubble_icon = "machine"
	status_flags = (CANPUSH | CANSTUN | CANKNOCKDOWN)
	possible_a_intents = list(INTENT_HELP, INTENT_HARM)
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = list(MOB_ROBOTIC)
	mob_size = MOB_SIZE_SMALL
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	hud_possible = list(DIAG_STAT_HUD, DIAG_HUD, ANTAG_HUD)
	minbodytemp = 0
	faction = list("neutral","silicon")
	dextrous = TRUE
	see_in_dark = 7
	can_be_held = TRUE
	held_items = list(null, null)
	maxbodytemp = INFINITY
	attacktext = "bumps into"
	maxHealth = 10
	health = 10
	environment_smash = 0
	melee_damage_lower = 1
	melee_damage_upper = 1
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	AIStatus = AI_OFF
	var/mob/living/pilot
	var/initial_pilot_health
	var/requires_pilot = TRUE
	var/obj/item/drone_controller/remote
	var/datum/action/innate/eject_rc/eject_act
	var/wrapped = FALSE
	var/range = 10
	//var/hacked = FALSE

/mob/living/simple_animal/remote_control/Initialize()
	. = ..()
	eject_act = new
	eject_act.Grant(src)
	access_card = new /obj/item/card/id(src)
	ADD_TRAIT(access_card, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/mob/living/simple_animal/remote_control/Destroy()
	qdel(access_card)
	qdel(eject_act)
	return ..()

/mob/living/simple_animal/remote_control/Login()
	..()
	to_chat(src, "<span class='notice'>You are now in control of [src]. To cease piloting, <span class='bold'>ctrl+click</span> on [src] or just press <span class='bold'>Disconnect</span> button.</span>")

/mob/living/simple_animal/remote_control/Life()
	. = ..()
	if(!.)
		if(pilot)
			eject_pilot()
			return FALSE
		else
			return FALSE
	if(requires_pilot && is_pilot_unsafe())
		eject_pilot()
		return FALSE

/mob/living/simple_animal/remote_control/death(gibbed)
	to_chat(src, "<span class='warning'>[src] was destroyed!</span>")
	eject_pilot()
	remote.linked = FALSE
	..()

/mob/living/simple_animal/remote_control/CtrlClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(requires_pilot && A == src)
		to_chat(src, "<span class='notice'>You cease piloting [src].</span>")
		eject_pilot()

/mob/living/simple_animal/remote_control/proc/is_pilot_unsafe()
	if(!pilot)
		to_chat(src, "<span class='alertwarning'>Your body went missing!</span>")
		return TRUE
	if(pilot.health < initial_pilot_health)
		to_chat(src, "<span class='alertwarning'>You're under attack!</span>")
		return TRUE
	if(pilot.restrained())
		to_chat(src, "<span class='alertwarning'>You're having trouble controlling [src] while handcuffed.</span>")
		return TRUE
	if(pilot.stat || pilot.incapacitated() || pilot.lying)
		to_chat(src, "<span class='alertwarning'>You can't control [src] while you're incapacitated!</span>")
		return TRUE
	if(remote.loc != pilot)
		to_chat(src, "<span class='alertwarning'>You dropped the remote!</span>")
		return TRUE

/mob/living/simple_animal/remote_control/proc/eject_pilot()
	if(pilot)
		if(mind)
			mind.transfer_to(pilot)
		else
			pilot.ckey = ckey
	else
		ghostize(0)
	pilot = null
	initial_pilot_health = null

/mob/living/simple_animal/remote_control/proc/assume_control(mob/living/user)
	if(pilot || !requires_pilot)
		to_chat(user, "<span class='notice'>It's already being piloted.</span>")
	else
		initial_pilot_health = user.health
		pilot = user
		if(pilot.mind)
			pilot.mind.transfer_to(src)
			update_inv_hands()
		else
			ckey = pilot.ckey

/mob/living/simple_animal/remote_control/proc/check_dist() // check the distance of the bot and the controller
	if(get_dist(remote.loc, get_turf(src)) >= range)
		to_chat(usr, "<span class='boldwarning'>The remote control robot is out of range!</span>")
		eject_pilot()
		return FALSE
	else
		return TRUE

/mob/living/simple_animal/remote_control/emp_act(severity)
	to_chat(src, "<span class='warning'>Bzzzzzzzzzt. Connection lost.</span>")
	eject_pilot()

/mob/living/simple_animal/remote_control/attack_hand(mob/user)
	. = ..()
	if(ishuman(user) && user.a_intent == INTENT_GRAB)
		if(user.get_active_held_item())
			to_chat(user, "<span class='warning'>Your hands are full!</span")
			return
		visible_message("<span class='warning'>[user] starts to wrap [src].</span>")
		if(!do_after(user, 20, target = src))
			return
		if(buckled)
			to_chat(user, "<span class='warning'>[src] is buckled to [buckled] and you cannot wrap it up!</span>")
			return
		to_chat(user, "<span class='notice'>You wrapped [src] up.</span>")
		visible_message("<span class='warning'>[user] wrapped [src]!</span>")
		drop_all_held_items()
		wrapped = TRUE
		var/obj/item/remote_control_bot/HA = new(get_turf(src), src)
		user.put_in_hands(HA)

//Action button to exit
/datum/action/innate/eject_rc
	name = "Disconnect"
	button_icon_state = "mech_eject"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'

/datum/action/innate/eject_rc/Activate()
	var/mob/living/simple_animal/remote_control/F = owner
	to_chat(src, "<span class='notice'>You cease piloting [src].</span>")
	F.eject_pilot()
