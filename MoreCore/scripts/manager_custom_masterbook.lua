-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "mbook";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  Debug.console("sDice16: ", sDice, " sDesc: ", sDesc);
  local sStackDesc, nMod = ModifierStack.getStack(true);
    local rRoll = createRoll(sDice, sDesc);
Debug.console("performAction: rRoll ", rRoll);
 rRoll.sStackDesc = sStackDesc;
 rRoll.nMod = nMod;
  Debug.console("sStackDesc: ", sStackDesc, " nMod: ", nMod);
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
  Debug.console("onLanded: ", rSource, rTarget, rRoll);
  nMod = rRoll.nMod;
  sStackDesc = rRoll.sStackDesc;
  local aDice = rRoll.aDice;
  local nDiceTotal = 0;

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
--    Debug.console("nDiceTotal: ", nDiceTotal);
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
		if nMyTotal == nil then nMyTotal = w.result;
			else nMyTotal = nMyTotal + w.result;
			end
--		Debug.console("nMyTotal: ", nMyTotal);
      else
        v.exploded = false;
		if nMyTotal == nil then nMyTotal = w.result;
			else nMyTotal = nMyTotal + w.result;
			end
--		Debug.console("nMyTotal: ", nMyTotal);
      end
    end
  end
--	Debug.chat("nMyTotal: ", nMyTotal);
  
  rRoll.aSavedDice = Json.stringify(aSavedDice);

Debug.console("aRerollDice: ",#aRerollDice, aRerollDice);
  if #aRerollDice > 0 then
    rRoll.aDice = aRerollDice;
    ActionsManager.performAction(draginfo, rActor, rRoll);
    return;
  else
    rRoll.aDice = aSavedDice;
  end
	local nSkill = rRoll.nSkill;
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	if nMyTotal <= 2 then 
		nBonus = "-10";
	elseif nMyTotal <= 3 then 
		nBonus = "-8";
	elseif nMyTotal <= 4 then 
		nBonus = "-7";
	elseif nMyTotal <= 5 then 
		nBonus = "-6";
	elseif nMyTotal <= 6 then 
		nBonus = "-5";
	elseif nMyTotal <= 7 then 
		nBonus = "-3";
	elseif nMyTotal <= 8 then 
		nBonus = "-1";
	elseif nMyTotal <= 10 then 
		nBonus = "0";
	elseif nMyTotal <= 12 then 
		nBonus = "1";
	elseif nMyTotal <= 13 then 
		nBonus = "2";
	elseif nMyTotal <= 14 then 
		nBonus = "3";
	elseif nMyTotal <= 15 then 
		nBonus = "4";
	elseif nMyTotal <= 16 then 
		nBonus = "5";
	elseif nMyTotal <= 17 then 
		nBonus = "6";
	elseif nMyTotal <= 18 then 
		nBonus = "7";
	elseif nMyTotal <= 19 then 
		nBonus = "8";
	elseif nMyTotal <= 20 then 
		nBonus = "9";
	elseif nMyTotal <= 25 then 
		nBonus = "10";
	elseif nMyTotal <= 30 then 
		nBonus = "11";
	elseif nMyTotal <= 35 then 
		nBonus = "12";
	elseif nMyTotal <= 40 then 
		nBonus = "13";
	elseif nMyTotal <= 45 then 
		nBonus = "14";
	elseif nMyTotal <= 50 then 
		nBonus = "15";
	elseif nMyTotal <= 55 then 
		nBonus = "16";
	elseif nMyTotal <= 60 then 
		nBonus = "17";
	else 
		nBonus = "18";
	end

	local nFinalResult = nSkill + nBonus + nMod;

	rMessage = createChatMessage(rSource, rRoll);
    rMessage.dicedisplay = 1; -- don't display total
  rMessage.type = "dice";
    rMessage.text = rMessage.text .. "\rSkill: " .. nSkill .. "\rModifiers: " .. sStackDesc .. "\rDice Result: " .. nMyTotal .. " Bonus: " .. nBonus .. "\rFinal Result: " .. nFinalResult;
--	onDiceTotal(nFinalResult);

	Comm.deliverChatMessage(rMessage);
  nMyTotal = nil;
  nBonus = nil;
  rRoll.nFinalResult = nFinalResult;
end

---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sDice, sDesc)
  Debug.console("sDice98: ", sDice, " sDesc: ", sDesc);
  local sDice, sSkill = sDice:match("([%d+]d[%dF]+)x(%d+)");
  Debug.console("sDice100: ", sDice, " sSkill: ", sSkill);
  local aDice, nMod = StringManager.convertStringToDice(sDice);
  Debug.console("aDice102: ", aDice, " nMod: ", nMod);
  local rRoll = { };
  rRoll.aDice = aDice;
  rRoll.sType = sCmd;
  rRoll.nMod = nMod;
  rRoll.sDesc = sDesc;
  rRoll.nTarget = 0;
  rRoll.nSkill = tonumber(sSkill);
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

function onDiceTotal(aMessage)
	Debug.chat("Boo!");
	return true, (rRoll.nFinalResult);
end
