---
--- Initialization
---
function onInit()
	Comm.registerSlashHandler("sfdice", processRoll);
	GameSystem.actions["sfdice"] = { bUseModStack = true};
	ActionsManager.registerResultHandler("sfdice", onRoll);
end

---
---	This is the function that is called when the successes slash command is called.
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
	rRoll.sType = "sfdice";
	rRoll.nMod = 0;
	rRoll.aDice = {};
	
    -- Grab discription. 
	local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
	rRoll.sDesc = sDescriptionParam;

	-- If no target number is specified, we will assume it is 0
    --Removing F was:(%d+)d([%dF]*)s(%d+)f(%d+)
    -- This step may not be needed. 
	if(not sDicePattern:match("(%d+)d([%d]*)s(%d+)f(%d+)") and sDicePattern:match("(%d+)d([%d]+)%s*(.*)")) then
		sDicePattern = sDicePattern .. " 0";
    end
	
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sDicePattern:match("(%d+)d([%d]*)s(%d+)f(%d+)") then
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#s#f#\"";
		return rRoll;
	end

    -- Grab # in the argument and assign them.
	local sNum, sSize, sSuccessLevel, sFailLevel = sDicePattern:match("(%d+)d([%d]+)s(%d+)f(%d+)");
	local count = tonumber(sNum);
    local nSize = tonumber(sSize);
	local nSuccessLevel = tonumber(sSuccessLevel);
    local nFailLevel = tonumber(sFailLevel);

    -- Set dice into Table.
	while count > 0 do
		table.insert(rRoll.aDice, "d" .. sSize);
		
		-- For d100 rolls, we also need to add a d10 dice for the ones place
		if sSize == "100" then
			table.insert(rRoll.aDice, "d10");
		end
		count = count - 1;
	end
	
    --Pass gathered info. 
	rRoll.nSize = nSize;
    rRoll.nSuccessLevel = nSuccessLevel;
    rRoll.nFailLevel = nFailLevel;

	return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function dropDiceResults(rRoll)
	local nSuccessLevel = tonumber(rRoll.nSuccessLevel) or 0;
	local nSuccesses = 0;
    local nFailLevel = tonumber(rRoll.nFailLevel) or 0;
    local nFails = 0;
    local nSize = tonumber(rRoll.nSize);
    local nPassFailText = "";
    local nOutcome = 0;
    local nModUpdate = ModifierStack.getSum();

    --Reset ModStack after use.
    ModifierStack.reset();
	
    --Error Checking to make sure user doesn't set difficulty above dice size or below 1. 
    nSuccessLevel = nSuccessLevel + nModUpdate;
    nSuccessLevel = math.min(nSuccessLevel, nSize);
    nSuccessLevel = math.max(nSuccessLevel, 1);
    
    --Roll the dice and count up successes and fails
	
    for _,v in ipairs(rRoll.aDice) do
		if v.result >= nSuccessLevel then
			nSuccesses = nSuccesses + 1;            
		elseif v.result <= nFailLevel then
			nFails = nFails + 1;
		end
	end
    
    --Calc Outcome
    nOutcome = nSuccesses - nFails;

    --Set Outcome Text.
    if nOutcome >0 then
        nPassFailText = "Success!";
    else
        nPassFailText = "Fail";
    end
       
    --Pass gathered info. 
	rRoll.successLevel = nSuccessLevel;
	rRoll.successes = nSuccesses;
    rRoll.fails = nFails;
    rRoll.passFailText = nPassFailText;
    rRoll.outcome = nOutcome;
    
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
	Debug.console("rRoll.result: ");
	Debug.console(rRoll.outcome);
	rMessage.text = rMessage.text .. "\n[Difficulty] "..rRoll.successLevel.."\n[Successes] " .. rRoll.successes .. "\n[Fails] " .. rRoll.fails .."\n" .. rRoll.passFailText .. " ("..rRoll.outcome..")" .. "\n";
	
	return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()	
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "The \"/sfdice\" command is used to roll a set of dice and report the number of dice that meet or exceed a success target number.\n"; 
	rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, the success target number, and the fail target number"; 
	rMessage.text = rMessage.text .. "by supplying the \"/sfdice\" command with parameters in the format of \"#d#s#f#\", where the first # is the "; 
	rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, the number following the "; 
	rMessage.text = rMessage.text .. "s being the success target number for each dice, and the number following f is the fail target number for each dice."; 
	Comm.deliverChatMessage(rMessage);
end

---
--- This is the callback that gets triggered after the roll is completed.
---
function onRoll(rSource, rTarget, rRoll)
	rRoll = dropDiceResults(rRoll);
	Debug.console("rRoll: ");
	Debug.console(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
end