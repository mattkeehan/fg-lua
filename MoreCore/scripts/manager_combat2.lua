-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
--  Debug.console("Combat2.onInit: registerResultHandler");
	CombatManager.setCustomSort(sortfunc);
	CombatManager.setCustomDrop(onDrop);

	CombatManager.setCustomAddNPC(addNPC);
	CombatManager.setCustomAddPC(addPC);
	CombatManager.setCustomNPCSpaceReach(getNPCSpaceReach);

	CombatManager.setCustomRoundStart(onRoundStart);
	CombatManager.setCustomCombatReset(resetInit);
end

--
-- COMBAT TRACKER SORT
-- Damian 10 06 2018
function resetInit()
	local sMCInitDice = OptionsManager.getOption("MCInitDice");
	local sMCRerollPC = OptionsManager.getOption("MCRerollPCInitDice");
	Debug.console("sMCRerollPC: ", sMCRerollPC)
	Debug.console("sMCInitDice: ", sMCInitDice);	
	

		for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
			local sClass, sRecord = DB.getValue(nodeCT, "link");
			if sMCInitDice == "0" then
				if sClass == "charsheet" and sRecord then
					local nodeChar = DB.findNode(sRecord);
					local sMCInitBonus = DB.getValue(nodeChar,"initbonus",0);
					local sNewInit = tonumber(sMCInitBonus);
					if sMCRerollPC == "Reroll" then
						DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
						end
					if sMCRerollPC == "Reset" then
						DB.setValue(nodeCT, "initresult", "number", 0);
						end
					end
				if sClass == "npc" then
					local sMCInitBonus = DB.getValue(nodeCT,"initbonus",0);	
					local sNewInit = tonumber(sMCInitBonus);
					DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
					end
			elseif sMCInitDice == "2d10" then
				if sClass == "charsheet" and sRecord then
					local nodeChar = DB.findNode(sRecord);
					local sMCInitBonus = DB.getValue(nodeChar,"initbonus",0);
					local sNewInit = math.random(10)+math.random(10)+tonumber(sMCInitBonus);
					if sMCRerollPC == "Reroll" then
						DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
						end
					if sMCRerollPC == "Reset" then
						DB.setValue(nodeCT, "initresult", "number", 0);
						end
					end
				if sClass == "npc" then
					local sMCInitBonus = DB.getValue(nodeCT,"initbonus",0);	
					local sNewInit = math.random(10)+math.random(10)+tonumber(sMCInitBonus);
					DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
					end
			else
				if sClass == "charsheet" and sRecord then
					local nodeChar = DB.findNode(sRecord);
					local sMCInitBonus = DB.getValue(nodeChar,"initbonus",0);
					local sNewInit = math.random(tonumber(sMCInitDice))+tonumber(sMCInitBonus);
					if sMCRerollPC == "Reroll" then
						DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
						end
					if sMCRerollPC == "Reset" then
						DB.setValue(nodeCT, "initresult", "number", 0);
						end
					end
				if sClass == "npc" then
					local sMCInitBonus = DB.getValue(nodeCT,"initbonus",0);	
					local sNewInit = math.random(tonumber(sMCInitDice))+tonumber(sMCInitBonus);
					DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
					end
			end
		end
end

function singleNPCReset()
	local sMCInitDice = OptionsManager.getOption("MCInitDice");
	local sMCRerollPC = OptionsManager.getOption("MCRerollPCInitDice");
		Debug.console("sMCRerollPC: ", sMCRerollPC)
	Debug.console("sMCInitDice: ", sMCInitDice);	

			local sClass, sRecord = DB.getValue(nodeCT, "link");

			if sClass == "npc" then
				local sMCInitBonus = DB.getValue(nodeCT,"initbonus",0);	
				local sNewInit = math.random(tonumber(sMCInitDice))+tonumber(sMCInitBonus);
				DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
				end
	end

function zeroInit()
			for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
				DB.setValue(nodeCT, "initresult", "number", 0);
				end

end

-- NOTE: Lua sort function expects the opposite boolean value compared to built-in FG sorting
function sortfunc(node1, node2)
	local nValue1 = DB.getValue(node1, "initresult", 0);
	local nValue2 = DB.getValue(node2, "initresult", 0);
	if nValue1 ~= nValue2 then
		return nValue1 > nValue2;
	end
	
	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return node1.getNodeName() < node2.getNodeName();
end

--
-- PER ROUND INITIATIVE
--

function onRoundStart(nRound)
	if OptionsManager.isOption("HRIR", "on") then
		rollInit();
	end
end


--
-- DROP HANDLING
--

function onDrop(rSource, rTarget, draginfo)
	local sDragType = draginfo.getType();

	-- Effect targeting
	if sDragType == "effect_targeting" then
		if User.isHost() then
			onEffectTargetingDrop(rSource, rTarget, draginfo);
			return true;
		end
	end
