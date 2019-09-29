-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "factwelve";

-- MoreCore v0.60 
function onInit()
--  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  if not sParams or sParams == "" then 
    sParams = "1d4+0";
  end

  if sParams == "?" or string.lower(sParams) == "help" then
    createHelpMessage();    
  else
    local rRoll = createRoll(sParams);
    ActionsManager.performAction(draginfo, rActor, rRoll);
  end   

end


function onLanded(rSource, rTarget, rRoll)
Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  Debug.console("rMessage: ", rMessage);
  rRoll = dropDiceResults(rRoll);
  rMessage = createChatMessage(rSource, rRoll);
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
	Debug.console("sDescriptionParam:", sDescriptionParam);
 
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sParams:match("(%d+)d([%dF]*)+(%d+)") then
	rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"1d#+#\"";
	return rRoll;
  end

	local sNum, sSize, aMod = sParams:match("(%d+)d([%dF]*)+(%d+)");
	local nSize = tonumber(sSize);

	Debug.console("sNum, sSize, aMod, nSize: ", sNum, sSize, aMod, nSize);
	
	rRoll.aDice = {"d12","d12","d" .. nSize};
	Debug.console("rRoll.aDice: ", rRoll.aDice);

	local sModDesc, nMod = ModifierStack.getStack(true);
	
	rRoll.sNum = sNum;
	rRoll.sSize = sSize;
	rRoll.aMod = aMod;
	rRoll.nSize = nSize;
	rRoll.nMod = nMod;
	rRoll.sModDesc = sModDesc;
	
	return rRoll;
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function dropDiceResults(rRoll)

	table.sort(rRoll.aDice, function(a,b) return a.result > b.result end);
	Debug.console("rRoll: ", rRoll);

	local nResult1 = rRoll.aDice[1].result;
	local nResult2 = rRoll.aDice[2].result;
	nResult = rRoll.aDice[1].result+rRoll.aDice[2].result+rRoll.aMod+rRoll.nMod;
	Debug.console("nResult: ", nResult);
	rRoll.nResult = nResult;
	rRoll.nResult1 = nResult1;
	rRoll.nResult2 = nResult2;
	return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Debug.console("rRoll: ", rRoll);
	Debug.console("rSource: ", rSource);
	rMessage.text = rMessage.text .. ", " .. rRoll.sModDesc;
	rMessage.text = rMessage.text .. "\n[Kept] " .. rRoll.nResult1 .. " " .. rRoll.nResult2;
	rMessage.text = rMessage.text .. "\n[Modifiers] " .. rRoll.aMod .. " " .. rRoll.nMod .. "\n";
	rMessage.text = rMessage.text .. "[Total] " .. rRoll.nResult;

return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()	
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "The \"/factwelve\" command is used to roll a set of dice, removing a number of the lowest results.\n"; 
	rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the number of results to be dropped "; 
	rMessage.text = rMessage.text .. "by supplying the \"/factwelve\" command with parameters in the format of \"#d#+#d#+# #\".";
	rMessage.text = rMessage.text .. "If no parameters are supplied, the default parameters of \"2d12+1d4+0 1\" are used.";
	Comm.deliverChatMessage(rMessage);
end

---
--- This is the callback that gets triggered after the roll is completed.
---
function onRoll(rSource, rTarget, rRoll)
	rRoll = dropDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.type = sCmd;
	Comm.deliverChatMessage(rMessage);
end

function onDiceTotal( messagedata )
  Debug.console("onDiceTotal: ", messagedata);
  return true, nResult;
end
