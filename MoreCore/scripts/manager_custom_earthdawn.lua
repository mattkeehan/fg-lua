-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "earthdawn";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  
-- Earthdawn Dice Step System
	sStep = sDice .. "+0+0+0+0+0+0"
	_, _, v1, v2, v3, v4, v5 = string.find(sStep, "(%d+)+(%d+)+(%d+)+(%d+)+(%d+)")
	sStep = v1 + v2 + v3 + v4 + v5
	sStep = tostring(sStep)
  
  if sStep == "1" then sDice = "1d4-2" 
  elseif sStep == "2" then sDice = "1d4-1"
  elseif sStep == "3" then sDice = "1d4"
  elseif sStep == "4" then sDice = "1d6"
  elseif sStep == "5" then sDice = "1d8"
  elseif sStep == "6" then sDice = "1d10"
  elseif sStep == "7" then sDice = "1d12"
  elseif sStep == "8" then sDice = "2d6"
  elseif sStep == "9" then sDice = "1d8+1d6"
  elseif sStep == "10" then sDice = "2d8"
  elseif sStep == "11" then sDice = "1d10+1d8"
  elseif sStep == "12" then sDice = "2d10"
  elseif sStep == "13" then sDice = "1d12+1d10"
  elseif sStep == "14" then sDice = "2d12"
  elseif sStep == "15" then sDice = "1d12+2d6"
  elseif sStep == "16" then sDice = "1d12+1d8+1d6"
  elseif sStep == "17" then sDice = "1d12+2d8"
  elseif sStep == "18" then sDice = "1d12+1d10+1d8"
  elseif sStep == "19" then sDice = "1d20+2d6"
  elseif sStep == "20" then sDice = "1d20+1d8+1d6"
  elseif sStep == "21" then sDice = "1d20+2d8"
  elseif sStep == "22" then sDice = "1d20+1d10+1d8"
  elseif sStep == "23" then sDice = "1d20+2d10"
  elseif sStep == "24" then sDice = "1d20+1d12+1d10"
  elseif sStep == "25" then sDice = "1d20+2d12"
  elseif sStep == "26" then sDice = "1d20+1d12+2d6"
  elseif sStep == "27" then sDice = "1d20+1d12+1d8+1d6"
  elseif sStep == "28" then sDice = "1d20+1d12+2d8"
  elseif sStep == "29" then sDice = "1d20+1d12+1d10+1d8"
  elseif sStep == "30" then sDice = "2d20+2d6"
  elseif sStep == "31" then sDice = "2d20+1d8+1d6"
  elseif sStep == "32" then sDice = "2d20+2d8"
  elseif sStep == "33" then sDice = "2d20+1d10+1d8"
  elseif sStep == "34" then sDice = "2d20+2d10"
  elseif sStep == "35" then sDice = "2d20+1d12+1d10"
  elseif sStep == "36" then sDice = "2d20+2d12"
  elseif sStep == "37" then sDice = "2d20+1d12+2d6"
  elseif sStep == "38" then sDice = "2d20+1d12+1d8+1d6"
  elseif sStep == "39" then sDice = "2d20+1d12+2d8"
  elseif sStep == "40" then sDice = "2d20+1d12+1d10+1d8"
  elseif sStep == "41" then sDice = "3d20+2d6"
  elseif sStep == "42" then sDice = "3d20+1d8+1d6"
  elseif sStep == "43" then sDice = "3d20+2d8"
  elseif sStep == "44" then sDice = "3d20+1d10+1d8"
  elseif sStep == "45" then sDice = "3d20+2d10"
  elseif sStep == "46" then sDice = "3d20+1d12+1d10"
  elseif sStep == "47" then sDice = "3d20+2d12"
  elseif sStep == "48" then sDice = "3d20+1d12+2d6"
  elseif sStep == "49" then sDice = "3d20+1d12+1d8+1d6"
  elseif sStep == "50" then sDice = "3d20+1d12+2d8"
  elseif sStep == "51" then sDice = "3d20+1d12+1d10+1d8"
  elseif sStep == "52" then sDice = "4d20+2d6"
  elseif sStep == "53" then sDice = "4d20+1d8+1d6"
  elseif sStep == "54" then sDice = "4d20+2d8"
  elseif sStep == "55" then sDice = "4d20+1d10+1d8"
  elseif sStep == "56" then sDice = "4d20+2d10"
  elseif sStep == "57" then sDice = "4d20+1d12+1d10"
  elseif sStep == "58" then sDice = "4d20+2d12"
  elseif sStep == "59" then sDice = "4d20+1d12+2d6"
  elseif sStep == "60" then sDice = "4d20+1d12+1d8+1d6"
  elseif sStep == "61" then sDice = "4d20+1d12+2d8"
  elseif sStep == "62" then sDice = "4d20+1d12+1d10+1d8"
  elseif sStep == "63" then sDice = "5d20+2d6"
  elseif sStep == "64" then sDice = "5d20+1d8+1d6"
  elseif sStep == "65" then sDice = "5d20+2d8"
  elseif sStep == "66" then sDice = "5d20+1d10+1d8"

  end

  if sDice == nil or not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /"..sCmd.." [step] [description]");
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
  if tonumber(sDie) > 1000 then
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
      else
        v.exploded = false;
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

  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";
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
  rRoll.sDesc = sDesc .. " (Step " .. sStep .. ")";
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
