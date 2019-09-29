---
--- Initialization
---
function onInit()
	Comm.registerSlashHandler("rollundersmod", processRoll);
	-- Damian added below to get the ModStack?
  GameSystem.actions["rollundersmod"] = { bUseModStack = true, sTargeting = "all" };
	ActionsManager.registerResultHandler("rollundersmod", onRoll);

	-- send launch message
--	local msg = {sender = "", font = "emotefont"};
--	msg.text = "Success count for Roll Under extension for CoreRPG based Rulesets.  v1.0 by damned.  Based on extensions by DMFirmy and Trenloe. Type \"/rollunder ?\" for usage.";
--	ChatManager.registerLaunchMessage(msg);
end

---
---	This is the function that is called when the rollundersmod slash command is called.
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
	rRoll.sType = "rollundersmod";
	rRoll.nMod = 0;
---	rRoll.sUser = User.getUsername();
	rRoll.aDice = {};
	
	local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
	rRoll.sDesc = sDescriptionParam;
	
	Debug.console("Dice pattern = " .. sDicePattern);

	-- If no target number is specified, we will assume it is 10
	if(not sDicePattern:match("(%d+)d([%dF]*)x(%d+)") and sDicePattern:match("(%d+)d([%dF]+)%s*(.*)")) then
		sDicePattern = sDicePattern .. " 10"
	end
	
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sDicePattern:match("%d+d%d+x%d+%s*(.*)") then
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#x# [description]\"";
		return rRoll;
	end
	
	Debug.console("Dice pattern 2 = " .. sDicePattern);

	-- First try to match a rollundersmod string including a modifier - #d#x#[+-]#
	local sNum, sSize, sSuccessLevel, sCommandMod = sDicePattern:match("(%d+)d([%dF]+)x(%d+)([+-]%d+)");
	
	-- If no modifier in the command string, process without - i.e. #d#x#
	if not sCommandMod then
		--Debug.console("Running pattern match without modifier");
		sNum, sSize, sSuccessLevel = sDicePattern:match("(%d+)d([%dF]+)x(%d+)");
		sCommandMod = "0";
	end
	
	--local nMod = tonumber(sMod);
	local sDesc, nMod = ModifierStack.getStack(true);
	
	Debug.console("sNum = " .. sNum .. ", sSize = " .. sSize .. ", sSuccessLevel = " .. sSuccessLevel .. ", sCommandMod = " .. sCommandMod);
	
	-- Set the total modifier to the final successes to be the command string modifier + any modifier widget data.
	rRoll.nMod = nMod + tonumber(sCommandMod);
	
	
	--local sNum = tonumber(sNum);
	local count = tonumber(sNum);
	local nSuccessLevel = tonumber(sSuccessLevel);

	while count > 0 do
		table.insert(rRoll.aDice, "d" .. sSize);
		
		-- For d100 rolls, we also need to add a d10 dice for the ones place
		if sSize == "100" then
			table.insert(rRoll.aDice, "d10");
		end
		count = count - 1;
	end
	
	rRoll.nSuccessLevel = nSuccessLevel;
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
	local nSuccessLevel = tonumber(rRoll.nSuccessLevel) or 0;
	local nSuccesses = 0;
	local nMod = rRoll.nMod;
	
	for _,v in ipairs(rRoll.aDice) do
		if v.result <= nSuccessLevel then
			nSuccesses = nSuccesses + 1;
		end
	end
	
	nSuccesses = nSuccesses + nMod;
	
	-- If resulting successes are less than 0 due to a negative modifer, set the total successes to be 0
	if nSuccesses < 0 then
		nSuccesses = 0;
	end
	
	Debug.console("Stuff: ", nSuccesses, nMod)
	rRoll.rollunder = nSuccesses;

	return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Debug.console("rSource: ");
	Debug.console(rSource);
	Debug.console("rMessage: " .. rMessage.text);
	
	local nSuccessLevel = tonumber(rRoll.nSuccessLevel) or 0;
	rMessage.text = rMessage.text .. "\nSuccesses = " .. rRoll.rollunder .. "\n" .. "(Target = " .. nSuccessLevel .. ")";
	
	return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()	
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "The \"/rollundersmod\" command is used to roll a set of dice and report the number of dice that roll equal to or under a success target number.\n"; 
	rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the success target number"; 
	rMessage.text = rMessage.text .. "by supplying the \"/rollundersmod\" command with parameters in the format of \"#d#x#([+-]#)\", where the first # is the "; 
	rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
	rMessage.text = rMessage.text .. "x being the success target number for each dice.  There is an option modifier that adds/subtracts from the final number of successes - to a minimum of 0."; 
	rMessage.text = rMessage.text .. "  The modifier box adds/subtracts the final number of successes.";
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