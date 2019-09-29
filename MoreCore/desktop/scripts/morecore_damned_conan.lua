---
--- Initialization
---
function onInit()
	Comm.registerSlashHandler("conan", processRoll);
	-- Damian added below to get the ModStack?
  GameSystem.actions["conan"] = { bUseModStack = true, sTargeting = "all" };
	ActionsManager.registerResultHandler("conan", onRoll);

	-- send launch message
--	local msg = {sender = "", font = "emotefont"};
--	msg.text = "Success count for Roll Under extension for CoreRPG based Rulesets.  v1.0 by damned.  Based on extensions by DMFirmy and Trenloe. Type \"/conan ?\" for usage.";
--	ChatManager.registerLaunchMessage(msg);
end

---
---	This is the function that is called when the conan slash command is called.
---
function processRoll(sCommand, sParams)
	if not sParams or sParams == "" then 
		createHelpMessage();
		return;
	end

	if sParams == "?" or string.lower(sParams) == "help" then
		createHelpMessage();		
	else
		local rRoll = createRoll(sParams);
		ActionsManager.roll(nil, nil, rRoll);
	end		
end

---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
	local rRoll = {};
	rRoll.sType = "conan";
	rRoll.nMod = 0;
---	rRoll.sUser = User.getUsername();
	rRoll.aDice = {};
	
	local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
	rRoll.sDesc = sDescriptionParam;

	-- If no target number is specified, we will assume it is 10
	if(not sDicePattern:match("(%d+)d([%dF]*)x(%d+)") and sDicePattern:match("(%d+)d([%dF]+)%s*(.*)")) then
		sDicePattern = sDicePattern .. " 10"
	end
	
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sDicePattern:match("%d+d%d+x%d+y%d+%s*(.*)") then
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#x#y# [description]\"";
		return rRoll;
	end

	local sNum, sSize, sRollUnder1, sRollUnder2 = sDicePattern:match("(%d+)d([%dF]+)x(%d+)y(%d+)");
	-- Damian added but need to get the nMod first in ln 38 its set as 0
	
	local sDesc, nMod = ModifierStack.getStack(true);
	
	
	local sNum = tonumber(sNum) + nMod;
	local count = tonumber(sNum);
	local nRollUnder1 = tonumber(sRollUnder1);
	local nRollUnder2 = tonumber(sRollUnder2);

	while count > 0 do
		table.insert(rRoll.aDice, "d" .. sSize);
		
		-- For d100 rolls, we also need to add a d10 dice for the ones place
		if sSize == "100" then
			table.insert(rRoll.aDice, "d10");
		end
		count = count - 1;
	end
	
	rRoll.nRollUnder1 = nRollUnder1;
	rRoll.nRollUnder2 = nRollUnder2;
	if sDesc ~= "" then
  	rRoll.sDesc = rRoll.sDesc.." ["..sDesc.."]";
  end

	return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function dropDiceResults(rRoll)
	local nRollUnder1 = tonumber(rRoll.nRollUnder1) or 0;
	local nRollUnder2 = tonumber(rRoll.nRollUnder2) or 0;
	local nSuccesses = 0;
	local nComplications = 0;
	local nUntrained = 0;
	
	for _,v in ipairs(rRoll.aDice) do
		if v.result == 20 then
			nComplications = nComplications + 1;
		end
		if v.result == 19 then
			nUntrained = nUntrained + 1;
		end
		if v.result <= nRollUnder1 then
			nSuccesses = nSuccesses + 1;
		end
		if v.result <= nRollUnder2 then
			nSuccesses = nSuccesses + 1;
		end
	end
	
	rRoll.conan = nSuccesses;
	rRoll.complications = nComplications;
	rRoll.untrained = nUntrained;
	rRoll.nRollUnder1 = nRollUnder1;
	rRoll.nRollUnder2 = nRollUnder2;
	return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)	

	nRollUnder1 = rRoll.nRollUnder1;
	nRollUnder2 = rRoll.nRollUnder2;
	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Debug.console("rSource: ");
	Debug.console(rSource);
	Debug.console("rMessage: " .. rMessage.text);
	rMessage.text = rMessage.text .. "\nSuccesses = " .. rRoll.conan .. "\nComplications = " .. rRoll.complications;
		if nRollUnder1 == 0 and nRollUnder2 == 0 then
			rMessage.text = rMessage.text .. "\nPossible Compliations " .. rRoll.untrained;
			end
	
	return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()	
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "The \"/conan\" command is used to roll a set of dice and report the number of dice that roll equal to or under a success target number.\n"; 
	rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the success target number"; 
	rMessage.text = rMessage.text .. "by supplying the \"/conan\" command with parameters in the format of \"#d#x#\", where the first # is the "; 
	rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
	rMessage.text = rMessage.text .. "x being the success target number for each dice."; 
	Comm.deliverChatMessage(rMessage);
end

---
--- This is the callback that gets triggered after the roll is completed.
---
function onRoll(rSource, rTarget, rRoll)
	rRoll = dropDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
end