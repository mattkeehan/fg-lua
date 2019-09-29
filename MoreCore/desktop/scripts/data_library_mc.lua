-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--


function onInit()
LibraryData.setRecordTypeInfo("cas", {
	bExport = true,
	bID = true,
	sDisplayText = "library_recordtype_label_rolls",
	aDataMap = { "cas", "reference.cas" },
	aDisplayIcon = { "button_cas", "button_cas_down" },
	fToggleIndex = toggleCharRecordIndex,
	sRecordDisplayClass = "cas",
});



LibraryData.setRecordTypeInfo("ability", {
	bExport = true,
	bID = true,
	sDisplayText = "library_recordtype_label_ability",
	aDataMap = { "ability", "reference.ability" },
	aDisplayIcon = { "button_mcability", "button_mcability_down" },
	fToggleIndex = toggleCharRecordIndex,
	sRecordDisplayClass = "ability",
});

LibraryData.setRecordTypeInfo("mc_locations", {
	bExport = true,
	bID = true,
	sDisplayText = "library_recordtype_label_mc_locations",
	aDataMap = { "mc_locations", "reference.mc_locations" },
	aDisplayIcon = { "button_mc_locations", "button_mc_locations_down" },
	fToggleIndex = toggleCharRecordIndex,
	sRecordDisplayClass = "mc_locations",
});

LibraryData.setRecordTypeInfo("mc_organisations", {
	bExport = true,
	bID = true,
	sDisplayText = "library_recordtype_label_mc_organisations",
	aDataMap = { "mc_organisations", "reference.mc_organisations" },
	aDisplayIcon = { "button_mc_organisations", "button_mc_organisations_down" },
	fToggleIndex = toggleCharRecordIndex,
	sRecordDisplayClass = "mc_organisations",
});






end


function unusedDatatypes()
-- not a real function

LibraryData.setRecordTypeInfo("trackers", {
sDisplayText = "library_recordtype_label_trackers",
aDataMap = { "trackers", "reference.trackers" },
aDisplayIcon = { "button_trackers", "button_trackers_down" },
fToggleIndex = toggleCharRecordIndex,
sRecordDisplayClass = "trackers",
});

-- not a real function
LibraryData.setRecordTypeInfo("spells", {
sDisplayText = "library_recordtype_label_spells",
aDataMap = { "spells", "reference.spells" },
aDisplayIcon = { "button_spells", "button_spells_down" },
fToggleIndex = toggleCharRecordIndex,
sRecordDisplayClass = "spells",
});

end

