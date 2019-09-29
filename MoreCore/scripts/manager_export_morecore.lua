-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

aExport = {};

function onInit()
	if User.isHost() then
		-- Register Standard Camapign Nodes for /export
		ExportManager.registerExportNode({ name = "cas", class = "cas", label = "MoreCore Rolls"});
		ExportManager.registerExportNode({ name = "ability", class = "ability", label = "MoreCore Abilities"});
		ExportManager.registerExportNode({ name = "spells", class = "spells", label = "MoreCore Spells"});
		ExportManager.registerExportNode({ name = "mc_locations", class = "mc_locations", label = "MoreCore Locations"});
		ExportManager.registerExportNode({ name = "mc_organisations", class = "mc_organisations", label = "MoreCore Organisations"});
		ExportManager.registerExportNode({ name = "pcclass", class = "pcclass", label = "MoreCore Classes"});
--		registerExportNode({ name = "charsheet", class = "pregencharselect", label = "Pregen Characters"});
	end
end
