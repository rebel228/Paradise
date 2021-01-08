/*
VOX HEIST ROUNDTYPE
*/
GLOBAL_LIST_EMPTY(raider_spawn)

/datum/game_mode/
	var/list/datum/mind/raiders = list()  //Antags.
	var/list/raid_objectives = list()     //Raid objectives

/datum/game_mode/heist/announce()
	to_chat(world, "<B>The current game mode is - Heist!</B>")
	to_chat(world, "<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>")
	to_chat(world, "Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!")
	to_chat(world, "<B>Raiders:</B> Loot [station_name()] for anything and everything you need, or choose the peaceful route and attempt to trade with them.")
	to_chat(world, "<B>Personnel:</B> Trade with the raiders, or repel them and their low, low prices and/or crossbows.")

/datum/game_mode/proc/is_raider_crew_alive()
	for(var/datum/mind/raider in raiders)
		if(raider.current)
			if(istype(raider.current, /mob/living/carbon/human) && raider.current.stat != DEAD)
				return TRUE
	return FALSE

/datum/game_mode/proc/forge_vox_objectives()
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

	return objs

/datum/game_mode/proc/greet_vox(var/datum/mind/raider)
	to_chat(raider.current, "<span class='boldnotice'>You are a Vox Raider, fresh from the Shoal!</span>")
	to_chat(raider.current, "<span class='notice'>The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to the frontier and much of the unexplored galaxy. You and the crew have come to the [station_name()] for plunder, trade or both.</span>")
	to_chat(raider.current, "<span class='notice'>Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.</span>")
	to_chat(raider.current, "<span class='notice'>Use :V to voxtalk, :H to talk on your encrypted channel, and don't forget to turn on your nitrogen internals!</span>")
	to_chat(raider.current, "<span class='notice'>Choose to accomplish your objectives by either raiding the crew and taking what you need, or by attempting to trade with them.</span>")
	spawn(25)
		show_objectives(raider)

/datum/game_mode/proc/auto_declare_completion_heist()
	if(raiders.len)
		to_chat(world, "<span class='warning'><FONT size = 3><B>The station was visited by Vox Raiders!</B></FONT></span>")

		var/end_msg = ""
		var/count = 1
		for(var/datum/objective/objective in raid_objectives)
			if(objective.check_completion())
				to_chat(world, "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>")
				feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
			else
				to_chat(world, "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>")
				feedback_add_details("traitor_objective","[objective.type]|FAIL")
			count++

		if(!is_raider_crew_alive())
			end_msg += "<B>The Vox Raiders have been wiped out!</B>"
		if(end_msg)
			to_chat(world, "[end_msg]")

		var/text = "<FONT size = 2><B>The Vox raiders were:</B></FONT>"
		for(var/datum/mind/vox in raiders)
			text += "<br>[vox.key] was [vox.name] ("
			if(vox.current)
				if(vox.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(vox.current.real_name != vox.name)
					text += " as [vox.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		to_chat(world, text)

	return 1

/obj/machinery/vox_win_button
	name = "shoal contact computer"
	desc = "Used to contact the Vox Shoal, generally to arrange for pickup."
	icon = 'icons/obj/computer.dmi'
	icon_state = "tcstation"

/obj/machinery/vox_win_button/New()
	. = ..()
	overlays += icon('icons/obj/computer.dmi', "syndie")
