---
--- Initialization
---


-- Still to do
-- Collect and store the Skill value from the slash eg /Command 7 as nSkill
-- Split the modifiers up - and store the first three separately as nMod1, nMod2, nMod3
--

local sCmd = "dsaskill";
local modSlotOffset = 0;

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", onMod);
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);

	if sParams == "?" or string.lower(sParams) == "help" then
		createHelpMessage();    
	else
		local rRoll = createRoll(sParams);
		Debug.console("performAction: rRoll ", rRoll);
		local aModSlots = ModifierStack.slots;	
--		if #aModSlots <3 or not aModSlots[1].number or aModSlots[1].number == 0 then
--			local rMessage = ChatManager.createBaseMessage(nil, nil);
--			rMessage.text = rMessage.text .. "There are not enough attributes selected for the skill check or the attributes are not valid."; 
--			Comm.deliverChatMessage(rMessage);
--			createHelpMessage();
		--else		
		if getAttributes(rActor, rRoll) then
			ActionsManager.performAction(draginfo, rActor, rRoll);
		else
			local rMessage = ChatManager.createBaseMessage(nil, nil);
			rMessage.text = rMessage.text .. "Could not generate attribute entries for skill check.  Make sure the three attribute 3 letter codes are in the /dsaskill XX AAA/BBB/CCC dice string - where AAA, BBB and CCC are the three letter attribute codes to match with the first 3 letters of the attributes in the first two ability windows in the PC sheet."; 
			Comm.deliverChatMessage(rMessage);
			createHelpMessage();		  
		end
		--end
	end   

end

function getDSAattDice(rRoll)
local rDie1, rDie2, rDie3;
local nResult1, nResult2, nResult3;

    rDie1 = rRoll.aDice[1];
    nResult1 = rDie1.result;
		Debug.console("nResult1: ", nResult1);

    rDie2 = rRoll.aDice[2];
    nResult2 = rDie2.result;
		Debug.console("nResult2: ", nResult2);

    rDie3 = rRoll.aDice[3];
    nResult3 = rDie3.result;
		Debug.console("nResult3: ", nResult3);

		rRoll.total1 = nResult1;
		rRoll.total2 = nResult2;
		rRoll.total3 = nResult3;

	return rRoll;
end

function checkForAttribute(sStringToCheck)
	local nStart, nEnd, sFirst3Letters = string.find(sStringToCheck, "(%a%a%a).*")
	sFirst3Letters = string.upper(sFirst3Letters);
	Debug.console("Checking " .. sStringToCheck .. " for attribute with: " .. sFirst3Letters);
	if sFirst3Letters == "CHA" or sFirst3Letters == "COU" or sFirst3Letters == "INT" or sFirst3Letters == "SAG" or sFirst3Letters == "AGI" or sFirst3Letters == "CON" or sFirst3Letters == "DEX" or sFirst3Letters == "STR" then
		return true;
	end
	return false;
end

