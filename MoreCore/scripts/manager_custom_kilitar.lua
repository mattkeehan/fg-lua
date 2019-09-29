-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "kilitar";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");

  if sDice == nil or not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /"..sCmd.." [dice+modifier] [description]");
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
  if tonumber(sDie) == 50010 then
	tempmax = -10;
  elseif tonumber(sDie) > 1000 then
	tempmax = tonumber(sDie);
	while tempmax > 20 do
		tempmax = tempmax - 1000;
	end
	else tempmax = tonumber(sDie);
	end
  max = tempmax;
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
  
  if not nTotal then nTotal = 0;
  end
  if not nDiceTotal then nDiceTotal = 0;
  end

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

  for i , v in ipairs (aSavedDice) do
    Debug.console("onLanded: last dice ", i, v);
    if v.exploded then
      w = aDice[k]; 
      k = k + 1; -- move on to next die for next time around
      v.result = v.result + w.result;

      if w.result == getDieMax(w.type) then
        aRerollDice[j] = w.type;
        j = j + 1;
        v.exploded = true;
 		nDiceTotal = nDiceTotal + w.result;
      else
        v.exploded = false;
 		nDiceTotal = nDiceTotal + w.result;
      end
   end
  end
  Debug.console("w.result: ", w.result);
  Debug.console("nDiceTotal: ", nDiceTotal);
  
  rRoll.aSavedDice = Json.stringify(aSavedDice);

Debug.console("aRerollDice: ",#aRerollDice, aRerollDice);
  if #aRerollDice > 0 then
    rRoll.aDice = aRerollDice;
    ActionsManager.performAction(draginfo, rActor, rRoll);
    return;
  else
    rRoll.aDice = aSavedDice;
  end

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  Debug.console("rSource: ", rSource)
  Debug.console("rRoll: ", rRoll)
  Debug.console("rRoll.aSavedDice.result: ", rRoll.aSavedDice.result)
  
  local nTotal = rRoll.nMod;
  Debug.console("nTotal1: ", nTotal)
  nTotal = nTotal + nDiceTotal;
  Debug.console("nTotal2: ", nTotal)
  
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";

  if nTotal >= 50 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Epic Success] ".. nTotal;
  elseif nTotal >= 20 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Great Success] ".. nTotal;
  elseif nTotal >= 1 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Success] ".. nTotal;
  elseif nTotal == 0 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Stalemate] ".. nTotal;
  elseif nTotal >= -20 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Failure] ".. nTotal;
  elseif nTotal >= -50 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Great Failure] ".. nTotal;
  else
    rMessage.text = "\n" .. rMessage.text .. "\n[Epic Failure] ".. nTotal;
  end
  if rTarget then
    rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
  end
  
  nTotal = 0;
  nDiceTotal = 0;
  
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
  rRoll.nTarget = 0;
  rRoll.nCount = 3;
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
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.." <target> <message>\n"; 
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll 3d10, ordering the results as m, C & M. "; 
  rMessage.text = rMessage.text .. "C accepts modifiers from the Modifier box. An optional target number can be provided which will be compared to C. A double or triple 1 is a fumble and a double or triple 10 is a critical success. "; 
  rMessage.text = rMessage.text .. "The result, along with a message is output to the chat window."; 
  Comm.deliverChatMessage(rMessage);
end
