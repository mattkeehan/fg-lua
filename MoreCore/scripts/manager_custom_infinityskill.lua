-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "infskill";

-- MoreCore v0.60 
function onInit()
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
--	Debug.console("performAction: ", draginfo, rActor, sParams);
	if not sParams or sParams == "" then 
		sParams = "2d20";
	end

	if sParams == "?" or string.lower(sParams) == "help" then
		createHelpMessage();    
	else
		local rRoll = createRoll(sParams);
		ActionsManager.performAction(draginfo, rActor, rRoll);
	end   
	
end


function onLanded(rSource, rTarget, rRoll)
--	Debug.console("onLanded: ", rSource, rTarget, rRoll);
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rRoll = getDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
end


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)

	local rRoll = {};
	rRoll.sType = sCmd;
	rRoll.nMod = 0;
	--- rRoll.sUser = User.getUsername();
	rRoll.aDice = {};
	rRoll.aDropped = {};

	local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
	rRoll.sDesc = sDescriptionParam;

  
  
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if sDicePattern:match("(%d+)d([%dF]*)a(%d+)e(%d+)f(%d+)") then
		-- Everything is good, carry on
	elseif sDicePattern:match("(%d+)d([%dF]*)a(%d+)e(%d+)") then
		-- Missing Focus, add focus and carry on
		aDicePattern = aDicePattern .. "f0";
	elseif sDicePattern:match("(%d+)d([%dF]*)a(%d+)") then
		-- Missing Expertise and Focus, add them and carry on
		sDicePattern = sDicePattern .. "e0f0";
	else
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#a#\" or \"#d#a#e#\" or \"#d#a#e#f#\"";
		return rRoll;
	end

	local sDesc, nMod = ModifierStack.getStack(true);
	local sNum, sSize, sAtt, sExp, sFocus = sDicePattern:match("(%d+)d([%dF]+)a(%d+)e(%d+)f(%d+)");

	local count = tonumber(sNum) + nMod;
	local size = tonumber(sSize);
	local attributeScore = tonumber(sAtt);
	local expertise = tonumber(sExp);
	local focus = tonumber(sFocus);

	while count > 0 do
		table.insert(rRoll.aDice, "d" .. sSize);
		count = count - 1;
	end

	rRoll.nSkill = attributeScore + expertise;
	rRoll.nFocus = focus;

	if( expertise == 0 ) then
		rRoll.nComplicationRange = 19;
	else
		rRoll.nComplicationRange = 20;
	end

  return rRoll;
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function getDiceResults(rRoll)

	local skill = tonumber(rRoll.nSkill);
	local focus = tonumber(rRoll.nFocus) or 0;
	local successes = 0;
	local complicationRange = tonumber(rRoll.nComplicationRange);
	local complications = 0;

	for _,v in ipairs(rRoll.aDice) do
		if v.result <= skill then
			successes = successes + 1;
			if v.result <= focus then
				successes = successes + 1;
			end
		end
		
		if( v.result >= complicationRange ) then
			complications = complications + 1;
		end
	end

	

	rRoll.aComplications = complications;
	rRoll.aSuccesses = successes;
	rRoll.aFocus = focus;
	rRoll.aSkill = skill;
	return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.text = rMessage.text .. "\n[Skill] " .. rRoll.aSkill .. "\n[Focus] " .. rRoll.aFocus .. "\n[Successes] " .. rRoll.aSuccesses .. "\n[Complications] " .. rRoll.aComplications;

    rMessage.dicedisplay = 0; -- don't display total
  
    rMessage.text = rMessage.text;

	return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll a set of dice, and counting the number of successes below a target skill number based on an Attribute Score plus (optionally) Expertise in a skill.";
  rMessage.text = rMessage.text .. "You may specify a focus, and every result less than or equal to the focus will count as an additional success.\n"; 
  rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the attribute score "; 
  rMessage.text = rMessage.text .. "by supplying the \"/rolld\" command with parameters in the format of \"#d#a#\", where the first # is the "; 
  rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and lastly the attribute score after the a.\n"; 
  rMessage.text = rMessage.text .. "You can optionally include e# to add expertise and e#f# to add expertise and focus.\n"; 
  rMessage.text = rMessage.text .. "If no expertise or focus are supplied, they are assumed to be 0."; 
  rMessage.text = rMessage.text .. "Complications are generated on a 20, unless the expertise is 0, in which case complications are generated on a 19+."; 
  Comm.deliverChatMessage(rMessage);
end
