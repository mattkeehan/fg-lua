---
--- Initialization
---

local sCmd = "dsaatt";

-- MoreCore v0.60 
function onInit()
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", onMod);
    
	--CustomDiceManager.add_roll_type("critconfirm", performAction, createChatMessage, false, "all");
  	--ActionsManager.registerResultHandler(sCmd, onAttack);
	ActionsManager.registerResultHandler("critconfirm", onLanded);
	ActionsManager.registerResultHandler("botchconfirm", onLanded);
end

function performAction(draginfo, rActor, sParams)
  Debug.console("performAction: ", draginfo, rActor, sParams);

  if sParams == "?" or string.lower(sParams) == "help" then
    createHelpMessage();    
  else
    local rRoll = createRoll(sParams);
	Debug.console("performAction: rRoll ", rRoll);
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
	
	local sTargetText = ""
	Debug.console("rTarget = ", rTarget);
	if rTarget then
		sTargetText = " vs "..rTarget.sName;
	end	

	-- If there are more than 1 slot then we have additional modifiers added to the roll.
	if #aModSlots > 1 or (string.find(rRoll.sDesc, "Attack") == 1 and #aModSlots > 0) or (string.find(rRoll.sDesc, "Defense") == 1 and #aModSlots > 0) then
		-- Get the total modifier from the slots after the first
		--local nModSlotCount = 0;
		local nModSlotStart = 2;
		if string.find(rRoll.sDesc, "Attack") == 1 or string.find(rRoll.sDesc, "Defense") == 1 then
			nModSlotStart = 1;
		end
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
		sStackDesc = string.gsub(sStackDesc, aModSlots[1].description .. " %+" .. aModSlots[1].number .. ", ", "", 1);
		
		Debug.console("sStackDesc after attribute removal = " .. sStackDesc);
		
		-- Add modifier stack text to overall roll description
		if sStackDesc ~= "" then
			if bDescNotEmpty then
				rRoll.sDesc = rRoll.sDesc .. sTargetText .. "\r\n[" .. sStackDesc .. "]";
			else
				rRoll.sDesc = sTargetText .. sStackDesc;
			end
		end	
	else
		if rRoll.sDesc ~= "" then
			rRoll.sDesc = rRoll.sDesc .. sTargetText;
		else
			rRoll.sDesc = sTargetText;
		end	
		if ModifierStack.freeadjustment ~= 0 then
			rRoll.sDesc = rRoll.sDesc .. "\r\n[Mod: " .. ModifierStack.freeadjustment .. "]";
		end		
	end
	
	rRoll.totalMod = rRoll.totalMod + ModifierStack.freeadjustment
	
	Debug.console("Total mod to attribute check = " .. rRoll.totalMod .. ", Free adjustment = " .. ModifierStack.freeadjustment);
	
    ModifierStack.reset();
	
	addEffectModifiers(rSource, rTarget, rRoll);
 
end

function addEffectModifiers(rSource, rTarget, rRoll)
	local sTempDescription = ""
	-- Add pain effect - PAIN
	local nPAINMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"PAIN"}, true, nil, rTarget);
	if nPAINMod ~= 0 then
		sTempDescription =  string.format("%s[PAIN %+d] ", sTempDescription, nPAINMod);
		rRoll.totalMod = rRoll.totalMod + nPAINMod;
	end

	-- Add Confused effect - CONF
	local nCONFMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"CONF"}, true, nil, rTarget);
	if nCONFMod ~= 0 then
		sTempDescription = string.format("%s[CONF %+d] ", sTempDescription, nCONFMod);
		rRoll.totalMod = rRoll.totalMod + nCONFMod;
	end	
	
	-- Add Fear effect - STUP
	local nFEARMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"FEAR"}, true, nil, rTarget);
	if nFEARMod ~= 0 then
		sTempDescription = string.format("%s[FEAR %+d] ", sTempDescription, nFEARMod);
		rRoll.totalMod = rRoll.totalMod + nFEARMod;
	end		
	
	-- Add Stupor effect - STUP
	local nSTUPMod = EffectManagerMoreCore.getEffectsBonus(rSource, {"STUP"}, true, nil, rTarget);
	if nSTUPMod ~= 0 then
		sTempDescription = string.format("%s[STUP %+d] ", sTempDescription, nSTUPMod);
		rRoll.totalMod = rRoll.totalMod + nSTUPMod;
	end		

	if sTempDescription ~= "" then
		rRoll.sDesc = rRoll.sDesc .. "\r\n" .. sTempDescription
	end
