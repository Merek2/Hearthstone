#define TENTACLE_PATCH 1
#define SPAWN_CHILDREN 2
#define RAGE 3
#define CALL_CHILDREN 4

/**
  * # Goliath Broodmother
  *
  * A stronger, faster variation of the goliath.  Has the ability to spawn baby goliaths, which it can later detonate at will.
  * When it's health is below half, tendrils will spawn randomly around it.  When it is below a quarter of health, this effect is doubled.
  * It's attacks are as follows:
  * - Spawns a 3x3/plus shape of tentacles on the target location
  * - Spawns 2 baby goliaths on its tile, up to a max of 8.  Children blow up when they die.
  * - The broodmother lets out a noise, and is able to move faster for 6.5 seconds.
  * - Summons your children around you.
  * The broodmother is a fight revolving around stage control, as the activator has to manage the baby goliaths and the broodmother herself, along with all the tendrils.
  */

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother
	name = "birthgiver"
	desc = ""
	gender = FEMALE
	icon_state = "broodmother"
	icon_living = "broodmother"
	icon_aggro = "broodmother"
	icon_dead = "egg_sac"
	icon_gib = "syndicate_gib"
	melee_damage_lower = 30
	melee_damage_upper = 30
	armor_penetration = 30
	attack_verb_continuous = "beats down on"
	attack_verb_simple = "beat down on"
	attack_sound = 'sound/blank.ogg'
	throw_message = "does nothing to the rocky hide of the"
	speed = 2
	mouse_opacity = MOUSE_OPACITY_ICON
	deathmessage = "explodes into gore!"
	loot_drop = /obj/item/crusher_trophy/broodmother_tongue



	emote_hear = null
	emote_see = null
	speak_chance = 1
	turns_per_move = 2
	see_in_dark = 10
	move_to_delay = 5
	base_intents = list(/datum/intent/simple/drake)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2)
	faction = list("caves")
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	maxHealth = 800
	health = 800
	melee_damage_lower = 30
	melee_damage_upper = 30
	vision_range = 5
	aggro_vision_range = 8
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 100
	retreat_distance = 0
	minimum_distance = 0
	milkies = FALSE
	food_type = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/bodypart, /obj/item/organ)
	footstep_type = FOOTSTEP_MOB_HEAVY
	pooptype = null
	STACON = 19
	STASTR = 16
	STASPD = 5
	deaggroprob = 0
	defprob = 40
	defdrain = 10
	retreat_health = 0
	food = 0
	dodgetime = 0
	aggressive = 1
//	stat_attack = UNCONSCIOUS

	attack_action_types = list(/datum/action/innate/elite_attack/tentacle_patch,
								/datum/action/innate/elite_attack/spawn_children,
								/datum/action/innate/elite_attack/rage,
								/datum/action/innate/elite_attack/call_children)

	var/rand_tent = 0
	var/list/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother_child/children_list = list()

/datum/action/innate/elite_attack/tentacle_patch
	name = "Tentacle Patch"
	button_icon_state = "tentacle_patch"
	chosen_message = span_boldwarning("I are now attacking with a patch of tentacles.")
	chosen_attack_num = TENTACLE_PATCH

/datum/action/innate/elite_attack/spawn_children
	name = "Spawn Children"
	button_icon_state = "spawn_children"
	chosen_message = span_boldwarning("I will spawn two children at your location to assist you in combat.  You can have up to 8.")
	chosen_attack_num = SPAWN_CHILDREN

/datum/action/innate/elite_attack/rage
	name = "Rage"
	button_icon_state = "rage"
	chosen_message = span_boldwarning("I will temporarily increase your movement speed.")
	chosen_attack_num = RAGE

