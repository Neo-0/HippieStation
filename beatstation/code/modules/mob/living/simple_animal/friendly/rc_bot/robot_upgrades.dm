// the base of upgades for the rc bot
/obj/item/rc_upgrade
	name = "remote control robot upgrade"
	desc = "An upgrade for the remote controlled robot. This one does nothing."
	icon = 'beatstation/icons/obj/rc-bot/upgrades.dmi'
	icon_state = "base"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=200, MAT_GLASS=200)

/obj/item/rc_upgrade/mechanic_arms
	name = "mechanic arm upgrade"
	desc = "A mechanic arms upgrade for the remote control robot. Gives to your robot arms, so it can take itens."

/obj/item/rc_upgrade/range_upgrade
	name = "range upgrade"
	desc = "Gives to your rc bot more range. This one has a range of 15 tiles."

/obj/item/rc_upgrade/range_upgrade/adv
	name = "advanced range upgrade"
	desc = "Gives to your rc bot more range. This one has a range of 20 tiles."

/obj/item/rc_upgrade/speed_upgrade
	name = "speed upgrade"
	desc = "Gives to your rc bot more speed."