function getAttributes(rSource, rRoll)
	local aModSlots = ModifierStack.slots;
	modSlotOffset = 0;
	local bAttributesBuilt = false;
	if #aModSlots >= 3 then
		if checkForAttribute(aModSlots[1].description) and checkForAttribute(aModSlots[2].description) and checkForAttribute(aModSlots[3].description) then
			-- Each slot description looks like a Dark Eye attribute name - use the first 3 mod slots to override the skill check attributes.
			rRoll.slot1attr = aModSlots[1].description;
			rRoll.slot1target = aModSlots[1].number;
			
			rRoll.slot2attr = aModSlots[2].description;
			rRoll.slot2target = aModSlots[2].number;
			
			rRoll.slot3attr = aModSlots[3].description;
			rRoll.slot3target = aModSlots[3].number	
			
			modSlotOffset = 3;
			
			bAttributesBuilt = true;
		end
	end
	
	if rRoll.sAttributesType == "Value" then
		-- Build attributes from roll values if available
		rRoll.slot1attr = "Attr1" .. " " .. rRoll.sAttributes[1]
		rRoll.slot1target = rRoll.sAttributes[1]							
		rRoll.slot2attr = "Attr2" .. " " .. rRoll.sAttributes[2]
		rRoll.slot2target = rRoll.sAttributes[2]							
		rRoll.slot3attr = "Attr3" .. " " .. rRoll.sAttributes[3]
		rRoll.slot3target = rRoll.sAttributes[3]
		bAttributesBuilt = true;	
		
	elseif modSlotOffset == 0 and rRoll.sAttributesType == "Code" then
		-- The first mod slot is not an attribute and we have attribute codes, so use the attributes set in the skill check text
		
		Debug.console("rRoll.sAttributes = ", rRoll.sAttributes);
		Debug.console("rSource data = ", rSource);			
					
		-- Get the DB nodes of the top-left and top-center ability section on the PC sheet - this is where we look for matching attributes
		local attributeNode1 = DB.getChild(rSource.sCreatureNode, "clilist1")  -- Will only exist for PCs
		local attributeNode2 = DB.getChild(rSource.sCreatureNode, "clilist2")  -- Will exist for PCs and NPCs

		-- Match against PC sheet attributes.
		for k, sAttrCode in pairs(rRoll.sAttributes) do
			if sAttrCode == "SGC" then
				sAttrCode = "SAG";
			end
			Debug.console("Finding value for attribute: " .. sAttrCode .. ", Key = " .. k);
			local bFound = false
			bAttributesBuilt = false;
			if attributeNode1 then
				-- attributeNode1 will only exist for PCs
				for _,childNode in pairs(attributeNode1.getChildren()) do
					local sName = childNode.getChild("name").getValue()
					local nStart, nEnd, sFirst3Letters = string.find(sName, "(%a%a%a).*")
					if sFirst3Letters then
						sFirst3Letters = string.upper(sFirst3Letters);	
						--Debug.console("Checking name of " .. sName .. " code = " .. sFirst3Letters);
						if sAttrCode == sFirst3Letters then
							bFound = true;
							bAttributesBuilt = true;
							local nStart, nEnd, nAttrValue = string.find(sName, ("%a+ (%d+)"))
							if k == 1 then
								rRoll.slot1attr = sName
								rRoll.slot1target = nAttrValue							
							elseif k == 2 then
								rRoll.slot2attr = sName
								rRoll.slot2target = nAttrValue							
							elseif k == 3 then
								rRoll.slot3attr = sName
								rRoll.slot3target = nAttrValue							
							end
							Debug.console("We have a match!  Stored attribute name = " .. sName .. ", value = " .. nAttrValue);						
							break;
						end	
					end
				end	
			end
			if not bFound then
				for _,childNode in pairs(attributeNode2.getChildren()) do
					local sName = childNode.getChild("name").getValue()
					local nStart, nEnd, sFirst3Letters = string.find(sName, "(%a%a%a).*")
					if sFirst3Letters then
						sFirst3Letters = string.upper(sFirst3Letters);	
						--Debug.console("Checking name of " .. sName .. " code = " .. sFirst3Letters);
						if sAttrCode == sFirst3Letters then
							if string.find(childNode.getChild("clichatcommand").getValue(), ("/mod ")) == 1 then
								bAttributesBuilt = true;
								local nStart, nEnd, nAttrValue = string.find(childNode.getChild("clichatcommand").getValue(), ("/mod (%d+)"))
								if k == 1 then
									rRoll.slot1attr = sName
									rRoll.slot1target = nAttrValue							
								elseif k == 2 then
									rRoll.slot2attr = sName
									rRoll.slot2target = nAttrValue							
								elseif k == 3 then
									rRoll.slot3attr = sName
									rRoll.slot3target = nAttrValue							
								end			
								Debug.console("We have a match!  Stored attribute name = " .. sName .. ", value = " .. nAttrValue);
								break;
							end
						end
					end
				end					
			end
			-- If we don't match an attribute then exit with false
			if not bAttributesBuilt then
				return false;
			end
		end					
	end
	
	return bAttributesBuilt;
end

