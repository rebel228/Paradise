#define RAIDERS_MAX_COUNT 4
#define RAIDERS_MIN_REQUIRED 1

// Vox Raiders event.

/datum/event/heist
	var/success_spawn = FALSE

/datum/event/heist/start()
	INVOKE_ASYNC(src, .proc/wrappedstart)

/datum/event/heist/proc/wrappedstart()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Vox Raider?", ROLE_RAIDER, TRUE)
	if(length(candidates) < RAIDERS_MIN_REQUIRED)
		message_admins("Warning: not enough players volunteered to be raiders. Could only find [length(candidates)] out of [RAIDERS_MIN_REQUIRED] required!")
		return
	SSticker.mode.raid_objectives = forge_vox_objectives()
	create_and_greet_raiders(candidates)

/datum/event/heist/proc/create_and_greet_raiders(candidates)
	var/raider_num
	raider_num = min(length(candidates), RAIDERS_MAX_COUNT)
	while(raider_num > 0)
		var/turf/picked_loc = GLOB.raider_spawn[raider_num]
		var/mob/C = pick_n_take(candidates)
		var/mob/living/carbon/human/vox/M = new /mob/living/carbon/human/vox(picked_loc)
		M.ckey = C.ckey
		M.set_species(/datum/species/vox)
		M.age = rand(12,20)
		M.s_tone = rand(1, 6)
		M.languages = list() // Removing language from chargen.
		M.flavor_text = null
		M.add_language("Vox-pidgin")
		M.add_language("Galactic Common")
		M.add_language("Tradeband")
		var/obj/item/organ/external/head/head_organ = M.get_organ("head")
		head_organ.h_style = "Short Vox Quills"
		head_organ.f_style = "Shaved"
		M.change_hair_color(97, 79, 25) //Same as the species default colour.
		M.change_eye_color(rand(1, 255), rand(1, 255), rand(1, 255))
		M.dna.ready_dna(M) // Won't be participating in the paralympics
		M.cleanSE() //No fat/blind/colourblind/epileptic/whatever.
		M.force_update_limbs()
		M.update_dna()
		M.update_eyes()
		M.equip_vox_raider()
		M.mind.objectives += SSticker.mode.raid_objectives
		M.mind.offstation_role = TRUE
		M.regenerate_icons()
		greet_raider(M)
		if(SSticker.mode.config_tag != "heist")
			SSticker.mode.raiders |= M.mind
		success_spawn = 1
		raider_num--

/datum/event/heist/proc/greet_raider(var/mob/living/carbon/human/M)
	to_chat(M, "<span class='boldnotice'>You are a Vox Raider, fresh from the Shoal!</span>")
	to_chat(M, "<span class='notice'>The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to the frontier and much of the unexplored galaxy. You and the crew have come to the [station_name()] for plunder, trade or both.</span>")
	to_chat(M, "<span class='notice'>Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.</span>")
	to_chat(M, "<span class='notice'>Use :V to voxtalk, :H to talk on your encrypted channel, and don't forget to turn on your nitrogen internals!</span>")
	to_chat(M, "<span class='notice'>Choose to accomplish your objectives by either raiding the crew and taking what you need, or by attempting to trade with them.</span>")
	spawn(25)
		show_objectives(M.mind)

/datum/event/heist/proc/forge_vox_objectives()
	var/i = 1
	var/max_objectives = pick(2,2,2,2,3,3,3,4)
	var/list/objs = list()
	var/list/goals = list("kidnap","loot","salvage")
	while(i<= max_objectives)
		var/goal = pick(goals)
		var/datum/objective/heist/O

		if(goal == "kidnap")
			goals -= "kidnap"
			O = new /datum/objective/heist/kidnap()
		else if(goal == "loot")
			O = new /datum/objective/heist/loot()
		else
			O = new /datum/objective/heist/salvage()
		O.choose_target()
		objs += O

		i++

	//-All- vox raids have these two objectives. Failing them loses the game.
	objs += new /datum/objective/heist/inviolate_death

	return objs

#undef RAIDERS_MAX_COUNT
#undef RAIDERS_MIN_REQUIRED
