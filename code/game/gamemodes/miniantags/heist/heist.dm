/*
VOX HEIST ROUNDTYPE
*/
GLOBAL_LIST_EMPTY(raider_spawn)

/datum/game_mode/
	var/list/datum/mind/raiders = list()  //Antags.
	var/list/raid_objectives = list()     //Raid objectives

/datum/game_mode/proc/is_raider_crew_alive()
	for(var/datum/mind/raider in raiders)
		if(raider.current)
			if(istype(raider.current, /mob/living/carbon/human) && raider.current.stat != DEAD)
				return TRUE
	return FALSE

/datum/game_mode/proc/auto_declare_completion_heist()
	if(length(raiders))
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
