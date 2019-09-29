-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "wegattack";

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

function orderDiceResults(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
    table.sort(rRoll.aDice, function(a,b) return a.result<b.result end)
  
  return rRoll;
end

function onLanded(rSource, rTarget, rRoll)
  Debug.console("onLanded: ", rSource, rTarget, rRoll);
	local sDesc, nMod = ModifierStack.getStack(true);
  
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
--	Debug.console("aSavedDice: ", aSavedDice);
--	Debug.console("Result 1: ", rRoll.aDice[1].result);
--	Debug.console("Result 2: ", rRoll.aDice[2].result);
--	Debug.console("Result 3: ", rRoll.aDice[3].result);


			
	  local nTotal = 0;
	if rRoll.aDice[1].result == 1 then
	  local count = 0;
	  for i,v in ipairs (rRoll.aDice) do
		count = count + 1;
		Debug.console("Count1: ", count);
		nTotal = nTotal + rRoll.aDice[count].result;
		Debug.console("nTotal: ", nTotal);
		end
		Debug.console("Count: ", count);
		table.sort(rRoll.aDice, function(a,b) return a.result < b.result end);
		
		sMessage = "Blunder! Result ";
		Debug.console("sMessage: ", sMessage);
		nBlunder = rRoll.aDice[count].result + 1;
		Debug.console("nBlunder: ", nBlunder);
		nTotal = nTotal - nBlunder;
		Debug.console("nTotal Blunder: ", nTotal);
		end;
	if rRoll.aDice[1].result > 1 then
	  local count = 0;
	  for i,v in ipairs (rRoll.aDice) do
		count = count + 1;
		Debug.console("Count1: ", count);
		nTotal = nTotal + rRoll.aDice[count].result;
		Debug.console("nTotal: ", nTotal);
		
		sMessage = "Result ";
		end
		end
		Debug.console("Count2: ", count);

		nWEGResult = nTotal + rRoll.nMod;
		sMessage1 = sMessage .. nWEGResult;
--		Debug.console("sMessage1: ", sMessage1);
	
  end

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  rMessage = createChatMessage(rSource, rRoll);
  rMessage.dicedisplay = 0; -- don't display total
  rMessage.type = "dice";
  rMessage.text = rMessage.text .. " - ".. sMessage1;
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