function buildDesktop()
	-- Local mode
	if User.isLocal() then
		DesktopManager.registerStackShortcut2("button_color", "button_color_down", "sidebar_tooltip_colors", "pointerselection");

		DesktopManager.registerDockShortcut2("button_characters", "button_characters_down", "sidebar_tooltip_character", "charselect_client");
		DesktopManager.registerDockShortcut2("button_library", "button_library_down", "sidebar_tooltip_library", "library");

	-- GM mode
	elseif User.isHost() then
		DesktopManager.registerStackShortcut2("button_ct", "button_ct_down", "sidebar_tooltip_ct", "combattracker_host", "combattracker");
		DesktopManager.registerStackShortcut2("button_partysheet", "button_partysheet_down", "sidebar_tooltip_ps", "partysheet_host", "partysheet");

		DesktopManager.registerStackShortcut2("button_calendar", "button_calendar_down", "sidebar_tooltip_calendar", "calendar", "calendar");
		DesktopManager.registerStackShortcut2("button_color", "button_color_down", "sidebar_tooltip_colors", "pointerselection");

		DesktopManager.registerStackShortcut2("button_light", "button_light_down", "sidebar_tooltip_lighting", "lightingselection");
		DesktopManager.registerStackShortcut2("button_options", "button_options_down", "sidebar_tooltip_options", "options");

		DesktopManager.registerStackShortcut2("button_modifiers", "button_modifiers_down", "sidebar_tooltip_modifiers", "modifiers", "modifiers");
		DesktopManager.registerStackShortcut2("button_effects", "button_effects_down", "sidebar_tooltip_effects", "effectlist", "effects");

		DesktopManager.registerDockShortcut2("button_characters", "button_characters_down", "sidebar_tooltip_character", "charselect_host", "charsheet");
		DesktopManager.registerDockShortcut2("button_book", "button_book_down", "sidebar_tooltip_story", "encounterlist", "encounter");
		DesktopManager.registerDockShortcut2("button_maps", "button_maps_down", "sidebar_tooltip_image", "imagelist", "image");
		DesktopManager.registerDockShortcut2("button_people", "button_people_down", "sidebar_tooltip_npc", "npclist", "npc");
		DesktopManager.registerDockShortcut2("button_items", "button_items_down", "sidebar_tooltip_item", "itemlist", "item");
		DesktopManager.registerDockShortcut2("button_notes", "button_notes_down", "sidebar_tooltip_note", "notelist", "notes");
		DesktopManager.registerDockShortcut2("button_cas", "button_cas_down", "sidebar_tooltip_cas", "caslist", "cas");
		DesktopManager.registerDockShortcut2("button_spells", "button_spells_down", "sidebar_tooltip_spells", "spellslist", "spells");
		DesktopManager.registerDockShortcut2("button_mcability", "button_mcability_down", "sidebar_tooltip_ability", "abilitylist", "ability");
		DesktopManager.registerDockShortcut2("button_mc_locations", "button_mc_locations_down", "sidebar_tooltip_mc_locations", "mc_locationslist", "mc_locations");
		DesktopManager.registerDockShortcut2("button_mc_organisations", "button_mc_organisations_down", "sidebar_tooltip_mc_organisations", "mc_organisationslist", "mc_organisations");
		DesktopManager.registerDockShortcut2("button_library", "button_library_down", "sidebar_tooltip_library", "library");

		DesktopManager.registerDockShortcut2("button_tokencase", "button_tokencase_down", "sidebar_tooltip_token", "tokenbag", nil, true);

	-- Player mode
	else
		DesktopManager.registerStackShortcut2("button_ct", "button_ct_down", "sidebar_tooltip_ct", "combattracker_host", "combattracker");
		DesktopManager.registerStackShortcut2("button_partysheet", "button_partysheet_down", "sidebar_tooltip_ps", "partysheet_host", "partysheet");

		DesktopManager.registerStackShortcut2("button_calendar", "button_calendar_down", "sidebar_tooltip_calendar", "calendar", "calendar");
		DesktopManager.registerStackShortcut2("button_color", "button_color_down", "sidebar_tooltip_colors", "pointerselection");

		DesktopManager.registerStackShortcut2("button_light", "button_light_down", "sidebar_tooltip_lighting", "lightingselection");
		DesktopManager.registerStackShortcut2("button_options", "button_options_down", "sidebar_tooltip_options", "options");

		DesktopManager.registerStackShortcut2("button_modifiers", "button_modifiers_down", "sidebar_tooltip_modifiers", "modifiers", "modifiers");
		DesktopManager.registerStackShortcut2("button_effects", "button_effects_down", "sidebar_tooltip_effects", "effectlist", "effects");

		DesktopManager.registerDockShortcut2("button_characters", "button_characters_down", "sidebar_tooltip_character", "charselect_client");
		DesktopManager.registerDockShortcut2("button_book", "button_book_down", "sidebar_tooltip_story", "encounterlist", "encounter");
		DesktopManager.registerDockShortcut2("button_maps", "button_maps_down", "sidebar_tooltip_image", "imagelist", "image");
		DesktopManager.registerDockShortcut2("button_people", "button_people_down", "sidebar_tooltip_npc", "npclist", "npc");
		DesktopManager.registerDockShortcut2("button_items", "button_items_down", "sidebar_tooltip_item", "itemlist", "item");
		DesktopManager.registerDockShortcut2("button_notes", "button_notes_down", "sidebar_tooltip_note", "notelist", "notes");
		DesktopManager.registerDockShortcut2("button_library", "button_library_down", "sidebar_tooltip_library", "library");
		DesktopManager.registerDockShortcut2("button_cas", "button_cas_down", "sidebar_tooltip_cas", "caslist", "cas");
		DesktopManager.registerDockShortcut2("button_spells", "button_spells_down", "sidebar_tooltip_spells", "spellslist", "spells");
		DesktopManager.registerDockShortcut2("button_mcability", "button_mcability_down", "sidebar_tooltip_ability", "abilitylist", "ability");
		DesktopManager.registerDockShortcut2("button_mc_locations", "button_mc_locations_down", "sidebar_tooltip_mc_locations", "mc_locationslist", "mc_locations");

		DesktopManager.registerDockShortcut2("button_tokencase", "button_tokencase_down", "sidebar_tooltip_token", "tokenbag", nil, true);
	end
end

