-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "cod";

-- MoreCore v0.60 
function onInit()
--  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local nReroll, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  --     Debug.console("sDesc: ", sDesc , " nReroll: ", nReroll);
  local sStackDesc, nStackMod = ModifierStack.getStack(true);  --     Debug.console("aDice: ", aDice);
  --     Debug.console("nStackMod: ", nStackMod);
  --     Debug.console("sStackDesc: ", sStackDesc);
  nStackMod = tonumber(nStackMod);
  --     Debug.console("nStackMod: ", nStackMod);
  if nStackMod > 1 then 
	--     Debug.console("if = true");
	--     Debug.console("nStackMod: ", nStackMod);
	sDice = nStackMod .. "d10";
	--     Debug.console(sDice);
	else
	--     Debug.console("if not true");
	sDice = "1d10010";
	end
	--     Debug.console(sDice);
  --     Debug.console("sDice: ", sDice);
  
  local rRoll = createRoll(sDice, sDesc);
  --     Debug.console("rRoll35: ", rRoll);
--	local nSuccess = 0;
Debug.console("performAction: rRoll ", rRoll);
	rRoll.nReroll = nReroll;
	rRoll.nStackMod = nStackMod;
--	rRoll.nSuccess = nSuccess;
--	     Debug.console("40: ", rRoll.nReroll, nSuccess);
    ActionsManager.performAction(draginfo, rActor, rRoll);
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
  Debug.console("onLanded57: ", rSource, rTarget, rRoll);
  --     Debug.console("61: ", rRoll.nReroll);
  local aDice = rRoll.aDice;
  local nReroll = tonumber(rRoll.nReroll);
  local nStackMod = tonumber(rRoll.nStackMod);
  local nSuccessBase = 0; 
    Debug.console("65 ", nReroll, nSuccess);
  Debug.console("nStackMod68: ", nStackMod);

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
	  --     Debug.console("82: ", nReroll);
      if nStackMod > 1 then
		  if w.result >= nReroll then
			aRerollDice[j] = w.type;
			j = j + 1;
			v.exploded = true;
			Debug.console("93 ", nSuccess);
			if not nSuccess then nSuccess = 0;
			end
			Debug.console("96 ", nSuccess);
			nSuccess = nSuccess + 1;
		  elseif w.result >= 8 and w.result < nReroll then
			if not nSuccess then nSuccess = 0;
			end
			v.exploded = false;
			nSuccess = nSuccess + 1;
		  else
			v.exploded = false;
		  end
	  else
		  if w.result == 10 then
			aRerollDice[j] = w.type;
			j = j + 1;
			v.exploded = true;
			Debug.console("93 ", nSuccess);
			if not nSuccess then nSuccess = 0;
			end
			Debug.console("96 ", nSuccess);
			nSuccess = nSuccess + 1;
		  elseif w.result == 1 then
			if nSuccess == 0 then
				nSuccess = nSuccess - 1;
			end
			v.exploded = false;
		  else
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

 if not nSuccess then nSuccess = 0;
 end

 

  Debug.console("nStackMod120: ", nStackMod);

      if nStackMod > 1 then
		  if nSuccess >= 5 then
			sSuccessMsg = "Exceptional Success. You have rolled " .. nSuccess .. " successes.";
		  elseif nSuccess >= 1 then
			sSuccessMsg = "Success. You have rolled " .. nSuccess .. " successes.";
			else sSuccessMsg = "Failure.";
			end
	else
		  if nSuccess >= 5 then
			sSuccessMsg = "Exceptional Success. You have rolled " .. nSuccess .. " successes.";
		  elseif nSuccess >= 1 then
			sSuccessMsg = "Success. You have rolled " .. nSuccess .. " successes.";
		  elseif nSuccess < 0 then
			sSuccessMsg = "Dramatic Failure!";
			else sSuccessMsg = "Failure.";
			end
	end
			
	local nSuccessValue = nSuccess;
	nSuccess = 0;
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Debug.console("nSuccess107: ", nSuccess);
  rMessage = createChatMessage(rSource, rRoll);
--  rMessage.type = "dice";
  rMessage.type = sCmd;
  rMessage.nSuccessValue = nSuccessValue;
	Debug.console("nSuccessValue: ", nSuccessValue);
	rMessage.text = rMessage.text .. "\r" .. sSuccessMsg;
	Debug.console("rMessage: ", rMessage);
  Comm.deliverChatMessage(rMessage);
  nMod = nil;
end

function onDiceTotal( messagedata )
	local nSuccessValue = string.match(messagedata.text, "%d+");
  Debug.console("onDiceTotal: ", nSuccessValue, messagedata);
  return true, nSuccessValue;
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
  rRoll.nReroll = nReroll;
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
