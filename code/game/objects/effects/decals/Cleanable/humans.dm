#define DRYING_TIME 5 * 60 * 10 //for 1 unit of depth in puddle (amount var)

GLOBAL_LIST_EMPTY(splatter_cache)

/obj/effect/decal/cleanable/blood
	name = "blood"
	var/dryname = "dried blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	var/drydesc = "It's dry and crusty. Someone is not doing their job."
	gender = PLURAL
	density = FALSE
	layer = TURF_LAYER
	plane = GAME_PLANE
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	blood_DNA = list()
	var/base_icon = 'icons/effects/blood.dmi'
	var/blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	var/basecolor = "#A10808" // Color when wet.
	var/amount = 5
	var/dry_timer = 0
	var/off_floor = FALSE


/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	if(C.blood_DNA)
		blood_DNA |= C.blood_DNA.Copy()
	if(bloodiness)
		if(C.bloodiness < MAX_SHOE_BLOODINESS)
			C.bloodiness += bloodiness
	return ..()


/obj/effect/decal/cleanable/blood/Initialize(mapload)
	. = ..()
	update_icon()
	if(type == /obj/effect/decal/cleanable/blood/gibs)
		return
	if(!.)
		dry_timer = addtimer(CALLBACK(src, .proc/dry), DRYING_TIME * (amount+1), TIMER_STOPPABLE)

/obj/effect/decal/cleanable/blood/Destroy()
	if(dry_timer)
		deltimer(dry_timer)
	return ..()

/obj/effect/decal/cleanable/blood/update_icon()
	if(basecolor == "rainbow")
		basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	color = basecolor
	..()

/obj/effect/decal/cleanable/blood/proc/dry()
	name = dryname
	desc = drydesc
	color = adjust_brightness(color, -50)
	amount = 0

/obj/effect/decal/cleanable/blood/attack_hand(mob/living/carbon/human/user)
	..()
	if(amount && istype(user))
		add_fingerprint(user)
		if(user.gloves)
			return
		var/taken = rand(1,amount)
		amount -= taken
		to_chat(user, "<span class='notice'>You get some of \the [src] on your hands.</span>")
		if(!user.blood_DNA)
			user.blood_DNA = list()
		user.blood_DNA |= blood_DNA.Copy()
		user.bloody_hands += taken
		user.hand_blood_color = basecolor
		user.update_inv_gloves()
		user.verbs += /mob/living/carbon/human/proc/bloody_doodle

/obj/effect/decal/cleanable/blood/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "A drop of blood in an ocean of mess."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1", "2", "3", "4", "5")
	amount = 0
	bloodiness = 0
	var/drips = 1

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose
	name = "blood"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	desc = "Your instincts say you shouldn't be following these."
	gender = PLURAL
	density = FALSE
	layer = TURF_LAYER
	random_icon_states = null
	blood_DNA = list()
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/writing
	icon_state = "tracks"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1", "writing2", "writing3", "writing4", "writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/Initialize(mapload)
	. = ..()
	if(random_icon_states.len)
		for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/effect/decal/cleanable/blood/writing/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It reads: <font color='[basecolor]'>\"[message]\"<font></span>"

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = FALSE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	no_clear = TRUE
	mergeable_decal = FALSE
	var/image/giblets
	var/fleshcolor = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/Destroy()
	giblets = null
	return ..()

/obj/effect/decal/cleanable/blood/gibs/update_icon(updates = ALL)
	if(!updates)
		return
	giblets = new(base_icon, "[icon_state]_flesh", dir)
	if(!fleshcolor || fleshcolor == "rainbow")
		fleshcolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	giblets.color = fleshcolor
	var/icon/blood = new(base_icon,"[icon_state]",dir)
	icon = blood
	. = ..()

/obj/effect/decal/cleanable/blood/gibs/update_overlays()
	. = ..()
	. += giblets

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity)
	return

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gibup1", "gibup1", "gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gibdown1", "gibdown1", "gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")
	scoop_reagents = list("liquidgibs" = 5)


/obj/effect/decal/cleanable/blood/gibs/cleangibs //most ironic name ever...
	scoop_reagents = null

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions)
	set waitfor = 0
	var/direction = pick(directions)
	for(var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
		sleep(3)
		if(i > 0)
			var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(loc)
			b.basecolor = src.basecolor
			b.update_icon()
		if(step_to(src, get_step(src, direction), 0))
			break


/obj/effect/decal/cleanable/blood/old/Initialize(mapload)
	. = ..()
	bloodiness = 0
	dry()

/obj/effect/decal/cleanable/blood/old/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload)
	. = ..()
	bloodiness = 0
	dry()

/obj/effect/decal/cleanable/blood/gibs/old/can_bloodcrawl_in()
	return FALSE

#undef DRYING_TIME