function onMod(rSource, rTarget, rRoll)
--Debug.console("onMod: ", rSource, rTarget, rRoll);
  
	local aModSlots = ModifierStack.slots;
	rRoll.totalMod = 0;

	-- If there are more than 3 slots then we have additional modifiers added to the roll.
	if #aModSlots > modSlotOffset then
		-- Get the total modifier from the slots after the first 3
		local nModSlotCount = 0;
		for nModSlotCount = modSlotOffset + 1, #aModSlots, 1
		do
			Debug.console("Modslot modifier " .. nModSlotCount .. " = " .. aModSlots[nModSlotCount].number);
			rRoll.totalMod = rRoll.totalMod + aModSlots[nModSlotCount].number;
		end 
		Debug.console("Total mod from slots to skill check = " .. rRoll.totalMod);
		
		local bDescNotEmpty = (rRoll.sDesc ~= "");
		local sStackDesc, nStackMod = ModifierStack.getStack(bDescNotEmpty);
		
		Debug.console("sStackDesc before attribute removal = " .. sStackDesc);
		-- Remove attribute names from modifier text
		sStackDesc = string.gsub(sStackDesc, rRoll.slot1attr .. " %+" .. rRoll.slot1target .. ", ", "", 1);
		sStackDesc = string.gsub(sStackDesc, rRoll.slot2attr .. " %+" .. rRoll.slot2target .. ", ", "", 1);
		sStackDesc = string.gsub(sStackDesc, rRoll.slot3attr .. " %+" .. rRoll.slot3target .. ", ", "", 1);
		sStackDesc = string.gsub(sStackDesc, rRoll.slot3attr .. " %+" .. rRoll.slot3target, "", 1);
		
		Debug.console("sStackDesc after attribute removal = " .. sStackDesc);
		
		-- Add modifier stack text to overall roll description
		if sStackDesc ~= "" then
			if bDescNotEmpty then
				rRoll.sDesc = rRoll.sDesc .. "\r\n[" .. sStackDesc .. "]";
			else
				rRoll.sDesc = sStackDesc;
			end
		end		
	end
	
	rRoll.totalMod = rRoll.totalMod + ModifierStack.freeadjustment
	
	Debug.console("Total mod to skill check = " .. rRoll.totalMod .. ", Free adjustment = " .. ModifierStack.freeadjustment);
	
    ModifierStack.reset();

	addEffectModifiers(rSource, rTarget, rRoll);
 
end

function addEffectModifiers(rSource, rTarget, rRoll)

	-- Flag incapacitated condition due to level IV conditions that incapacitate the actor
	-- Using strings rather than boolean - boolean values don't appear to be maintained in rRoll after the result of the roll.
	rRoll.sIncapacitated = "no";
	rRoll.sMentalSkillOK = "no";

	local sTempDescription = ""
	-- Add pain effect - PAIN
	local nPAINMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"PAIN"}, true, nil, rTarget);
	if nPAINMod ~= 0 then
		if nPAINMod <= -4 then
			rRoll.sIncapacitated = "yes";
			rRoll.sMentalSkillOK = "yes";
		end		
		sTempDescription = string.format("%s[PAIN %+d] ", sTempDescription, nPAINMod);
		rRoll.totalMod = rRoll.totalMod + nPAINMod;
	end

	-- Add Confused effect - CONF
	local nCONFMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"CONF"}, true, nil, rTarget);
	if nCONFMod ~= 0 then
		if nCONFMod <= -4 then
			rRoll.sIncapacitated = "yes";
			rRoll.sMentalSkillOK = "no";
		end	
		sTempDescription = string.format("%s[CONF %+d] ", sTempDescription, nCONFMod);
		rRoll.totalMod = rRoll.totalMod + nCONFMod;
	end	
	
	-- Add Fear effect - STUP
	local nFEARMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"FEAR"}, true, nil, rTarget);
	if nFEARMod ~= 0 then
		if nFEARMod <= -4 then
			rRoll.sIncapacitated = "yes";
			rRoll.sMentalSkillOK = "no";
		end		
		sTempDescription = string.format("%s[FEAR %+d] ", sTempDescription, nFEARMod);
		rRoll.totalMod = rRoll.totalMod + nFEARMod;
	end		
	
	-- Add Stupor effect - STUP
	local nSTUPMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"STUP"}, true, nil, rTarget);
	if nSTUPMod ~= 0 then
		if nSTUPMod <= -4 then
			rRoll.sIncapacitated = "yes";
			rRoll.sMentalSkillOK = "no";
		end		
		sTempDescription = string.format("%s[STUP %+d] ", sTempDescription, nSTUPMod);
		rRoll.totalMod = rRoll.totalMod + nSTUPMod;
	end		
	
	-- Add Encumbrance effect - ENC
	Debug.console("rRoll.sEffects = " .. rRoll.sEffects);
	if string.find(rRoll.sEffects, "E") then
		local nENCMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"ENC"}, true, nil, rTarget);
		if nENCMod ~= 0 then
			sTempDescription = string.format("%s[ENC %+d] ", sTempDescription, nENCMod);
			if nENCMod <= -4 then
				rRoll.sIncapacitated = "yes";
				rRoll.sMentalSkillOK = "no";
			end
			rRoll.totalMod = rRoll.totalMod + nENCMod;
		end	
	end
	
	-- Add Rapture effect - RAPT
	--Debug.console("rRoll.sEffects = " .. rRoll.sEffects);

	local nRAPTMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"RAPT"}, true, nil, rTarget);
	if nRAPTMod ~= 0 then
		-- If the skill (or spell) is tagged as being agreebale to the caster's god (with a R for Rapture) then apply a bonus.
		if string.find(rRoll.sEffects, "R") then
			nRAPTMod = math.abs(nRAPTMod) - 1;
		end
		sTempDescription = string.format("%s[RAPT %+d] ", sTempDescription, nRAPTMod);
		rRoll.totalMod = rRoll.totalMod + nRAPTMod;		
	end	
	
	-- Add Paralysis effect - PARA
	local nPARAMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"PARA"}, true, nil, rTarget);
	if nPARAMod ~= 0 then
		sTempDescription = string.format("%s[PARA %+d] ", sTempDescription, nPARAMod);
		rRoll.totalMod = rRoll.totalMod + nPARAMod;
	end		
	
	if sTempDescription ~= "" then
		rRoll.sDesc = rRoll.sDesc .. "\r\n" .. sTempDescription
	end	
	
	Debug.console("End of processing effects.  rRoll = ", rRoll);

