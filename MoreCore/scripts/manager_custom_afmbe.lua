-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "afmbe";

-- MoreCore v0.60 
function onInit()
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
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

  if not nTotal then nTotal = 0;
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

  if v.exploded then
      w = aDice[k]; 
      k = k + 1; -- move on to next die for next time around
      v.result = v.result + w.result;
      if w.result == 10 and nTotal == 0 then
	  Debug.chat("Ten-0");
        aRerollDice[j] = w.type;
        j = j + 1;
        v.exploded = true;
		nTotal = 10;
      elseif w.result > 1 and w.result < 10 and nTotal == 0 then
        v.exploded = false;
 		nTotal = w.result;
      elseif w.result > 1 and w.result < 10 and nTotal == 1 then
        v.exploded = false;
		if w.result > 4 then
			nTotal = nTotal;
		else 
			nTotal = (w.result -5);
			end
      elseif w.result > 1 and w.result < 10 and nTotal <= -5 then
        v.exploded = false;
		if w.result > 5 then
			nTotal = nTotal;
		else 
			nTotal = nTotal + (w.result -5);
			end
      elseif w.result == 1 and nTotal == 0 then
        aRerollDice[j] = w.type;
        j = j + 1;
        v.exploded = true;
	    nTotal = 1;
      elseif w.result == 1 and nTotal == 1 then
        aRerollDice[j] = w.type;
        j = j + 1;
        v.exploded = true;
	    nTotal = -5;
      elseif w.result == 1 and nTotal <= -5 then
        aRerollDice[j] = w.type;
        j = j + 1;
        v.exploded = true;
	    nTotal = nTotal - 5;
      elseif w.result > 1 and nTotal <= -5 then
        v.exploded = false;
		if w.result > 5 then
			nTotal = nTotal;
		else 
			nTotal = nTotal + (w.result -5);
			end
      elseif w.result < 10 and nTotal < 2 then
        v.exploded = false;
		if w.result < 5 then
			nTotal = 1;
		else 
			nTotal = nTotal + (w.result -5);
			end
      elseif w.result < 10 and nTotal > 1 then
        v.exploded = false;
		if w.result < 5 then
			nTotal = nTotal;
		else 
			nTotal = nTotal + (w.result - 5);
			end
      elseif w.result == 10 and nTotal > 2 then
	  aRerollDice[j] = w.type;
        aRerollDice[j] = w.type;
        j = j + 1;
        v.exploded = true;
		if w.result > 5 then
			nTotal = nTotal + (w.result - 5);
		else 
			nTotal = nTotal;
			end
      elseif w.result == 10 and nTotal < 2 then
	  Debug.chat("Ten-1");
        v.exploded = false;
			nTotal = nTotal;
     else
        v.exploded = false;
      end
    end
  end

  
  rRoll.aSavedDice = Json.stringify(aSavedDice);

  if #aRerollDice > 0 then
    rRoll.aDice = aRerollDice;
    ActionsManager.performAction(draginfo, rActor, rRoll);
    return;
  else
    rRoll.aDice = aSavedDice;
  end

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rMessage = createChatMessage(rSource, rRoll);

  nTotal = nTotal + rRoll.nMod;

if nTotal >= 33 then
rMessage.text = "\n" .. rMessage.text .. "\n[Godly 10, dmg +7, soc +9]";
elseif nTotal >= 30 then
rMessage.text = "\n" .. rMessage.text .. "\n[Godly 9, dmg +6, soc +8]";
elseif nTotal >= 27 then
rMessage.text = "\n" .. rMessage.text .. "\n[Godly 8, dmg +5, soc +7]";
elseif nTotal >= 24 then
rMessage.text = "\n" .. rMessage.text .. "\n[Mind Boggling 7, dmg +4, soc +6]";
elseif nTotal >= 21 then
rMessage.text = "\n" .. rMessage.text .. "\n[Extraordinary 6, dmg +3, soc +5]";
elseif nTotal >= 17 then
rMessage.text = "\n" .. rMessage.text .. "\n[Excellent 5, dmg +2, soc +4]";
elseif nTotal >= 13 then
rMessage.text = "\n" .. rMessage.text .. "\n[Good 3, soc +2]";
elseif nTotal >= 11 then
rMessage.text = "\n" .. rMessage.text .. "\n[Decent 2, soc +1]";
elseif nTotal >= 9 then
rMessage.text = "\n" .. rMessage.text .. "\n[Adequate 1]";
else
rMessage.text = "\n" .. rMessage.text .. "\n[Failure]";
end
if rTarget then
rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
end

  rMessage.text = rMessage.text .. " " .. nTotal;
  rMessage.type = sCmd;
	nTotal = nil;
  Comm.deliverChatMessage(rMessage);
end

function onDiceTotal( messagedata )
	local sMyTotal = string.match(messagedata.text, "]%s(%d+)");
  Debug.console("onDiceTotal: ", sMyTotal, messagedata);
  return true, tonumber(sMyTotal);
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
