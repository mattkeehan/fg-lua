-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "torgbd";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
   if sParams == "?" or string.lower(sParams) == "help" then
	createHelpMessage();	
	return;
  end
  
  Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDiceCount, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  
  if sDiceCount == nil then 
	sDiceCount = 1;
  elseif string.match(sDiceCount, "(%d+)") == nil then
	sDiceCount = 1;
	sDesc = sParams;
  end
  
  local sDice = sDiceCount.."d6";
  if sDice == nil or not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /"..sCmd.." [#] [message]. '/"..sCmd.." ?' for details." );
    return;
  else
    local rRoll = createRoll(sDice, sDesc);
Debug.console("performAction: rRoll ", rRoll);
    ActionsManager.performAction(draginfo, rActor, rRoll); 
  end   
end

function getDieMax(sType)
Debug.console("getDieMax: ", sType);
  local sDie = string.match(sType, "d(%d+)");
  max = tonumber(sDie);
  return max;  
end

function initLastDice(aDice)
  aSavedDice = {};
  for i , v in ipairs (aDice) do
    aSavedDice[i] = { type=v.type, result=0, exploded=true };
  end
  return aSavedDice;
end

function onLanded(rSource, rTarget, rRoll)
  Debug.console("onLanded: ", rSource, rTarget, rRoll);
  
  local aDice = rRoll.aDice;

  -- get saved dice
  local aSavedDice = nil;
  if rRoll.aSavedDice then
    aSavedDice = Json.parse(rRoll.aSavedDice);
  else
    aSavedDice = initLastDice(aDice);
  end

  local aRerollDice = {};
  local j = 1; -- reRoll dice index
  local k = 1; -- aDice index
  
  local nTotal = 0;

  for i , v in ipairs (aSavedDice) do
    Debug.console("onLanded: last dice ", i, v);
    if v.exploded then
      w = aDice[k]; 
      k = k + 1; -- move on to next die for next time around
      if w.result == getDieMax(w.type) then
        aRerollDice[j] = w.type;

        j = j + 1;
        v.exploded = true;
		v.result = v.result + (w.result - 1);
      else
        v.exploded = false;
		v.result = v.result + w.result;
      end
    end
	nTotal = nTotal + v.result;
  end
  
  rRoll.aSavedDice = Json.stringify(aSavedDice);
--  Debug.chat("rRoll.aSavedDice: ", rRoll.aSavedDice);

Debug.console("aRerollDice: ",#aRerollDice, aRerollDice);
  if #aRerollDice > 0 then
    rRoll.aDice = aRerollDice;
    ActionsManager.performAction(draginfo, rActor, rRoll);
    return;
  else
    rRoll.aDice = aSavedDice;
  end

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  rMessage = createChatMessage(rSource, rRoll);

  rMessage.type = "damage";

--  Debug.chat("nMod: ", rRoll.nMod);
  
--  Debug.chat("nFirstDice: ", nFirstDice);
--  Debug.chat("nTotal: ", nTotal);
--  Debug.chat("rMessage: ", rMessage);
  
     rMessage.text = rMessage.text .. "\nBonus Dice ".. nTotal;

    -- rMessage.dicedisplay = 0; -- don't display total
	Comm.deliverChatMessage(rMessage);
end


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sDice, sDesc)
  local aDice, nMod = StringManager.convertStringToDice(sDice);

  local rRoll = { };
  rRoll.aDice = aDice;
  rRoll.sType = sCmd;
  rRoll.nMod = nMod;
  rRoll.sDesc = sDesc;
--- rRoll.sUser = User.getUsername();

--Debug.console("createRoll: ",rRoll);
  
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.." <#> <message>\n"; 
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll <#>d6, where a roll of 6 adds 5 to the total and is rerolled until a result other than 6 is rolled. The # can be ommitted, defaulting to 1d6."; 
  rMessage.text = rMessage.text .. "The result, along with an optional message is output to the chat window."; 
  Comm.deliverChatMessage(rMessage);
end
