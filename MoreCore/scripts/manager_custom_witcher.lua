-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "witcher";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  local sOnlyDice, sMod = string.match(sDice, "([^%s]+)[-+]([%d]+)");
  Debug.console("sDice: ", sDice, " sOnlyDice: ", sOnlyDice, " sMod: ", sMod);
  if sDice == nil or not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /"..sCmd.." [dice+modifier] [description]");
    return;
  else
    local rRoll = createRoll(sDice, sDesc);
Debug.console("sDice ", sDice);
Debug.console("performAction: rRoll ", rRoll);
	rRoll.nMod = tonumber(sMod);
	if (rRoll.nMod == nil) then rRoll.nMod = 0;
	end
Debug.console("rRoll.nMod: ", rRoll.nMod, " sMod: ", sMod);
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
  local nMod = tonumber(rRoll.nMod);

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
	  Debug.console("nMyNewValue71: ", nMyNewValue, " nMyTotal: ", nMyTotal);
      if w.result == 1 then
		if nMyTotal == nil and sFirstRoll ~= "false" then
			Debug.console("74 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			j = j + 1;
			nMyNewValue = 0;
			nMyTotal = nMyNewValue;
			Debug.console("nMyNewValue78: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = true;
			sFirstRoll = "false";
		elseif nMyTotal > 9 then
			j = j + 1;
			Debug.console("84 w: ", w, " v: ", v);
		--	aRerollDice[j] = w.type;
			nMyNewValue = (w.result);
			nMyTotal = nMyTotal - nMyNewValue;
			Debug.console("nMyNewValue88: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
			sFirstRoll = "false";
		elseif nMyTotal > 0 then
			j = j + 1;
			Debug.console("93 w: ", w, " v: ", v);
		--	aRerollDice[j] = w.type;
			nMyNewValue = (w.result);
			nMyTotal = nMyTotal + nMyNewValue;
			Debug.console("nMyNewValue97: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
			sFirstRoll = "false";
		elseif nMyTotal < 0 then
			Debug.console("101 w: ", w, " v: ", v);
		--	aRerollDice[j] = w.type;
			nMyNewValue = (0 - w.result);
			nMyTotal = nMyTotal + nMyNewValue;
			Debug.console("nMyNewValue105: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
			sFirstRoll = "false";
		elseif nMyTotal == 0 and sFirstRoll == "false" then
			Debug.console("109 w: ", w, " v: ", v);
		--	aRerollDice[j] = w.type;
			nMyNewValue = (0 - w.result);
			nMyTotal = nMyTotal + nMyNewValue;
			Debug.console("nMyNewValue113: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
			sFirstRoll = "false";
		else
			Debug.console("117 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			nMyNewValue = (w.result);
			nMyTotal = nMyTotal + nMyNewValue;
			Debug.console("nMyNewValue121: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
			sFirstRoll = "false";
		end
      elseif w.result == 10 then
		if nMyTotal == nil then
			Debug.console("100 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			j = j + 1;
			nMyNewValue = w.result;
			nMyTotal = nMyNewValue;
			Debug.console("nMyNewValue105: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = true;
        elseif nMyTotal <= 1 then
			Debug.console("108 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			j = j + 1;
			nMyNewValue = (w.result);
			nMyTotal = nMyTotal - nMyNewValue;
			Debug.console("nMyNewValue113: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = true;
        else
			Debug.console("113 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			j = j + 1;
			nMyNewValue = (w.result);
			nMyTotal = nMyTotal + 10;
			Debug.console("nMyNewValue118: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = true;
		end
      else 
			j = j + 1;
		if nMyTotal == nil then
			Debug.console("97 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			nMyNewValue = (w.result);
			nMyTotal = nMyNewValue;
			Debug.console("nMyNewValue102: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
		elseif nMyTotal <= 1 then
			Debug.console("97 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			nMyNewValue = (w.result);
			nMyTotal = nMyTotal - nMyNewValue;
			Debug.console("nMyNewValue102: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
		elseif nMyTotal >= 10 then
			Debug.console("97 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			nMyNewValue = (w.result);
			nMyTotal = nMyTotal + nMyNewValue;
			Debug.console("nMyNewValue102: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
        else
			Debug.console("105 w: ", w, " v: ", v);
			aRerollDice[j] = w.type;
			nMyNewValue = (w.result);
			nMyTotal = nMyNewValue;
			Debug.console("nMyNewValue110: ", nMyNewValue, " nMyTotal: ", nMyTotal, " J: ", j);
			v.exploded = false;
		end
	  end
    end
  end
  
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

  local sStackDesc, nStackMod = ModifierStack.getStack(true);  --     Debug.console("aDice: ", aDice);
  Debug.console("nStackMod: ", nStackMod, " sStackDesc: ", sStackDesc);
  nStackMod = tonumber(nStackMod);
  Debug.console("nStackMod2: ", nStackMod);

  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";
  rMessage.dicedisplay = 0; -- don't display total

  if nMyTotal < 0 then
  rMessage.text = rMessage.text .. "\r[Fumble] " .. nMyTotal;
	end
	
  nMyNewTotal = nMyTotal + nStackMod + nMod;
  
  rMessage.text = rMessage.text .. "\r" .. sStackDesc .. " [Result] " .. nMyNewTotal;
  Comm.deliverChatMessage(rMessage);
  nMyTotal = nil;
  nMyNewValue = nil;
  sFirstRoll = nil;
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