end

function onLanded(rSource, rTarget, rRoll)
--Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rRoll = getDSAattDice(rRoll);
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
end


function createRoll(sParams)
	local rRoll = { };
	rRoll.aDice = {"d20", "d20", "d20"};
	Debug.console("rRoll.aDice: ", rRoll.aDice);
	rRoll.sType = sCmd;
	Debug.console("rRoll.sType: ", sCmd);
	rRoll.nMod = 0;
  
	-- Look for most common skill definition - including the 3 attribute codes.  e.g. /dsaskill <SR> XXX/YYY/ZZZ
	--local nStart, nEnd, sTarget, sAttributes1, sAttributes2, sAttributes3, sEffects, sDescriptionParam = string.find(sParams, "([%d]+)%s*(%a+)/(%a+)/(%a+)%s*(%[%a*%])%s*(.*)")
	--local nStart, nEnd, sAttributes1, sAttributes2, sAttributes3, sEffects, sDescriptionParam = string.find(sParams,"(%a+)/(%a+)/(%a+)%s*(%[%a*%])%s*(.*)")
	
	-- Get skill check attributes and Skill Ranks (SR)
	local nStart, nEnd, sEffects, sAttributes1, sAttributes2, sAttributes3, sSR = string.find(sParams,"(%[%a*%])[%w%s&%-%+]*%((%a+)/(%a+)/(%a+)%)%s*(%d+)");
	
	-- Get Skill Check description
	local nStart, nEnd, sDescriptionParam = string.find(sParams,"%[%a*%]([%w%s&%-%+]*%(%a+/%a+/%a+%)%s*%d+)")
	
	Debug.console("sParams, sAttributes1, sAttributes2, sAttributes3, sEffects = ", sParams, sAttributes1, sAttributes2, sAttributes3, sEffects);
  
	if sAttributes1 and sAttributes2 and sAttributes3 then
		sAttributes = {sAttributes1, sAttributes2, sAttributes3};
		rRoll.sAttributesType = "Code";
	else
		-- We don't have any attributes defined - look for actual attribute scores
		--nStart, nEnd, sTarget, sAttributes1, sAttributes2, sAttributes3, sEffects, sDescriptionParam = string.find(sParams, "([%d]+)%s*(%d+)/(%d+)/(%d+)%s*(%[%a*%])%s*(.*)")
		--nStart, nEnd, sAttributes1, sAttributes2, sAttributes3, sEffects, sDescriptionParam = string.find(sParams,"(%d+)/(%d+)/(%d+)%s*(%[%a*%])%s*(.*)")
		
		-- Get skill check attributes and Skill Ranks (SR)
		nStart, nEnd, sEffects, sAttributes1, sAttributes2, sAttributes3, sSR = string.find(sParams,"(%[%a*%])[%w%s&%-%+]*%((%d+)/(%d+)/(%d+)%)%s*(%d+)");
		
		-- Get Skill Check description
		nStart, nEnd, sDescriptionParam = string.find(sParams,"%[%a*%]([%w%s&%-%+]*%(%d+/%d+/%d+%)%s*%d+)")
		
		if sAttributes1 and sAttributes2 and sAttributes3 then
			sAttributes = {sAttributes1, sAttributes2, sAttributes3};
			rRoll.sAttributesType = "Value";
		else
			rRoll.sAttributesType = "Empty";
		end
		Debug.console("sParams, sAttributes, sEffects = ", sParams, sAttributes, sEffects);
	end
	
	--nStart, nEnd, sSR = string.find(sDescriptionParam,"%a* %(%a+/%a+/%a+%)%s*(%d+)%s*(.*)")
	
	Debug.console("Matching SR: ", sDescriptionParam, sSR);
  
	-- temp values assigned until I can retrieve values
	rRoll.skill = sSR;
	rRoll.sDesc = sDescriptionParam;
	rRoll.sAttributes = sAttributes;
	rRoll.sEffects = sEffects;
  
	Debug.console("sParams, sAttributes, sEffects = ", sParams, sAttributes, sEffects);

	Debug.console("createRoll: ",rRoll);
  
	return rRoll;
