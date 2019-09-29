-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- from CoreRPG 
-- Added setActiveVisible for Attack String
function onInit()
	-- Set the displays to what should be shown
	setTargetingVisible();
	setSpacingVisible();
	setEffectsVisible();
	setActiveVisible();
	setRollsVisible();

	-- Acquire token reference, if any
	linkToken();
	
	-- Set up the PC links
	onLinkChanged();
	
	-- Update the displays
	onFactionChanged();
	
	-- Register the deletion menu item for the host
	registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);


end
---
--- Additional Functions for More Core
-- Added toggleActive for Attack String
function toggleActive()
	if not enableglobaltoggle then
		return;
	end
	
	local activeon = window.button_global_active.getValue();
	for _,v in pairs(getWindows()) do
			v.activateactive.setValue(activeon);
	end
end
-- Added toggleRolls for Roll String
function toggleRolls()
	if not enableglobaltoggle then
		return;
	end
	
	local rollson = window.button_global_rolls.getValue();
	for _,v in pairs(getWindows()) do
			v.activateactive.setValue(rollson);
	end
end



-- from CoreRPG 
function onVisibilityToggle()
	local anyVisible = 0;
	for _,v in pairs(getWindows()) do
		if (v.friendfoe.getStringValue() ~= "friend") and (v.tokenvis.getValue() == 1) then
			anyVisible = 1;
		end
	end
	
	enablevisibilitytoggle = false;
	window.button_global_visibility.setValue(anyVisible);
	enablevisibilitytoggle = true;
end

--- End new Functions

-- from CoreRPG 
function updateDisplay()
	local sFaction = friendfoe.getStringValue();

	if DB.getValue(getDatabaseNode(), "active", 0) == 1 then
		name.setFont("sheetlabel");
		
		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
	else
		name.setFont("sheettext");
		
		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe");
		else
			setFrame("ctentrybox");
		end
	end
end

-- from CoreRPG 
function linkToken()
	local imageinstance = token.populateFromImageNode(tokenrefnode.getValue(), tokenrefid.getValue());
	if imageinstance then
		TokenManager.linkToken(getDatabaseNode(), imageinstance);
	end
end

-- from CoreRPG 
function onMenuSelection(selection, subselection)
	if selection == 6 and subselection == 7 then
		delete();
	end
end

-- from CoreRPG 
function delete()
	local node = getDatabaseNode();
	if not node then
		close();
		return;
	end
	
	-- Remember node name
	local sNode = node.getNodeName();
	
	-- Clear any effects and wounds first, so that saves aren't triggered when initiative advanced
	effects.reset(false);
	
	-- Move to the next actor, if this CT entry is active
	if DB.getValue(node, "active", 0) == 1 then
		CombatManager.nextActor();
	end

	-- Delete the database node and close the window
	node.delete();

	-- Update list information (global subsection toggles)
	windowlist.onVisibilityToggle();
	windowlist.onEntrySectionToggle();
end

-- from CoreRPG 
function onLinkChanged()
	-- If a PC, then set up the links to the char sheet
	local sClass, sRecord = link.getValue();
	if sClass == "charsheet" then
		linkPCFields();
		name.setLine(false);
	end
end

-- from CoreRPG 
function onFactionChanged()
	-- Update the entry frame
	updateDisplay();

	-- If not a friend, then show visibility toggle
	if friendfoe.getStringValue() == "friend" then
		tokenvis.setVisible(false);
	else
		tokenvis.setVisible(true);
	end
end

-- from CoreRPG 
function onVisibilityChanged()
	TokenManager.updateVisibility(getDatabaseNode());
	windowlist.onVisibilityToggle();
end

