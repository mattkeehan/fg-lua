-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "srun4";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sLimit, sDesc = string.match(sParams, "(%d+d6)x(%d+)%s*(.*)");

  Debug.console("sDice: ", sDice, " sLimit: ", sLimit, " sDesc: ", sDesc);

  if sDice == nil or not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /"..sCmd.." [dicexlimit] [description]");
    return;
  else
  local sDesc = sLimit .. " " .. sDesc;
	Debug.console("performAction: rRoll ", rRoll, " sDesc: ", sDesc);
    local rRoll = createRoll(sDice, sDesc);
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
  if not nSuccesses then nSuccesses = 0;
  end
  if not nFails then nFails = 0;
  end
	local sLimit = rRoll.sLimit;
  if not sLimit then sLimit = nil;
  end
  if sLimit == "0" then sLimit = "None";
  end
	Debug.console("nSuccesses: ", nSuccesses, " nFails: ", nFails, " sLimit: ", sLimit);
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
		nSuccesses = nSuccesses + 1;
        v.exploded = true;
      elseif w.result == 5 then
		nSuccesses = nSuccesses + 1;
        v.exploded = false;
      elseif w.result == 1 and v.result == 1 then
			nFails = nFails + 1;
        v.exploded = false;
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

	rRoll.nFails = nFails;
	rRoll.nSuccesses = nSuccesses;
	rRoll.sLimit = sLimit;
	Debug.console("nSuccesses1: ", nSuccesses, " nFails1: ", nFails, " sLimit1: ", sLimit);
	
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";
  rMessage.text = rMessage.text .. "\nSuccesses: " .. rRoll.nSuccesses .. "\n[Success Limit: " .. rRoll.sLimit .. "]" .. "\nFails: " .. rRoll.nFails;
  Comm.deliverChatMessage(rMessage);
  
  nSuccesses = nil;
  nFails = nil;
end


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sDice, sDesc)
  local aDice, nMod = StringManager.convertStringToDice(sDice);

local sModDesc, nMod = ModifierStack.getStack(true);

local sLimit, sDesc = string.match(sDesc, "([^%s])%s*(.*)");

Debug.console("sLimit: ",sLimit, "sDesc: ",sDesc);

	local rRoll = { };
  rRoll.aDice = aDice;
  Debug.console("aDice: ", aDice);
  rRoll.sType = sCmd;
  rRoll.nMod = nMod;
  rRoll.sDesc = sDesc .. " " .. sModDesc;
  rRoll.sLimit = sLimit;

--Debug.console("createRoll: ",rRoll);
	local count = nMod;
	  while count > 0 do
		table.insert(rRoll.aDice, "d6");
		count = count - 1;
	  end
 
 
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 0; -- don't display total

  
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
