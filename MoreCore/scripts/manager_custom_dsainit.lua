---
--- Initialization
---

local sCmd = "dsainit";

-- MoreCore v0.60 
function onInit()
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", onMod);
end

-- Handler for rolling form the Combat Tracker
function performActionCT(draginfo, rActor, node)

	--Debug.console("performActionCT - draginfo, rActor, node: ", draginfo, rActor, node);
	
	local nListCount = 1;
	local bFound = false;
	local sInitValue = ""
	-- Search through each of the first three "clilist" data paths - clilist1, clilist2 and clilist3
	while nListCount <= 3 and not bFound do
		local sheetNode = DB.getChild(rActor.sCreatureNode, "clilist" .. nListCount)
		if sheetNode then
			if sheetNode.getChildCount() > 0 then
				for k, childNode in pairs(sheetNode.getChildren()) do	
					if childNode.getChild("rollstype").getValue() then
						-- Matches on DB node: <rollstype type="string">dsainit</rollstype>
						if childNode.getChild("rollstype").getValue() == "dsainit" then
							sInitValue = childNode.getChild("name").getValue();
							Debug.console("Matched rolltype = dsainit, returning name of: " .. sInitValue);
							bFound = true;
							break;
						end
					end
				end	
			end
		end
		nListCount = nListCount + 1
	end
	
	if bFound then
		performAction(draginfo, rActor, "Initiative " .. sInitValue)
	end

end

function performAction(draginfo, rActor, sParams)
  Debug.console("performAction: ", draginfo, rActor, sParams);

  if sParams == "?" or string.lower(sParams) == "help" then
    createHelpMessage();    
  else
    local rRoll = createRoll(sParams);
	Debug.console("performAction: rRoll ", rRoll);
	-- Do secondary parameter checks here - either continue roll with the performAction function, or create the roll help message and exit without rolling.
	if rRoll.attrValue then
		ActionsManager.performAction(draginfo, rActor, rRoll);
	else
		createHelpMessage();
	end
  end   
end

function onMod(rSource, rTarget, rRoll)
	Debug.console("onMod: ", rSource, rTarget, rRoll);
  
	local aModSlots = ModifierStack.slots;
	rRoll.totalMod = 0;
	
--	local sTargetText = ""
--	Debug.console("rTarget = ", rTarget);
--	if rTarget then
--		sTargetText = " vs "..rTarget.sName;
--	end	

	-- If there are more than 1 slot then we have additional modifiers added to the roll.
	if #aModSlots > 0 then
		-- Get the total modifier from the slots
		--local nModSlotCount = 0;
		local nModSlotStart = 1;
		for nModSlotCount = nModSlotStart, #aModSlots, 1
		do
			Debug.console("Modslot modifier " .. nModSlotCount .. " = " .. aModSlots[nModSlotCount].number);
			rRoll.totalMod = rRoll.totalMod + aModSlots[nModSlotCount].number;
		end 
		Debug.console("Total mod from slots to attribute check = " .. rRoll.totalMod);
		
		local bDescNotEmpty = (rRoll.sDesc ~= "");
		local sStackDesc, nStackMod = ModifierStack.getStack(bDescNotEmpty);
		
		Debug.console("sStackDesc before attribute removal = " .. sStackDesc .. ", checking for " .. aModSlots[1].description .. " %+" .. aModSlots[1].number .. ", ");
		-- Remove attribute name and bonus from modifier text
		--sStackDesc = string.gsub(sStackDesc, aModSlots[1].description .. " %+" .. aModSlots[1].number .. ", ", "", 1);
		
		--Debug.console("sStackDesc after attribute removal = " .. sStackDesc);
		
		-- Add modifier stack text to overall roll description
		if sStackDesc ~= "" then
			if bDescNotEmpty then
				rRoll.sDesc = rRoll.sDesc .. "\r\n[" .. sStackDesc .. "]";
			else
				rRoll.sDesc = sStackDesc;
			end
		end	
	else
		if ModifierStack.freeadjustment ~= 0 then
			rRoll.sDesc = rRoll.sDesc .. "\r\n[Mod: " .. ModifierStack.freeadjustment .. "]";
		end		
	end
	
	rRoll.totalMod = rRoll.totalMod + ModifierStack.freeadjustment
	
	-- Add the base modifier from the INI/Initiative value
	rRoll.totalMod = rRoll.totalMod + rRoll.attrValue
	
	Debug.console("Total mod to Init roll = " .. rRoll.totalMod .. ", Free adjustment = " .. ModifierStack.freeadjustment);
	
    ModifierStack.reset();
	
	addEffectModifiers(rSource, rTarget, rRoll);
	
	-- Move the total modifier to the standard roll modifier
	rRoll.nMod = rRoll.totalMod
 