end

function onEffectTargetingDrop(rSource, rTarget, draginfo)
	local sTargetCT = ActorManager.getCTNodeName(rTarget);
	if sTargetCT ~= "" then
		local sRefClass, sEffectNode = draginfo.getShortcutData();
		if sRefClass and sEffectNode then
			if sRefClass == "ct_effect" then
				EffectManager.addEffectTarget(sEffectNode, sTargetCT);
			end
		end
	end
end

--
-- ADD FUNCTIONS
--

function getNPCSpaceReach(nodeNPC)
	if fCustomNPCSpaceReach then
		return fCustomNPCSpaceReach(nodeNPC);
	end
	
	local nDU = GameSystem.getDistanceUnitsPerGrid();
	local nSpace = (tonumber(DB.getValue(nodeNPC, "space", 1)) or 1) * nDU;
	local nReach = (tonumber(DB.getValue(nodeNPC, "reach", 1)) or 1) * nDU;
	return nSpace, nReach;
end


function addNPC(sClass, nodeNPC, sName)
	local nodeCT, nodeLastMatch = CombatManager.addNPCHelper(nodeNPC, sName);


	-- Roll initiative and sort
			local sMCInitDice = OptionsManager.getOption("MCInitDice");
			local sClass, sRecord = DB.getValue(nodeCT, "link");
			if sClass == "npc" then
				if sMCInitDice == "0" then
					if sClass == "npc" then
						local sMCInitBonus = DB.getValue(nodeCT,"initbonus",0);	
						local sNewInit = tonumber(sMCInitBonus);
						DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
					end
				else 
						local sMCInitBonus = DB.getValue(nodeCT,"initbonus",0);	
						local sNewInit = math.random(tonumber(sMCInitDice))+tonumber(sMCInitBonus);
						DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
					end
			end

	return nodeCT;
end




--
-- RESET FUNCTIONS
--

function resetEffects()
	for _, vChild in pairs(DB.getChildren(CombatManager.CT_LIST)) do
		local nodeEffects = vChild.getChild("effects");
		if nodeEffects then
			for _, vEffect in pairs(nodeEffects.getChildren()) do
				vEffect.delete();
			end
		end
	end
end

function clearExpiringEffects(bShort)
	for _, vChild in pairs(DB.getChildren(CombatManager.CT_LIST)) do
		local nodeEffects = vChild.getChild("effects");
		if nodeEffects then
			for _, vEffect in pairs(nodeEffects.getChildren()) do
				local sLabel = DB.getValue(vEffect, "label", "");
				local nDuration = DB.getValue(vEffect, "duration", 0);
				
				if nDuration ~= 0 or sLabel == "" then
					if bShort then
						if nDuration > 50 then
							DB.setValue(vEffect, "duration", "number", nDuration - 50);
						else
							vEffect.delete();
						end
					else
						vEffect.delete();
					end
				end
			end
		end
	end
end


function rollEntryInit(nodeEntry)
	if not nodeEntry then
		return;
	end
	

	local sMCInitDice = OptionsManager.getOption("MCInitDice");
	local sMCRerollPC = OptionsManager.getOption("MCRerollPCInitDice");
	Debug.console("sMCRerollPC: ", sMCRerollPC)
	Debug.console("sMCInitDice: ", sMCInitDice);	
		for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
			local sClass, sRecord = DB.getValue(nodeCT, "link");
			
			if sMCInitDice == "0" then
				if sClass == "charsheet" and sRecord then
					local nodeChar = DB.findNode(sRecord);
					local sMCInitBonus = DB.getValue(nodeChar,"initbonus",0);
					local sNewInit = tonumber(sMCInitBonus);
					if sMCRerollPC == "Reroll" then
						DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
						end
					if sMCRerollPC == "Reset" then
						DB.setValue(nodeCT, "initresult", "number", 0);
						end
					end
				if sClass == "npc" then
					local sMCInitBonus = DB.getValue(nodeCT,"initbonus",0);	
					local sNewInit = tonumber(sMCInitBonus);
					DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
					end
			else
				if sClass == "charsheet" and sRecord then
					local nodeChar = DB.findNode(sRecord);
					local sMCInitBonus = DB.getValue(nodeChar,"initbonus",0);
					local sNewInit = math.random(tonumber(sMCInitDice))+tonumber(sMCInitBonus);
					if sMCRerollPC == "Reroll" then
						DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
						end
					if sMCRerollPC == "Reset" then
						DB.setValue(nodeCT, "initresult", "number", 0);
						end
					end
				if sClass == "npc" then
					local sMCInitBonus = DB.getValue(nodeCT,"initbonus",0);	
					local sNewInit = math.random(tonumber(sMCInitDice))+tonumber(sMCInitBonus);
					DB.setValue(nodeCT, "initresult", "number", tonumber(sNewInit));
					end
			end
		end
	end

