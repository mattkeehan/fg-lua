-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()

-- options for changing Column heading Colour in Combat Tracker --
-- Option Variable Name: CTCHC
-- Under What Heading: option_header_combattracker (string - translation found in /strings/morecore_strings.xml)
-- Option Name: option_label_CTCHC (string - translation found in /strings/morecore_strings.xml)
-- Option Control Type: option_entry_cycler (cycler)
-- Options Text: option_val_white|option_val_black (strings - translations found in /strings/morecore_strings.xml, separated by | )
-- DB Values: stringw|Black
-- Default Selection: option_val_white (strings - translations found in /strings/morecore_strings.xml, separated by | )
-- Default DB Value: stringw (strings - translations found in /strings/morecore_strings.xml, separated by | , references the template stringw in the ct_host.xml and ct_client.xml files)
-- Default DB Value: stringw (strings - translations found in /strings/morecore_strings.xml, separated by | )
	OptionsManager.registerOption2("CTCHC", false, "option_header_combattracker", "option_label_CTCHC", "option_entry_cycler", 
			{ labels = "option_val_white|option_val_black", values = "#FFFFFFFF|#FF000000", baselabel = "option_val_white", baseval = "#FFFFFFFF", default = "#FFFFFFFF" });

-- options for show/hide Column 1 (which is linked to Health on NPC/Char sheets --
	OptionsManager.registerOption2("MCC1", false, "option_header_combattracker", "option_label_MCC1", "option_entry_cycler", 
			{ labels = "option_val_MCC_off|option_val_MCC_gm|option_val_MCC_both", values = "Off|GM|Both", baselabel = "option_val_MCC_gm", baseval = "GM", default = "GM" });

-- options for changing Column 1 Colour in Combat Tracker --
	OptionsManager.registerOption2("MCC1C", false, "option_header_combattracker", "option_label_MCC1C", "option_entry_cycler", 
			{ labels = "option_val_black|option_val_red|option_val_green|option_val_blue", values = "FF000000|#FF990000|#FF006600|#ff003366", baselabel = "option_val_black", baseval = "#FF000000", default = "#FF000000" });

			-- options for show/hide Column 2 (which is linked to Defence on NPC/Char sheets --
	OptionsManager.registerOption2("MCC2", false, "option_header_combattracker", "option_label_MCC2", "option_entry_cycler", 
			{ labels = "option_val_MCC_off|option_val_MCC_gm|option_val_MCC_both", values = "Off|GM|Both", baselabel = "option_val_MCC_gm", baseval = "GM", default = "GM" });

-- options for changing Column 2 Colour in Combat Tracker --
	OptionsManager.registerOption2("MCC2C", false, "option_header_combattracker", "option_label_MCC2C", "option_entry_cycler", 
			{ labels = "option_val_black|option_val_red|option_val_green|option_val_blue", values = "FF000000|#FF990000|#FF006600|#ff003366", baselabel = "option_val_black", baseval = "#FF000000", default = "#FF000000" });

			-- options for show/hide Column 3 --
	OptionsManager.registerOption2("MCC3", false, "option_header_combattracker", "option_label_MCC3", "option_entry_cycler", 
			{ labels = "option_val_MCC_off|option_val_MCC_gm|option_val_MCC_both", values = "Off|GM|Both", baselabel = "option_val_MCC_both", baseval = "Both", default = "Both" });

			-- options for Auto SUM Column 3 (generally if used for Wounds tracking) --
	OptionsManager.registerOption2("MCC3SUM", false, "option_header_combattracker", "option_label_MCC3SUM", "option_entry_cycler", 
			{ labels = "option_val_MCCSUM_on|option_val_MCCSUM_off", values = "On|Off", baselabel = "option_val_MCCSUM_on", baseval = "On", default = "On" });
			
-- options for changing Column 3 Colour in Combat Tracker --
	OptionsManager.registerOption2("MCC3C", false, "option_header_combattracker", "option_label_MCC3C", "option_entry_cycler", 
			{ labels = "option_val_black|option_val_red|option_val_green|option_val_blue", values = "FF000000|#FF990000|#FF006600|#ff003366", baselabel = "option_val_black", baseval = "#FF000000", default = "#FF000000" });

			-- options for show/hide Column 4 --
	OptionsManager.registerOption2("MCC4", false, "option_header_combattracker", "option_label_MCC4", "option_entry_cycler", 
			{ labels = "option_val_MCC_off|option_val_MCC_gm|option_val_MCC_both", values = "Off|GM|Both", baselabel = "option_val_off", baseval = "Off", default = "Off" });

-- options for changing Column 4 Colour in Combat Tracker --
	OptionsManager.registerOption2("MCC4C", false, "option_header_combattracker", "option_label_MCC4C", "option_entry_cycler", 
			{ labels = "option_val_black|option_val_red|option_val_green|option_val_blue", values = "FF000000|#FF990000|#FF006600|#ff003366", baselabel = "option_val_black", baseval = "#FF000000", default = "#FF000000" });

			-- options for show/hide Column 5 --
	OptionsManager.registerOption2("MCC5", false, "option_header_combattracker", "option_label_MCC5", "option_entry_cycler", 
			{ labels = "option_val_MCC_off|option_val_MCC_gm|option_val_MCC_both", values = "Off|GM|Both", baselabel = "option_val_off", baseval = "Off", default = "Off" });

-- options for changing Column 5 Colour in Combat Tracker --
	OptionsManager.registerOption2("MCC5C", false, "option_header_combattracker", "option_label_MCC5C", "option_entry_cycler", 
			{ labels = "option_val_black|option_val_red|option_val_green|option_val_blue", values = "FF000000|#FF990000|#FF006600|#ff003366", baselabel = "option_val_black", baseval = "#FF000000", default = "#FF000000" });

-- options for Tracking Actions without Initiative for Story Telling games in Combat Tracker --
	OptionsManager.registerOption2("MCTurns", false, "option_header_combattracker", "option_label_MCTurns", "option_entry_cycler", 
			{ labels = "option_val_MCC_off|option_val_MCC_gm|option_val_MCC_both", values = "Off|GM|Both", baselabel = "option_val_off", baseval = "Off", default = "Off" });

-- options for Disabling Auto Initiative in Combat Tracker --
	OptionsManager.registerOption2("MCInit", false, "option_header_combattracker", "option_label_MCInit", "option_entry_cycler", 
			{ labels = "option_val_MCC_off|option_val_MCC_both", values = "Off|Both", baselabel = "option_val_MCC_both", baseval = "GM and Player", default = "GM and Player" });

-- options for Init Dice Size in Combat Tracker --
	OptionsManager.registerOption2("MCInitDice", false, "option_header_combattracker", "option_label_MCInitDice", "option_entry_cycler", 
			{ labels = "option_val_MCC_d100|option_val_MCC_d20|option_val_MCC_d12|option_val_MCC_2d10|option_val_MCC_d10|option_val_MCC_d8|option_val_MCC_d6|option_val_MCC_d4|option_val_MCC_d0", values = "100|20|12|2d10|10|8|6|4|0", baselabel = "option_val_MCC_d10", baseval = "10", default = "10" });

-- options for PC Init Reroll in Combat Tracker --
	OptionsManager.registerOption2("MCRerollPCInitDice", false, "option_header_combattracker", "option_label_MCRerollPCInitDice", "option_entry_cycler", 
			{ labels = "option_val_MCC_rerollPC|option_val_MCC_rerollNPC", values = "Reroll|Reset", baselabel = "option_val_MCC_rerollPC", baseval = "Reroll", default = "Reroll" });

			OptionsManager.addOptionValue("DDCL", "option_val_DDCL_morecore", "desktopdecal_morecore", true);
	OptionsManager.setOptionDefault("DDCL", "desktopdecal_morecore");

			
end