/datum/action/innate/elite_attack/call_children
	name = "Call Children"
	button_icon_state = "call_children"
	chosen_message = span_boldwarning("I will summon your children to your location.")
	chosen_attack_num = CALL_CHILDREN

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother/OpenFire()
	if(client)
		switch(chosen_attack)
			if(TENTACLE_PATCH)
				tentacle_patch(target)
			if(SPAWN_CHILDREN)
				spawn_children()
			if(RAGE)
				rage()
			if(CALL_CHILDREN)
				call_children()
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(TENTACLE_PATCH)
			tentacle_patch(target)
		if(SPAWN_CHILDREN)
			spawn_children()
		if(RAGE)
			rage()
		if(CALL_CHILDREN)
			call_children()

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother/Life()
	. = ..()
	if(health < maxHealth * 0.5 && rand_tent < world.time)
		rand_tent = world.time + 30
		var/tentacle_amount = 5
		if(health < maxHealth * 0.25)
			tentacle_amount = 10
		var/tentacle_loc = spiral_range_turfs(5, get_turf(src))
		for(var/i in 1 to tentacle_amount)
			var/turf/t = pick_n_take(tentacle_loc)
			new /obj/effect/temp_visual/goliath_tentacle/broodmother(t, src)

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother/proc/tentacle_patch(target)
	ranged_cooldown = world.time + 15
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	visible_message(span_warning("[src] digs its tentacles under [target]!"))
	new /obj/effect/temp_visual/goliath_tentacle/broodmother/patch(tturf, src)

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother/proc/spawn_children(target)
	ranged_cooldown = world.time + 40
	visible_message(span_boldwarning("The ground churns behind [src]!"))
	for(var/i in 1 to 2)
		if(children_list.len >= 8)
			return
		var/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother_child/newchild = new /mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother_child(loc)
		newchild.GiveTarget(target)
		newchild.faction = faction.Copy()
		visible_message(span_boldwarning("[newchild] appears below [src]!"))
		newchild.mother = src
		children_list += newchild

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother/proc/rage()
	ranged_cooldown = world.time + 70
	playsound(src,'sound/blank.ogg', 200, 1)
	visible_message(span_warning("[src] starts picking up speed!"))
	color = "#FF0000"
	set_varspeed(0)
	move_to_delay = 3
	addtimer(CALLBACK(src, PROC_REF(reset_rage)), 65)

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother/proc/reset_rage()
	color = "#FFFFFF"
	set_varspeed(2)
	move_to_delay = 5

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother/proc/call_children()
	ranged_cooldown = world.time + 60
	visible_message(span_warning("The ground shakes near [src]!"))
	var/list/directions = GLOB.cardinals.Copy() + GLOB.diagonals.Copy()
	for(var/mob/child in children_list)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src, spawndir)
		if(T)
			child.forceMove(T)
			playsound(src, 'sound/blank.ogg', 100, 1)

//The goliath's children.  Pretty weak, simple mobs which are able to put a single tentacle under their target when at range.
/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother_child
	name = "newborn"
	desc = ""
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_baby"
	icon_living = "goliath_baby"
	icon_aggro = "goliath_baby"
	icon_dead = "goliath_baby_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 30
	health = 30
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "bashes against"
	attack_verb_simple = "bash against"
	attack_sound = 'sound/blank.ogg'
	throw_message = "does nothing to the rocky hide of the"
	speed = 2
	move_to_delay = 5
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list()
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	deathmessage = "falls to the ground."
	status_flags = CANPUSH
	var/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother/mother = null

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother_child/OpenFire(target)
	ranged_cooldown = world.time + 40
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so it can't attack people off-screen
		visible_message(span_warning("[src] digs one of its tentacles under [target]!"))
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(tturf, src)

/mob/living/simple_animal/hostile/retaliate/rogue/asteroid/elite/broodmother_child/death()
	. = ..()
	if(mother != null)
		mother.children_list -= src
	visible_message(span_warning("[src] explodes!"))
	explosion(get_turf(loc),0,0,0,flame_range = 3, adminlog = FALSE)
	gib()

//Tentacles have less stun time compared to regular variant, to balance being able to use them much more often.  Also, 10 more damage.
/obj/effect/temp_visual/goliath_tentacle/broodmother/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if((!QDELETED(spawner) && spawner.faction_check_mob(L)) || L.stat == DEAD)
			continue
		visible_message(span_danger("[src] grabs hold of [L]!"))
		L.Stun(10)
		L.adjustBruteLoss(rand(30,35))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), 10, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/broodmother/patch/Initialize(mapload, new_spawner)
	. = ..()
	var/tentacle_locs = spiral_range_turfs(1, get_turf(src))
	for(var/T in tentacle_locs)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(T, spawner)
	var/list/directions = GLOB.cardinals.Copy()
	for(var/i in directions)
		var/turf/T = get_step(get_turf(src), i)
		T = get_step(T, i)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(T, spawner)

// Broodmother's loot: Broodmother Tongue
/obj/item/crusher_trophy/broodmother_tongue
	name = "eldritch tongue"
	desc = ""
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "broodmother_tongue"
	denied_type = /obj/item/crusher_trophy/broodmother_tongue
	bonus_value = 10

/obj/item/crusher_trophy/broodmother_tongue/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a patch of goliath tentacles at the target's location"

/obj/item/crusher_trophy/broodmother_tongue/on_mark_detonation(mob/living/target, mob/living/user)
	if(rand(1, 100) <= bonus_value && target.stat != DEAD)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother/patch(get_turf(target), user)
