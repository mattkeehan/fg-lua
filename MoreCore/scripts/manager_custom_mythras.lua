-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "mythras";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  if not sParams or sParams == "" then 
    sParams = "1d100w10x10y0z0";
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

  if(not sParams:match("(%d+)d([%dF]*)x(%d+)%s*(.*)") and sParams:match("(%d+)d([%dF]+)%s*(.*)")) then
    sDicePattern = sDicePattern .. "x7"
  end
  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
  if not sDicePattern:match("(%d+)d([%dF]*)w(%d+)x(%d+)y(%d+)z(%d+)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#x#\" or \"#d#x#y#\"";
	Debug.console("Bailing Out");
    return rRoll;
  end

  local sNum, sSize, sAtt1, sAtt2, sSkill, sDifficulty = sDicePattern:match("(%d+)d([%dF]+)w(%d+)x(%d+)y(%d+)z(%d+)");
	if sNum == nil then
	sFocus = "0";
	sNum, sSize, sSkill = sDicePattern:match("(%d+)d([%dF]+)x(%d+)");
	end
	
  local count = tonumber(sNum);
	Debug.console("count: ", count);
  local size = tonumber(sSize);
	Debug.console("size: ", size);
  local nAtt1 = tonumber(sAtt1);
	Debug.console("nAtt1: ", nAtt1);
  local nAtt2 = tonumber(sAtt2);
	Debug.console("nAtt2: ", nAtt2);
  local nSkill = tonumber(sSkill);
	Debug.console("nSkill: ", nSkill);
  local nDifficulty = tonumber(sDifficulty);
	Debug.console("nDifficulty: ", nDifficulty);


  while count > 0 do
    table.insert(rRoll.aDice, "d" .. sSize);
    
    -- For d100 rolls, we also need to add a d10 dice for the ones place
    if sSize == "100" then
      table.insert(rRoll.aDice, "d10");
    end
    count = count - 1;
  end
  
  rRoll.nAtt1 = nAtt1;
  rRoll.nAtt2 = nAtt2;
  rRoll.nSkill = nSkill;
  rRoll.nDifficulty = nDifficulty;
  rRoll.nTargetNumber = (nAtt1+nAtt2+nSkill)*(1+(nDifficulty/100));
  Debug.console("rRoll.nTargetNumber: ", rRoll.nTargetNumber);

  return rRoll;
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function getDiceResults(rRoll)

  nTargetNumber = tonumber(rRoll.nTargetNumber);
	Debug.console("nTargetNumber: ", nTargetNumber);

  

	
	
    for _,v in ipairs(rRoll.aDice) do
	nTotal = v.result;
	Debug.console("nTotal: ", nTotal);
	end

	if nTotal >= nTargetNumber then
		Debug.console("Failed: ", nTotal);
		sSaveResult = "Failure";
	elseif nTotal < nTargetNumber then
			Debug.console("Success: ", nTotal);
			sSaveResult = "Success";
		end


  rRoll.aTotal = nTotal;
  rRoll.nTargetNumber = nTargetNumber;
  rRoll.aSaveResult = sSaveResult;

  
	
  return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.text = rMessage.text .. "\n[Skill Check - Target " .. rRoll.nTargetNumber .. "]\n[" .. rRoll.aSaveResult .. "] " .. rRoll.aTotal;

    rMessage.dicedisplay = 1; -- display total
  
    rMessage.text = rMessage.text;

  return rMessage;

end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll a set of dice, removing a number of the lowest results.\n"; 
  rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the number of results to be dropped "; 
  rMessage.text = rMessage.text .. "by supplying the \"/rolld\" command with parameters in the format of \"#d#x#\", where the first # is the "; 
  rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
  rMessage.text = rMessage.text .. "x being the number of results to be dropped.\n"; 
  rMessage.text = rMessage.text .. "If no parameters are supplied, the default parameters of \"4d6x1\" are used."; 
  Comm.deliverChatMessage(rMessage);
end