end

function getDSAattDice(rRoll)
local rDie1;
local nResult1;

    rDie1 = rRoll.aDice[1];
    nResult1 = rDie1.result;
	
	Debug.console("nResult1: ", nResult1);

	rRoll.total = nResult1;

	return rRoll;
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
  rRoll.aDice = {"d20"};
		Debug.console("rRoll.aDice: ", rRoll.aDice);
  rRoll.sType = sCmd;
		Debug.console("rRoll.sType: ", sCmd);
  rRoll.sDesc = "Attribute check: ";
  rRoll.nMod = 0;
---  rRoll.nTarget = 0;
--- rRoll.sUser = User.getUsername();

  
  --local nStart, nEnd, sMod, sDescriptionParam = string.find(sParams, "([+-]?[%d]+)%s*(.*)");
	local nStart, nEnd, sMod, sDescriptionParam = string.find(sParams, "([+-]?[%d]+)%s*(.*)");
	Debug.console("createRoll - parameter parsing: ", sParams, nStart, nEnd, tonumber(sMod), sDescriptionParam);
	
	rRoll.attrValue = tonumber(sMod);
	if sDescriptionParam then
		rRoll.sDesc = rRoll.sDesc .. sDescriptionParam;	
	end
	
	--Get attribute name and modifier from the first modifier slot
--	local aModSlots = ModifierStack.slots;
--	if #aModSlots >= 1 then
--		rRoll.attrValue = aModSlots[1].number;
--		rRoll.sDesc = rRoll.sDesc .. aModSlots[1].description;
--	end
			
--	if sMod then
--		rRoll.nMod = tonumber(sMod);
--		Debug.console("rRoll.nMod1: ", rRoll.nMod);
--		rRoll.sDesc = sDescriptionParam;
--		Debug.console("rRoll.sDesc: ", rRoll.sDesc);
--	else
--		rRoll.sDesc = sParams;
--	end

Debug.console("createRoll: ",rRoll);
  
  return rRoll;
end

