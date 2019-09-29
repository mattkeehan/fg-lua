---
--- Initialization
---
function onInit()
	Comm.registerSlashHandler("woddice", processRoll);
	GameSystem.actions["woddice"] = { bUseModStack = true};
	ActionsManager.registerResultHandler("woddice", onRoll);
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
	rRoll.sType = "woddice";
    rRoll.nSize = 10;
	rRoll.nMod = 0;
	rRoll.aDice = {};
	
    -- Grab discription. 
	local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
	rRoll.sDesc = sDescriptionParam;

	-- If no target number is specified, we will assume it is 6
    --I don't think this step is needed. 
--    if(not sDicePattern:match("(%d+)s(%d+)") and sDicePattern:match("(%d+)%s*(.*)")) then
--		sDicePattern = sDicePattern .. " 6"
--	end
	
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sDicePattern:match("(%d+)s(%d+)") then
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#s#\"";
		return rRoll;
	end

    -- Grab # in the argument and assign them.
	local sNum, sSuccessLevel = sDicePattern:match("(%d+)s(%d+)");
	local count = tonumber(sNum);
    local nSuccessLevel = tonumber(sSuccessLevel);
    
    -- Set dice into Table.
	while count > 0 do
		table.insert(rRoll.aDice, "d" .. rRoll.nSize);
		
--		-- For d100 rolls, we also need to add a d10 dice for the ones place
--		if sSize == "100" then
--			table.insert(rRoll.aDice, "d10");
--		end
		count = count - 1;
	end
	
    --Pass gathered info. 
	
    rRoll.nSuccessLevel = nSuccessLevel;
    rRoll.nFailLevel = 1;

	return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function dropDiceResults(rRoll)
	local nSuccessLevel = tonumber(rRoll.nSuccessLevel) or 6;
	local nSuccesses = 0;
    local nFailLevel = tonumber(rRoll.nFailLevel);
    local nFails = 0;
    local nPassFailText = "";
    local nResult = 0;
    local nModUpdate = ModifierStack.getSum();

    --Reset ModStack after use.
    ModifierStack.reset();
	
    --If SuccessLevel is > 9 then remove successes and set successLevel to 9.
    --If SuccessLevel is < 3 set it to 3.
    nSuccessLevel = nSuccessLevel + nModUpdate; --Yes I am using this non-standardly. This is because adding values to the end doesn't makes sense on these types of dice.
    if nSuccessLevel > 9 then
        nSuccesses = 9-nSuccessLevel;
        nSuccessLevel = 9;
    elseif nSuccessLevel < 3 then
        nSuccessLevel = 3;
    end

    --Roll the dice and count up successes and fails
	for _,v in ipairs(rRoll.aDice) do
		if v.result >= nSuccessLevel then
			nSuccesses = nSuccesses + 1;
		elseif v.result <= nFailLevel then
			nFails = nFails + 1;
		end
	end
    
    --Calc Result
    nResult = nSuccesses - nFails;

    --Set Result Text.
    if nSuccesses <= 0 then
        if nFails >0 then
            nPassFailText = "Botch!";
        else
            nPassFailText = "Fail";
        end
    elseif nResult >0 then
        nPassFailText = "Success!";
    else
        nPassFailText = "Fail";
    end
     
     --Pass gathered info. 
	rRoll.successLevel = nSuccessLevel;
	rRoll.successes = nSuccesses;
    rRoll.fails = nFails;
    rRoll.passFailText = nPassFailText;
    rRoll.result = nResult;
    
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
	rMessage.text = rMessage.text .. "\nDiff = "..rRoll.successLevel..", Success = " .. rRoll.successes .. ", Fail = " .. rRoll.fails .."\n" .. rRoll.passFailText .. " ("..rRoll.result..")" .. "\n";
	
	return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()	
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text ..    "The \"/woddice\" command is used to roll a set of dice and give a Success Target number and a Fail Target number. " ..
                                        "The Result will return the value of number of Successes minus number of Fails. \n"..
                                        "By supplying the \"/woddice\" command with parameters in the format of \"#s#\":\n".. 
                                        "The first # is the number of dice. The second # is Success Target number. Example: 5s6 will return a success on any "..
                                        "dice 6+ and will return a fail on any dice with a 1.\n"..
                                        "Last the Modifier Stack works differently for this dice command than normal. A '+1' on the mod stack will increase the difficulty by 1."..
                                        "a '-2' will decrease the difficulty by 2. Example: 5s6 with a Mod of '-2' will return a success on any dice 4+. The Difficulties are limited from 3 to 9. \n"..
                                        "This version of OWoD dice is using threshold.";
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