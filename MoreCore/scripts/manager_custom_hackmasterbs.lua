-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "hackmbs";

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
--  local nMyTotal = 0;
--	Debug.console("nMyTotal 1st", nMyTotal);
  local nNewValue = 0;

  for i , v in ipairs (aSavedDice) do
    Debug.console("onLanded: last dice ", i, v);
    if v.exploded then
      w = aDice[k]; 
      k = k + 1; -- move on to next die for next time around
      v.result = v.result + w.result;
	  Debug.console("v.result: ", v.result);

	if v.type == "d20" then
      if w.result == 20 and v.type == "d20" then
        aRerollDice[j] = "d6";
        j = j + 1;
        v.exploded = true;
		rRoll.sSuccess = "Success 10";
		Debug.console("Success 10: ", rRoll.sSuccess);
			if not sDiceLanded then
				sDiceLanded = w.result;
			else
				sDiceLanded = sDiceLanded .. " " .. w.result;
			Debug.console("sDiceLanded", sDiceLanded);
			end
		nNewValue = w.result;
		nMyTotal = nMyTotal + nNewValue;
		Debug.console("nMyTotal", nMyTotal);
		sResult = "Success";

      elseif w.result == 6 and w.type == "d6" and sResult == "Success" then
        aRerollDice[j] = "d6";
        j = j + 1;
        v.exploded = true;
		rRoll.sSuccess = "Success 6";
		Debug.console("Success 6: ", rRoll.sSuccess);
			if not sDiceLanded then
				sDiceLanded = w.result;
			else
				sDiceLanded = sDiceLanded .. " " .. w.result;
			Debug.console("sDiceLanded", sDiceLanded);
			end
		nNewValue = w.result - 1;
		Debug.console("nNewValue", nNewValue);
		Debug.console("nMyTotal", nMyTotal);
		nMyTotal = nMyTotal + nNewValue;
		Debug.console("nMyTotal", nMyTotal);
		
      elseif w.result <= 5 and w.type == "d6" and sResult == "Success" then
        v.exploded = false;
		rRoll.sSuccess = "Success < 6";
		Debug.console("Success < 6: ", rRoll.sSuccess);
			if not sDiceLanded then
				sDiceLanded = w.result;
			else
				sDiceLanded = sDiceLanded .. " " .. w.result;
			Debug.console("sDiceLanded", sDiceLanded);
			end
		nNewValue = w.result - 1;
		Debug.console("nNewValue", nNewValue);
		nMyTotal = nMyTotal + nNewValue;
		Debug.console("nMyTotal", nMyTotal);
		
	else
        v.exploded = false;
		rRoll.sSuccess = "Normal roll";
		Debug.console("Final Roll: ", rRoll.sSuccess);
			if not sDiceLanded then
				sDiceLanded = w.result;
			else
				sDiceLanded = sDiceLanded .. " " .. w.result;
			Debug.console("sDiceLanded", sDiceLanded);
			end
		nMyTotal = w.result;
		Debug.console("nMyTotal", nMyTotal);

		end
	end
	Debug.console("v.result 1: ", v.result);
		end
		Debug.console("v.result 2: ", v.result);

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

	nMyTotal = nMyTotal + rRoll.nMod;
  
	if nMyTotal <= 8 then 
		sOutcome = "Fail";
	elseif nMyTotal <= 10 then 
		sOutcome = "Adequate Success";
	elseif nMyTotal <= 12 then 
		sOutcome = "Decent Success";
	elseif nMyTotal <= 14 then 
		sOutcome = "Good Success";
	elseif nMyTotal <= 16 then 
		sOutcome = "Very Good Success";
	elseif nMyTotal <= 20 then 
		sOutcome = "Excellent Success";
	elseif nMyTotal <= 23 then 
		sOutcome = "Extraordinary Success";
	else 
		sOutcome = "Mind-boggling Success";
	end

	rMessage = createChatMessage(rSource, rRoll);
	rMessage.type = "dice";
	rMessage.text = rMessage.text .. "\r[Dice] " .. sDiceLanded .. "\r[Result] " .. nMyTotal .. "\r[Outcome] " .. sOutcome;

	Comm.deliverChatMessage(rMessage);

	sDiceLanded = nil;
  
  end
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
  rRoll.nCount = 0;
  rRoll.nEachDice = 0;
  rRoll.nTotalDice = 0;
  rRoll.sSuccess = nil;
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
