-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "torg20";

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
      v.result = v.result + w.result;
      if w.result == getDieMax(w.type) then
        aRerollDice[j] = w.type;

        j = j + 1;
        v.exploded = true;
      elseif w.result == 10 then
        aRerollDice[j] = w.type;

        j = j + 1;
        v.exploded = true;
      else
        v.exploded = false;
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

  rMessage.type = "dice";

--  Debug.chat("nMod: ", rRoll.nMod);
  
  local nFirstDice = rRoll.aDice[1].result;
--  Debug.chat("nFirstDice: ", nFirstDice);
--  Debug.chat("nTotal: ", nTotal);
--  Debug.chat("rMessage: ", rMessage);
  
  local nBonus = 0;
  
  if nTotal >= 61 then
    nBonus = 16;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +15";
  elseif nTotal >= 56 then
    nBonus = 15;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +15";
  elseif nTotal >= 51 then
    nBonus = 14;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +14";
  elseif nTotal >= 46 then
    nBonus = 13;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +13";
  elseif nTotal >= 41 then
    nBonus = 12;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +12";
  elseif nTotal >= 36 then
    nBonus = 11;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +11";
  elseif nTotal >= 31 then
    nBonus = 10;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +10";
  elseif nTotal >= 26 then
    nBonus = 9;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +9";
  elseif nTotal >= 21 then
    nBonus = 8;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +8";
  elseif nTotal >= 20 then
    nBonus = 7;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +7";
  elseif nTotal >= 19 then
    nBonus = 6;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +6";
  elseif nTotal >= 18 then
    nBonus = 5;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +5";
  elseif nTotal >= 17 then
     nBonus = 4;
--	Debug.chat("nBonus: ", nBonus);
   rMessage.text = rMessage.text .. "\nBonus +4";
  elseif nTotal >= 16 then
    nBonus = 3;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +3";
  elseif nTotal >= 15 then
    nBonus = 2;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +2";
  elseif nTotal >= 13 then
    nBonus = 1;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +1";
  elseif nTotal >= 11 then
    nBonus = 0;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\n No Bonus";
  elseif nTotal >= 9 then
    nBonus = -1;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -1";
  elseif nTotal >= 7 then
    nBonus = -2;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -2";
  elseif nTotal >= 5 then
    nBonus = -4;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -4";
  elseif nTotal >= 4 then
    nBonus = -4;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -4 \nPossible Mishap";
  elseif nTotal >= 3 then
    nBonus = -6;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -6 \nPossible Mishap";
  elseif nTotal >= 2 then
    nBonus = -8;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -8 \nPossible Mishap";
  else
    nBonus = -10;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -10";
  end
  if nFirstDice == 1 then
    rMessage.text = rMessage.text .. "\nCritical Failure";
  end
  if rTarget then
    rMessage.text = rMessage.text .. "\nvs ".. rTarget.sName;
  end

	 local nCheck = nBonus + rRoll.nMod;
     rMessage.text = rMessage.text .. "\nCheck Result ".. nCheck;

    rMessage.dicedisplay = 0; -- don't display total
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