function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  
  	Debug.console("rRoll.sDesc = " .. rRoll.sDesc);
	Debug.console("createChatMessage, rRoll = ", rRoll);
	
	-- Default message icon is failure - code will change to success as appropriate
	rMessage.icon = "poll_negative";
  
    rMessage.dicedisplay = 0; 
	
	-- Check for adjusted attribute totals (from additional check modifiers) and adjust as necessary
	rRoll.target = tonumber(rRoll.attrValue) + rRoll.totalMod
	--rRoll.slot2target = tonumber(rRoll.slot2target) + rRoll.totalMod
	--rRoll.slot3target = tonumber(rRoll.slot3target) + rRoll.totalMod
	
	rMessage.text = rMessage.text .. "\r\nTotal modifiers = " .. rRoll.totalMod
	
	-- If adjusted attribute is 0 or less then the roll automatically fails.	
	if rRoll.target <= 0 then
		rMessage.text = rMessage.text .. "\r\nThe adjusted attribute (EAV) is 0 or less - roll automatically fails."
		return rMessage;
	end	
	
	Debug.console("Die result = ", rRoll.aDice[1].result);
	
	-- Check for a critical (natural 1) and roll the critconfirm die
	if rRoll.aDice[1].result ==1 and rRoll.sType ~= "critconfirm" and rRoll.sType ~= "botchconfirm" then
		local rCritConfirmRoll = { sType = "critconfirm", aDice = {"d20"} };
		--rCritConfirmRoll.nMod = rRoll.nMod + nCCMod;
		rCritConfirmRoll.nMod = 0
		
		rCritConfirmRoll.sDesc = "Critical confirm: ";
		rCritConfirmRoll.attrValue = rRoll.attrValue;
		rCritConfirmRoll.totalMod = rRoll.totalMod;
		
		ActionsManager.roll(rSource, rTarget, rCritConfirmRoll);			
	end
	
	-- Check for a botch (natural 20) and roll the botchconfirm die
	if rRoll.aDice[1].result == 20 and rRoll.sType ~= "botchconfirm" and rRoll.sType ~= "critconfirm" then
		local rCritConfirmRoll = { sType = "botchconfirm", aDice = {"d20"} };
		--rCritConfirmRoll.nMod = rRoll.nMod + nCCMod;
		rCritConfirmRoll.nMod = 0
		
		rCritConfirmRoll.sDesc = "Botch confirm: ";
		rCritConfirmRoll.attrValue = rRoll.attrValue;
		rCritConfirmRoll.totalMod = rRoll.totalMod;
		
		ActionsManager.roll(rSource, rTarget, rCritConfirmRoll);			
	end	
	
	-- Calculate result of base roll and botch/crit confirm if appropriate.
	-- Display result text.
	if rRoll.sType == "critconfirm" then
		if rRoll.total <= rRoll.target and rRoll.total ~= 20 then
			rMessage.text = rMessage.text .. "\r\n[Dice Roll] " .. rRoll.total .. "\r\n[Roll Under Target] " .. rRoll.target .. " \r\nCritical Confirmed!\n";
			rMessage.icon = "poll_check";
		else      
			rMessage.text = rMessage.text .. "\r\n[Dice Roll] " .. rRoll.total .. "\r\n[Roll Under Target] " .. rRoll.target .. " \r\nNo critical.  Normal success.\n";
			rMessage.icon = "poll_empty";
		end
	elseif rRoll.sType == "botchconfirm" then
		if rRoll.total > rRoll.target or rRoll.total == 20 then
			rMessage.text = rMessage.text .. "\r\n[Dice Roll] " .. rRoll.total .. "\r\n[Roll Under Target] " .. rRoll.target .. " \r\Botch Confirmed!\n";
		else      
			rMessage.text = rMessage.text .. "\r\n[Dice Roll] " .. rRoll.total .. "\r\n[Roll Under Target] " .. rRoll.target .. " \r\nNo botch.  Normal failure.\n";
			rMessage.icon = "poll_empty";
		end	
	elseif rRoll.total == 1 then
		rMessage.text = rMessage.text .. "\r\n[Dice Roll] " .. rRoll.total .. "\r\n[Roll Under Target] " .. rRoll.target .. " \r\n[Result] Auto success.  Possible critical!\n";
		rMessage.icon = "poll_check";
	elseif rRoll.total == 20 then
		rMessage.text = rMessage.text .. "\r\n[Dice Roll] " .. rRoll.total .. "\r\n[Roll Under Target] " .. rRoll.target .. " \r\n[Result] Auto failure.  Possible botch!\n";
    elseif rRoll.total <= rRoll.target then
		rMessage.text = rMessage.text .. "\r\n[Dice Roll] " .. rRoll.total .. "\r\n[Roll Under Target] " .. rRoll.target .. " \r\n[Result] Success\n";
		rMessage.icon = "poll_check";
	elseif rRoll.total > rRoll.target then       
		rMessage.text = rMessage.text .. "\r\n[Dice Roll] " .. rRoll.total .. "\r\n[Roll Under Target] " .. rRoll.target .. " \r\n[Result] Failure\n";
	end
 
  return rMessage;
end

function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.."\n"; 
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command rolls 1d20 as an aatribute check for The Dark Eye (TDE) RPG.\n "; 
  rMessage.text = rMessage.text .. "The taret of the check is taken from XX in the roll name: <TDE attribute name> XX\n"; 
  rMessage.text = rMessage.text .. "For example: Charisma 13 or Strength 10.  Use the standard TDE attribute names: Agility, Charisma, Constitution, Courage, Dexterity, Intuition, Sagacity, Strength."; 
  Comm.deliverChatMessage(rMessage);
end