end

function addEffectModifiers(rSource, rTarget, rRoll)
	-- Flag incapacitated condition due to level IV conditions that incapacitate the actor
	-- Using strings rather than boolean - boolean values don't appear to be maintained in rRoll after the result of the roll.
	rRoll.sIncapacitated = "no";

	local sTempDescription = ""
	
	local nENCMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"ENC"}, true, nil, rTarget);
	if nENCMod ~= 0 then
		sTempDescription = string.format("%s[ENC %+d] ", sTempDescription, nENCMod);
		if nENCMod <= -4 then
			rRoll.sIncapacitated = "yes";
		end
		rRoll.totalMod = rRoll.totalMod + nENCMod;	
	end
	
	-- INI modifier - allows modifier for armor and other random INI mods
	local nINIMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"INI"}, true, nil, rTarget);
	if nINIMod ~= 0 then
		sTempDescription = string.format("%s[INI %+d] ", sTempDescription, nINIMod);
		rRoll.totalMod = rRoll.totalMod + nINIMod;	
	end	

	if sTempDescription ~= "" then
		rRoll.sDesc = rRoll.sDesc .. "\r\n" .. sTempDescription
	end
end

function onLanded(rSource, rTarget, rRoll)
--Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rRoll.total = rRoll.aDice[1].result;
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
end

function createRoll(sParams)
  local rRoll = { };
  rRoll.aDice = {"d6"};
		Debug.console("rRoll.aDice: ", rRoll.aDice);
  rRoll.sType = sCmd;
		Debug.console("rRoll.sType: ", sCmd);
  rRoll.sDesc = "Initiative Roll: ";
  rRoll.nMod = 0;
	-- Get Init roll bonus
	local nStart, nEnd, sInit = string.find(sParams,"[%w%s&%-%+](%d+)");

	Debug.console("createRoll - parameter parsing: ", sParams, tonumber(sInit), sParams);
	
	rRoll.attrValue = tonumber(sInit);
	if sParams then
		rRoll.sDesc = rRoll.sDesc .. sParams;	
	end

Debug.console("createRoll: ",rRoll);
  
  return rRoll;
end

function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  
  	Debug.console("rRoll.sDesc = " .. rRoll.sDesc);
	Debug.console("createChatMessage, rRoll = ", rRoll);
  
	-- Show the total (roll + modifier) in the chat window
    rMessage.dicedisplay = 1; 

	rMessage.text = rMessage.text .. "\r\nTotal modifiers = " .. (rRoll.totalMod - rRoll.attrValue)
	
	if rRoll.sIncapacitated == "yes" then
		rMessage.text = rMessage.text .. "\r\nINCAPACITATED due to ENC level IV.";	
	end
	
	-- Apply total to the Order field in the PC/NPC.
	local nRollTotal = rRoll.total + rRoll.totalMod
	Debug.console("Roll total = " .. nRollTotal);
	
	local sCreatureNode = rSource.sCreatureNode;
	local nodeCreature = DB.findNode(sCreatureNode);
	if nodeCreature.getChild("initresult") then
		nodeCreature.getChild("initresult").setValue(nRollTotal);
	end
 
  return rMessage;
end

function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.."\n"; 
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command rolls 1d6 as an initiative check for The Dark Eye (TDE) RPG and adds the Initiative modifier\n "; 
  rMessage.text = rMessage.text .. "The INI bonus for the roll is taken from XX in the roll name: Initiative XX\n"; 
  Comm.deliverChatMessage(rMessage);
end