end

function createChatMessage(rSource, rRoll)  
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nSkillCurrent = tonumber(rRoll.skill);
	local nFailures = 0;
	local nCritCount = 0;
	local nBotchCount = 0;

	-- Default message icon is failure - code will change to success as appropriate
	rMessage.icon = "poll_negative";
  
	Debug.console("rRoll.sDesc = " .. rRoll.sDesc);
	Debug.console("createChatMessage, rRoll = ", rRoll);
  
    rMessage.dicedisplay = 0; 
	
	-- Check for adjusted attribute totals (from additional check modifiers) and adjust as necessary
	rRoll.slot1target = tonumber(rRoll.slot1target) + rRoll.totalMod
	rRoll.slot2target = tonumber(rRoll.slot2target) + rRoll.totalMod
	rRoll.slot3target = tonumber(rRoll.slot3target) + rRoll.totalMod
	
	rMessage.text = rMessage.text .. "\r\nTotal modifiers = " .. rRoll.totalMod
	
	-- Check for incapacitated due to conditions
	if rRoll.sIncapacitated == "yes" and rRoll.sMentalSkillOK == "no" then
		rMessage.text = rMessage.text .. "\r\nActor is INCAPACITATED.  Skill check not possible."
		return rMessage;	
	end
	
	-- If adjusted attribute is 0 or less then the roll automatically fails.	
	if rRoll.slot1target <= 0 or rRoll.slot2target <= 0 or rRoll.slot3target <= 0 then
		rMessage.text = rMessage.text .. "\r\nOne or more adjusted attributes are 0 or less - roll automatically fails."
		return rMessage;
	end
	
	local nPARAMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"PARA"}, true, nil, rTarget);
	if nPARAMod <= -4 then
		rMessage.text = rMessage.text .. "\r\nParalysis level 4 effect present.  No checks involving movement or speech possible.  If this check does not require movement or speech, temporarily disable the PARA effect and roll again."
		return rMessage;		
	end
	
	--Check for Criticals
	if rRoll.total1 == 1 or rRoll.total2 == 1 or rRoll.total3 == 1 then
		if rRoll.total1 == 1 then
			nCritCount = 1;
		end
		if rRoll.total2 == 1 then
			nCritCount = nCritCount + 1;
		end		
		if rRoll.total3 == 1 then
			nCritCount = nCritCount + 1;
		end	
		if nCritCount == 2 then
			-- Critical result
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot1attr .. " (" .. rRoll.total1 .. " vs. " .. rRoll.slot1target .. ")";
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot2attr .. " (" .. rRoll.total2 .. " vs. " .. rRoll.slot2target .. ")";
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot3attr .. " (" .. rRoll.total3 .. " vs. " .. rRoll.slot3target .. ")";
			if nSkillCurrent == 0 then
				nSkillCurrent = 1;	-- Set to 1 purely for the QL calculation.
			elseif nSkillCurrent >= 16 then
				nSkillCurrent = 16;	-- Set to 16 purely for the max QL calculation.				
			end
			rMessage.text = rMessage.text .. "\r\n[Quality] 2 x base (if appropriate) = " .. (math.floor((nSkillCurrent-1)/3)+1)*2;
			rMessage.text = rMessage.text .. "\r\n[Overall Result] CRITICAL Success!"	
			rMessage.icon = "poll_check";
			return rMessage;		
		elseif nCritCount == 3 then
			-- Spectacular critical result
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot1attr .. " (" .. rRoll.total1 .. " vs. " .. rRoll.slot1target .. ")";
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot2attr .. " (" .. rRoll.total2 .. " vs. " .. rRoll.slot2target .. ")";
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot3attr .. " (" .. rRoll.total3 .. " vs. " .. rRoll.slot3target .. ")";
			if nSkillCurrent == 0 then
				nSkillCurrent = 1;	-- Set to 1 purely for the QL calculation.
			elseif nSkillCurrent >= 16 then
				nSkillCurrent = 16;	-- Set to 16 purely for the max QL calculation.				
			end			
			rMessage.text = rMessage.text .. "\r\n[Quality] 2 x base (if appropriate) = " .. (math.floor((nSkillCurrent-1)/3)+1)*2;
			rMessage.text = rMessage.text .. "\r\n[Overall Result] SPECTACULAR Success!"
			rMessage.icon = "poll_check";
			return rMessage;
		end
	end
	
	--Check for Botches
	if rRoll.total1 == 20 or rRoll.total2 == 20 or rRoll.total3 == 20 then
		if rRoll.total1 == 20 then
			nBotchCount = 1;
		end
		if rRoll.total2 == 20 then
			nBotchCount = nBotchCount + 1;
		end		
		if rRoll.total3 == 20 then
			nBotchCount = nBotchCount + 1;
		end	
		if nBotchCount == 2 then
			-- Botch result
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot1attr .. " (" .. rRoll.total1 .. " vs. " .. rRoll.slot1target .. ")";
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot2attr .. " (" .. rRoll.total2 .. " vs. " .. rRoll.slot2target .. ")";
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot3attr .. " (" .. rRoll.total3 .. " vs. " .. rRoll.slot3target .. ")";
			rMessage.text = rMessage.text .. "\r\n[Overall Result] BOTCH Failure!"			
			return rMessage;		
		elseif nBotchCount == 3 then
			-- Disastrous Botch result
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot1attr .. " (" .. rRoll.total1 .. " vs. " .. rRoll.slot1target .. ")";
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot2attr .. " (" .. rRoll.total2 .. " vs. " .. rRoll.slot2target .. ")";
			rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot3attr .. " (" .. rRoll.total3 .. " vs. " .. rRoll.slot3target .. ")";
			rMessage.text = rMessage.text .. "\r\n[Overall Result] DISASTROUS BOTCH Failure!"
			return rMessage;
		end
	end	
	
    if rRoll.total1 <= tonumber(rRoll.slot1target) then
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot1attr .. " (" .. rRoll.total1 .. " vs. " .. rRoll.slot1target .. ") : Success!";
      elseif rRoll.total1 - nSkillCurrent <= tonumber(rRoll.slot1target) then
	    nSkillSpent = (rRoll.total1 - tonumber(rRoll.slot1target));
		nSkillCurrent = nSkillCurrent - nSkillSpent;
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot1attr .. " ("  .. rRoll.total1 .. " vs. " .. rRoll.slot1target .. ") : Success!" .. "\r\nSkill Spent: " .. nSkillSpent;
	  else
		nSkillCurrent = nSkillCurrent - (rRoll.total1 - tonumber(rRoll.slot1target));
		nFailures = nFailures + 1;
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot1attr .. " ("  .. rRoll.total1 .. " vs. " .. rRoll.slot1target .. ") : Failure! \r\nInsufficient Skill Points";
	-- Some sort of skip to end command?	
      end
 
    if rRoll.total2 <= tonumber(rRoll.slot2target) then
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot2attr .. " ("  .. rRoll.total2 .. " vs. " .. rRoll.slot2target .. ") : Success!";
      elseif rRoll.total2 - nSkillCurrent <= tonumber(rRoll.slot2target) then
	    nSkillSpent = (rRoll.total2 - tonumber(rRoll.slot2target));
		nSkillCurrent = nSkillCurrent - nSkillSpent;
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot2attr .. " ("  .. rRoll.total2 .. " vs. " .. rRoll.slot2target .. ") : Success!" .. "\r\nSkill Spent: " .. nSkillSpent;
	  else
		nSkillCurrent = nSkillCurrent - (rRoll.total1 - tonumber(rRoll.slot2target));
		nFailures = nFailures + 1;
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot2attr .. " (" .. rRoll.total2 .. " vs. " .. rRoll.slot2target .. ") : Failure! \r\nInsufficient Skill Points";
	-- Some sort of skip to end command?	
      end

    if rRoll.total3 <= tonumber(rRoll.slot3target) then
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot3attr .. " ("  .. rRoll.total3 .. " vs. " .. rRoll.slot3target .. ") : Success!";
      elseif rRoll.total3 - nSkillCurrent <= tonumber(rRoll.slot3target) then
	    nSkillSpent = (rRoll.total3 - tonumber(rRoll.slot3target));
		nSkillCurrent = nSkillCurrent - nSkillSpent;
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot3attr .. " ("  .. rRoll.total3 .. " vs. " .. rRoll.slot3target .. ") : Success!" .. "\r\nSkill Spent: " .. nSkillSpent;
	  else
		nSkillCurrent = nSkillCurrent - (rRoll.total1 - tonumber(rRoll.slot3target));
		nFailures = nFailures + 1;
        rMessage.text = rMessage.text .. "\r\n" .. rRoll.slot3attr .. " ("  .. rRoll.total3 .. " vs. " .. rRoll.slot3target .. ") : Failure! \r\nInsufficient Skill Points";
	-- Some sort of skip to end command?	
      end

	--Debug.console("Test QL = " .. math.floor((nSkillCurrent-1)/3)+1);

	if nFailures > 0 then
		rMessage.text = rMessage.text .. "\r\n[Overall Result] " .. nFailures .. " Failures!";
	elseif nSkillCurrent == 0 then
		rMessage.text = rMessage.text .. "\r\n[Overall Result] Success! \r\n[Quality] 1";
		rMessage.icon = "poll_check";
	elseif nSkillCurrent >= 16 then
		rMessage.text = rMessage.text .. "\r\n[Overall Result] Success! \r\n[Quality] 6";
		rMessage.icon = "poll_check";
	else
		rMessage.text = rMessage.text .. "\r\n[Overall Result] Success! \r\n[Quality] " .. math.floor((nSkillCurrent-1)/3)+1;
		rMessage.icon = "poll_check";
	end

	if rRoll.sIncapacitated == "yes" and rRoll.sMentalSkillOK == "yes" then
		rMessage.text = rMessage.text .. "\r\nActor is INCAPACITATED due to level IV pain!  Mental skill checks may be possible."
		rMessage.icon = "poll_empty";
	end
	
	if nPARAMod > -4 and nPARAMod ~=0 then
		rMessage.text = rMessage.text .. "\r\nParalysis effect active.  This modifies checks involving movement or speech."
		--TODO - Do coding for alternative result based off no PARA effect??		
	end	
	    
	return rMessage;
end



function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.." [<Effects>]\n"; 
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command rolls ... Takes details from the roll title:  <skill name> (<XXX/YYY/ZZZ) <sr>\n"; 
  rMessage.text = rMessage.text .. "Where XXX, YYY and ZZZ are the 3 character codes for the three attributes to roll the skill against."; 
  Comm.deliverChatMessage(rMessage);
end
