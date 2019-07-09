/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "egloves"

/obj/item/clothing/gloves/cyborg
	desc = "Beep boop borp!"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	siemens_coefficient = 1.0

/obj/item/clothing/gloves/insulated
	desc = "These gloves will protect the wearer from electric shocks."
	name = "insulated gloves"
	color = COLOR_YELLOW
	icon_state = "white"
	item_state = "lgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/gloves/insulated/cheap                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()

/obj/item/clothing/gloves/insulated/cheap/New()
	..()
	//average of 0.4, better than regular gloves' 0.75
	siemens_coefficient = pick(0, 0.1, 0.2, 0.3, 0.4, 0.6, 1.3)

/obj/item/clothing/gloves/forensic
	desc = "Specially made gloves for forensic technicians. The luminescent threads woven into the material stand out under scrutiny."
	name = "forensic gloves"
	icon_state = "forensic"
	item_state = "bgloves"
	siemens_coefficient = 0.50
	permeability_coefficient = 0.05

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/thick
	desc = "These work gloves are thick and fire-resistant."
	name = "work gloves"
	icon_state = "black"
	item_state = "bgloves"
	siemens_coefficient = 0.50
	permeability_coefficient = 0.05
	item_flags = ITEM_FLAG_THICKMATERIAL

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/thick/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/thick/swat
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	name = "\improper SWAT Gloves"
	item_state = "swat_gl"
	force = 5
	armor  = list(
		DAM_BLUNT 	= 80,
		DAM_PIERCE 	= 70,
		DAM_CUT 	= 80,
		DAM_BULLET 	= 60,
		DAM_LASER 	= 60,
		DAM_ENERGY 	= 25,
		DAM_BURN 	= 25,
		DAM_BOMB 	= 50,
		DAM_EMP 	= 0,
		DAM_BIO 	= 10,
		DAM_RADS 	= 0,
		DAM_STUN 	= 0)

/obj/item/clothing/gloves/thick/combat //Combined effect of SWAT gloves and insulated gloves
	desc = "These tactical gloves are somewhat fire and impact resistant."
	name = "combat gloves"
	icon_state = "work"
	item_state = "wgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	force = 5
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	armor  = list(
		DAM_BLUNT 	= 80,
		DAM_PIERCE 	= 70,
		DAM_CUT 	= 80,
		DAM_BULLET 	= 60,
		DAM_LASER 	= 60,
		DAM_ENERGY 	= 25,
		DAM_BURN 	= 25,
		DAM_BOMB 	= 50,
		DAM_EMP 	= 0,
		DAM_BIO 	= 10,
		DAM_RADS 	= 0,
		DAM_STUN 	= 0)

/obj/item/clothing/gloves/thick/blueguard
	desc = "A pair of synthweave-ablative gloves. Durable and resistant."
	name = "\improper guard gloves"
	icon_state = "bggloves"
	item_state = "bluegloves"
	force = 5
	armor  = list(
		DAM_BLUNT 	= 80,
		DAM_PIERCE 	= 70,
		DAM_CUT 	= 80,
		DAM_BULLET 	= 30,
		DAM_LASER 	= 50,
		DAM_ENERGY 	= 30,
		DAM_BURN 	= 30,
		DAM_BOMB 	= 0,
		DAM_EMP 	= 0,
		DAM_BIO 	= 10,
		DAM_RADS 	= 0,
		DAM_STUN 	= 0)
	matter = list(MATERIAL_LEATHER = 0.5 SHEETS, MATERIAL_PLASTEEL = 0.5 SHEETS)

/obj/item/clothing/gloves/thick/botany
	desc = "These leather work gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "thick leather gloves"
	icon_state = "leather"
	item_state = "ggloves"
	matter = list(MATERIAL_LEATHER = 2000)

/obj/item/clothing/gloves/thick/botany/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 1.1 //thin latex gloves, much more conductive than fabric gloves (basically a capacitor for AC)
	permeability_coefficient = 0.03
	germ_level = 0
	matter = list(MATERIAL_LEATHER = 2000)

/obj/item/clothing/gloves/latex/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/latex/nitrile
	name = "nitrile gloves"
	desc = "Sterile nitrile gloves"
	icon_state = "nitrile"
	item_state = "ngloves"
	permeability_coefficient = 0.005

/obj/item/clothing/gloves/latex/nitrile/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/thick/duty
	desc = "These brown duty gloves are made from a durable synthetic."
	name = "work gloves"
	icon_state = "work"
	item_state = "wgloves"
	siemens_coefficient = 0.50
	armor  = list(
		DAM_BLUNT 	= 10,
		DAM_PIERCE 	= 5,
		DAM_CUT 	= 10,
		DAM_BULLET 	= 10,
		DAM_LASER 	= 10,
		DAM_ENERGY 	= 5,
		DAM_BURN 	= 10,
		DAM_BOMB 	= 0,
		DAM_EMP 	= 0,
		DAM_BIO 	= 0,
		DAM_RADS 	= 0,
		DAM_STUN 	= 0)

/obj/item/clothing/gloves/thick/duty/modified
	item_flags = ITEM_FLAG_PREMODIFIED

/obj/item/clothing/gloves/tactical
	desc = "These brown tactical gloves are made from a durable synthetic, and have hardened knuckles."
	name = "tactical gloves"
	icon_state = "work"
	item_state = "wgloves"
	force = 5
	siemens_coefficient = 0.50
	permeability_coefficient = 0.05
	armor  = list(
		DAM_BLUNT 	= 30,
		DAM_PIERCE 	= 20,
		DAM_CUT 	= 30,
		DAM_BULLET 	= 10,
		DAM_LASER 	= 10,
		DAM_ENERGY 	= 15,
		DAM_BURN 	= 10,
		DAM_BOMB 	= 20,
		DAM_EMP 	= 0,
		DAM_BIO 	= 0,
		DAM_RADS 	= 0,
		DAM_STUN 	= 0)

/obj/item/clothing/gloves/guards
	desc = "A pair of synthetic gloves and arm pads reinforced with armor plating."
	name = "arm guards"
	icon_state = "guards"
	item_state = "guards"
	body_parts_covered = HANDS|ARMS
	w_class = ITEM_SIZE_NORMAL
	siemens_coefficient = 0.7
	permeability_coefficient = 0.03
	armor  = list(
		DAM_BLUNT 	= 40,
		DAM_PIERCE 	= 30,
		DAM_CUT 	= 40,
		DAM_BULLET 	= 40,
		DAM_LASER 	= 40,
		DAM_ENERGY 	= 25,
		DAM_BURN 	= 40,
		DAM_BOMB 	= 30,
		DAM_EMP 	= 0,
		DAM_BIO 	= 0,
		DAM_RADS 	= 0,
		DAM_STUN 	= 0)