-- from CoreRPG 
-- added links for C1/Health, C2/Defence, Order/Order, Attack/Atk 
function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
--	Debug.console("linkPCFields:");
--	Debug.console(nodeChar);
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
		health.setLink(nodeChar.createChild("health", "number"), false);
		defence.setLink(nodeChar.createChild("defence", "number"), false);
		fieldthree.setLink(nodeChar.createChild("wounds", "number"), false);
		initresult.setLink(nodeChar.createChild("initresult", "number"));
		atk.setLink(nodeChar.createChild("attacks", "string"), true);
		fieldfour.setLink(nodeChar.createChild("four", "number"), false);
		fieldfive.setLink(nodeChar.createChild("five", "number"), false);
	end
end


--
-- SECTION VISIBILITY FUNCTIONS
--
-- Added setActiveVisible for Attack String
function setActiveVisible()
	local v = false;
	if activateactive.getValue() == 1 then
		v = true;
	end
	local sClass, sRecord = link.getValue();
	if sClass ~= "charsheet" and active.getValue() == 1 then
		v = true;
	end
	
	local bMonster;
	
	if sClass == "charsheet" then
		bMonster = false;
	else
		bMonster = (DB.getValue(getDatabaseNode(), "monster", "") ~= "false");
	end
	
	activeicon.setVisible(v);

--	initresult.setVisible(v);
--	init_label.setVisible(v);
--	move.setVisible(v and not bMonster);
--	monstermove.setVisible(v and bMonster);
--	move_label.setVisible(v);
--	bth.setVisible(v and not bMonster);
--	monsterbth.setVisible(v and bMonster);
--	bth_label.setVisible(v);
	atk.setVisible(v and not bMonster);
	monsteratk.setVisible(v and bMonster);
	atk_label.setVisible(v);
--	sa.setVisible(v);
--	sa_label.setVisible(v);
	
	frame_active.setVisible(v);
end

-- Added setRollsVisible for Rolls
function setRollsVisible()
	local v = false;
	if activaterolls.getValue() == 1 then
		v = true;
	end
	local sClass, sRecord = link.getValue();
	if sClass ~= "charsheet" and active.getValue() == 1 then
		v = true;
	end
	
	local bMonster;
	
	if sClass == "charsheet" then
		bMonster = false;
	else
		bMonster = (DB.getValue(getDatabaseNode(), "monster", "") ~= "false");
	end
	
--	activeicon.setVisible(v);

--	initresult.setVisible(v);
--	init_label.setVisible(v);
--	move.setVisible(v and not bMonster);
--	monstermove.setVisible(v and bMonster);
--	move_label.setVisible(v);
--	bth.setVisible(v and not bMonster);
--	monsterbth.setVisible(v and bMonster);
--	bth_label.setVisible(v);
--	rolls.setVisible(v and not bMonster);
--	rolls.setVisible(false);
	rollsicon.setVisible(false);
	rolls_label.setVisible(false);
	monsterrolls.setVisible(v and bMonster);
	rollsicon.setVisible(v and bMonster);
	rolls_label.setVisible(v and bMonster);
--	rolls_label.setVisible(v);
--	sa.setVisible(v);
--	sa_label.setVisible(v);
	
	frame_rolls.setVisible(v);
end

-- from CoreRPG
function setTargetingVisible()
	local v = false;
	if activatetargeting.getValue() == 1 then
		v = true;
	end

	targetingicon.setVisible(v);
	
	sub_targeting.setVisible(v);
	
	frame_targeting.setVisible(v);

	target_summary.onTargetsChanged();
end

-- from CoreRPG
function setSpacingVisible()
	local v = false;
	if activatespacing.getValue() == 1 then
		v = true;
	end

	spacingicon.setVisible(v);
	
	space.setVisible(v);
	spacelabel.setVisible(v);
	reach.setVisible(v);
	reachlabel.setVisible(v);
	
	frame_spacing.setVisible(v);
end

-- From CoreRPG
function setEffectsVisible()
	local v = false;
	if activateeffects.getValue() == 1 then
		v = true;
	end
	
	effecticon.setVisible(v);
	
	effects.setVisible(v);
	effects_iadd.setVisible(v);
	for _,w in pairs(effects.getWindows()) do
		w.idelete.setValue(0);
	end

	frame_effects.setVisible(v);

	effect_summary.onEffectsChanged();
end