function rollInit(sType)
	for _, vChild in pairs(DB.getChildren(CombatManager.CT_LIST)) do
		local bRoll = true;
		if sType then
			local sClass,_ = DB.getValue(vChild, "link", "", "");
			if sType == "npc" and sClass == "charsheet" then
				bRoll = false;
			elseif sType == "pc" and sClass ~= "charsheet" then
				bRoll = false;
			end
		end
		
		if bRoll then
			DB.setValue(vChild, "initresult", "number", -10000);
		end
	end

	for _, vChild in pairs(DB.getChildren(CombatManager.CT_LIST)) do
		local bRoll = true;
		if sType then
			local sClass,_ = DB.getValue(vChild, "link", "", "");
			if sType == "npc" and sClass == "charsheet" then
				bRoll = false;
			elseif sType == "pc" and sClass ~= "charsheet" then
				bRoll = false;
			end
		end
		
		if bRoll then
			rollEntryInit(vChild);
		end
	end
end

--
-- PARSE CT ATTACK LINE
--

function XXXparseAttackLine(rActor, sText)
	local rAttackRolls = {};
	local rDamageRolls = {};

	sText = sText:gsub("�", "-");

	local aClauses = {};
	local nIndex = 1;
	local nStart, nEnd, nStart2, nEnd2, nStart3, nEnd3;
	local sPhrase;
	while nIndex < #sText do
		nStart, nEnd = string.find(sText, "%s+or%s+", nIndex);
		nStart2, nEnd2 = string.find(sText, "%s*;%s*", nIndex);
		nStart3, nEnd3 = string.find(sText, "%)%s*,%s*", nIndex);
		nStart4, nEnd4 = string.find(sText, "%s+and%s+", nIndex);
		
		if nStart2 and (not nStart or nStart > nStart2) then
			nStart = nStart2;
			nEnd = nEnd2;
		end
		if nStart3 and (not nStart or nStart > nStart3) then
			nStart = nStart3 + 1;
			nEnd = nEnd3;
		end
		if nStart4 and (not nStart or nStart > nStart4) then
			nStart = nStart4;
			nEnd = nEnd4;
		end
		
		if nStart then
			sPhrase = string.sub(sText, nIndex, nEnd - 1);
		else
			sPhrase = string.sub(sText, nIndex);
		end
		
		nPhraseStart, sAll, sAttackCount, sAttackLabel, nDamageStart, sDamage, nDamageEnd, nPhraseEnd = string.match(sPhrase, '()((%d*) ?([%w%s%[%]%+%-]*) %(()([^%)]*)()%))()');
		if nPhraseStart then
			local rAttack = {};
			rAttack.startpos = nIndex + nPhraseStart - 1;
			rAttack.endpos = nIndex + nPhraseEnd - 1;
			
			local rDamage = {};
			rDamage.startpos = nIndex + nDamageStart - 1;
			rDamage.endpos = nIndex + nDamageEnd - 1;
			
			-- Clean up the attack count field (i.e. magical weapon bonuses up front, no attack count)
			local nAttackCount = 1;
			if #sAttackCount then
				nAttackCount = tonumber(sAttackCount) or 1;
				if nAttackCount < 1 then
					nAttackCount = 1;
				end
			end

			-- Watch for touch attacks
			local aLabelWords = StringManager.parseWords(sAttackLabel:lower());
			if StringManager.contains(aLabelWords, "touch") then
				rAttack.touch = true;
			end
			
			-- Decode any attack bonus
			local nBonusStart, sAttackModifier = string.match(sAttackLabel, "()%s+([%+%-]?%d+)$");
			if nBonusStart then
				sAttackLabel = sAttackLabel:sub(1, nBonusStart);
			end
			
			-- Capitalize first letter of label
			sAttackLabel = StringManager.capitalize(sAttackLabel);
			
			rAttack.label = sAttackLabel;
			rAttack.count = nAttackCount;
			rAttack.modifier = sAttackModifier;
			
			rDamage.label = sAttackLabel;
			local aDamageDice, nDamageMod = StringManager.convertStringToDice(sDamage)
			rDamage.dice = aDamageDice;
			rDamage.modifier = nDamageMod;
			
			-- Add to roll list
			table.insert(rAttackRolls, rAttack);
			table.insert(rDamageRolls, rDamage);
		end
		
		if nStart then
			nIndex = nEnd + 1;
		else
			nIndex = #sText;
		end
	end
	
	return rAttackRolls, rDamageRolls;
end
