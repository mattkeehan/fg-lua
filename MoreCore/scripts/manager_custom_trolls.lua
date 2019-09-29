-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "trolls";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
--Debug.console("performAction: ", draginfo, rActor, sParams);

  if sParams == "?" or string.lower(sParams) == "help" then
    createHelpMessage();    
  else
    local rRoll = createRoll(sParams);
--Debug.console("performAction: rRoll ", rRoll);
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

  for i , v in ipairs (aSavedDice) do
    Debug.console("onLanded: last dice ", i, v);
    if v.exploded then
      w = aDice[k]; 
      k = k + 1; -- move on to next die for next time around
      v.result = v.result + w.result;
      if  w.result == aDice[(i%#aDice)+1].result or w.result == aDice[((i+(#aDice-2))%#aDice)+1].result then
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
function createRoll(sParams)
  local rRoll = { };
  rRoll.aDice = {"d6","d6"};
  rRoll.sType = sCmd;
  rRoll.nMod = 0;
  rRoll.sDesc = "";
  rRoll.nLevel = 0;
  
  local nStart, nEnd, sTarget, sDescriptionParam = string.find(sParams, "([%d]+)%s*(.*)");
  Debug.console("createRoll: ",nStart, nEnd, sTarget, sDescriptionParam);
  if sTarget then
    rRoll.nLevel = tonumber(sTarget);
    rRoll.sDesc = sDescriptionParam;
	else
		rRoll.sDesc = sParams;
  end
--Debug.console("createRoll: ",rRoll);
  
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  
    rMessage.dicedisplay = 0; -- dont display total
	local rDie1, rDie2;
	local nResult1, nResult2, nLevel;
	local nTotal;
	local nAtt=0;

    rDie1 = rRoll.aDice[1];
    nResult1 = rDie1.result;
		Debug.console("nResult1: ", nResult1);

    rDie2 = rRoll.aDice[2];
    nResult2 = rDie2.result;
		Debug.console("nResult2: ", nResult2);

    nLevel = rRoll.aDice[2];
		Debug.console("nLevel: ", nLevel);

    nTotal = nResult1+nResult2;
		Debug.console("nTotal: ", nTotal);
		
    nAtt = rRoll.nMod;
		Debug.console("nAtt: ", nAtt);
		

    rMessage.text = rMessage.text .. "\n[Target " .. rRoll.nLevel .. "*5+15-" .. nAtt .."] " .. (tonumber(rRoll.nLevel)*5)+15-nAtt;

	if nTotal == 3 then
      rMessage.text = rMessage.text .. "\nCritical Failure";
    elseif nTotal >= ((rRoll.nLevel)*5+15-nAtt) then
      rMessage.text = rMessage.text .. "\nSuccess";
    else
      rMessage.text = rMessage.text .. "\nFailure";
    end

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
