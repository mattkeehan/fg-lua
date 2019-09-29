---
--- Initialization
---
function onInit()
	Comm.registerSlashHandler("wizard", processRoll);
	-- Damian added below to get the ModStack?
  GameSystem.actions["spell"] = { bUseModStack = true, sTargeting = "all" };
	ActionsManager.registerResultHandler("spell", onRoll);

end

---
---	This is the function that is called when the rollover slash command is called.
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
	rRoll.sType = "spell";
	rRoll.nMod = 0;
---	rRoll.sUser = User.getUsername();
	rRoll.aDice = {};
Debug.chat("Wizard!");	
	local nStart, nEnd, sSpellPoints, sDescriptionParam = string.find(sParams, "(%d+)%s*(.*)");
	Debug.chat("sDescriptionParam: ", sDescriptionParam);
	local sDesc1, sName1, sNode1 = string.match(sDescriptionParam, "(^.)|(%w+)|(%w+.$)");
Debug.chat("sDesc1!", sDesc1, " sName1! ", sName1, " sNode1: ", sNode1);	
Debug.chat("sDescriptionParam!", sDescriptionParam, " sSpellPoints! ", sSpellPoints);	
rRoll.sDesc = sDesc1;
local sDesc1 = "Magic Missile";
local sName1 = "Badajoz";
local sNode1 = "charsheet.id-00001";
local nSpellMax = DB.getValue(sNode1 .. ".spells.max");
local nSpellCur = DB.getValue(sNode1 .. ".spells.cur");
Debug.chat("nSpellMax: ", nSpellMax, " nSpellCur: ", nSpellCur);


	function createChatMessage(rSource, rRoll);
	Debug.console("rSource: ", rSource);
	Debug.console("rMessage: ", rMessage.text);
	Debug.console("rTarget: ", rTarget);
	Debug.console("rRoll: ", rRoll);

	if nSpellMax == "0" then 
		rMessage.text = "You cast a spell";
	else
		rMessage.text = "You cast a spell and used " .. sSpellPoints .. " spell points.";
	end
	
	Comm.deliverChatMessage(rMessage);

		
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sSpellPoints:match("%d+") then
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"# [description]\"";
		return rRoll;
	end

	
	local nSpellPoints = tonumber(sSpellPoints);
	local sDesc, nMod = ModifierStack.getStack(true);
	local nSpellPoints = nSpellPoints + nMod;
	

	rRoll.nSpellPoints = nSpellPoints;
	if sDesc ~= "" then
  	rRoll.sDesc = rRoll.sDesc.. " \n["..sDesc.."]";
  end

	return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll, rTarget)	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Debug.console("rSource: ", rSource);
	Debug.console("rMessage: ", rMessage.text);
	Debug.console("rTarget: ", rTarget);
	Debug.console("rRoll: ", rRoll);

local rActor = ActorManager.getActor("pc", charSheetDBNode);
	Debug.console("rActor: ", rActor);

	local nodeWin = window.getDatabaseNode();
						local sName = nodeWin.getChild("name").getValue();
	
	Debug.console("sName: ", sName, " nodeWin: ", nodeWin);

	rMessage.text = rMessage.text .. "uses " .. rRoll.sDesc ;
	
  if rRoll.nSpellPoints < 1 then
    rMessage.text = rMessage.text .. "\n[Fail]";
  elseif rRoll.rollover >= 3 then
    rMessage.text = rMessage.text .. "\n[Critical Success]";
  else
    rMessage.text = rMessage.text .. "\n[Limited Success]";
  end

	
	return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()	
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "The \"/rollover\" command is used to roll a set of dice and report the number of dice that roll equal to or under a success target number.\n"; 
	rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the success target number"; 
	rMessage.text = rMessage.text .. "by supplying the \"/rollover\" command with parameters in the format of \"#d#x#\", where the first # is the "; 
	rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
	rMessage.text = rMessage.text .. "x being the success target number for each dice."; 
	Comm.deliverChatMessage(rMessage);
end

---
--- This is the callback that gets triggered after the roll is completed.
---
function onRoll(rSource, rTarget, rRoll)
--	rRoll = dropDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll, rTarget);
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
end