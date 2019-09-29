-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "oladv_initiative";

-- MoreCore v0.60 
function onInit()
--  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
end




function getDieMax(sType)
Debug.console("getDieMax: ", sType);
  local sDie = string.match(sType, "d(%d+)");
  if tonumber(sDie) > 1000 then
	tempmax = tonumber(sDie);
	while tempmax > 100 do
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

function orderDiceResults(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
		Debug.console("Advantage!");
		Debug.console("Results!", rRoll.aDice);
	rRoll.aDice[1].result = rRoll.aDice[1].result + 1000;
    table.sort(rRoll.aDice, function(a,b) return a.result>b.result end)
 	rRoll.aDice[1].result = rRoll.aDice[1].result - 1000;
 
  return rRoll;
end

function onLanded(rSource, rTarget, rRoll)
  Debug.console("onLanded: ", rSource, rTarget, rRoll);
  Debug.console("Attribute: ", rRoll.sDesc);
  
  local nScore = tonumber(string.match(rRoll.sDesc, "(%d+)"));
  Debug.console("nScore: ", nScore);
  
  if nScore == 0 then nKeep = 1;
  elseif nScore > 0 and nScore < 5 then nKeep = 2;
  elseif nScore > 4 and nScore < 8 then nKeep = 3;
  elseif nScore > 7 and nScore < 10 then nKeep = 4;
  elseif nScore == 10 then nKeep = 5;
  end
   Debug.console("nKeep: ", nKeep);
 
  
  
  rRoll = orderDiceResults(rRoll);
  
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

  nNewTotal = 0;
  nCounter = 1;
  while nCounter <= nKeep do
	nNewTotal = nNewTotal + rRoll.aDice[nCounter].result;
	Debug.console("rRoll.aDice[nCounter]: ", rRoll.aDice[nCounter]);
	Debug.console("rRoll.aDice[nCounter].result: ", rRoll.aDice[nCounter].result);
	nCounter = nCounter + 1;
	end
  
  Debug.console("nNewTotal: ", nNewTotal);
  nNewTotal = nNewTotal + tonumber(rRoll.nMod);
  Debug.console("nNewTotal: ", nNewTotal);
  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  rRoll.nNewTotal = nNewTotal;
  
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = sCmd;
  Comm.deliverChatMessage(rMessage);
  return true, nNewTotal;
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
--  rRoll.nCount = 3;
--- rRoll.sUser = User.getUsername();

--Debug.console("createRoll: ",rRoll);
  
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
   rMessage.text = rMessage.text .. ", Total " .. rRoll.nNewTotal;
 
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.type = sCmd;
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.." <target> <message>\n"; 
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll 3d10, ordering the results as m, C & M. "; 
  rMessage.text = rMessage.text .. "C accepts modifiers from the Modifier box. An optional target number can be provided which will be compared to C. A double or triple 1 is a fumble and a double or triple 10 is a critical success. "; 
  rMessage.text = rMessage.text .. "The result, along with a message is output to the chat window."; 
  Comm.deliverChatMessage(rMessage);
end


function onDiceTotal( messagedata )
	local sMyTotal = string.match(messagedata.text, "Total%s(%d+)");
  Debug.console("onDiceTotal: ", sMyTotal, messagedata);
	nNewTotal = tonumber(sMyTotal);
  return true, nNewTotal;
end
