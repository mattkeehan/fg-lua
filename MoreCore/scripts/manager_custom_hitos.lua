-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "hitos";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
  
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

function orderDiceResults(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
    table.sort(rRoll.aDice, function(a,b) return a.result<b.result end)
  
  return rRoll;
end



function onLanded(rSource, rTarget, rRoll)
--Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rRoll = orderDiceResults(rRoll);
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = sCmd;
  Comm.deliverChatMessage(rMessage);
end

function onDiceTotal( messagedata )
  Debug.console("onDiceTotal: ", messagedata);
  return true, messagedata.dice[2].result;
end

---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
  local rRoll = { };
  rRoll.aDice = {"d10","d10","d10"};
  rRoll.sType = sCmd;
  rRoll.nMod = 0;
  rRoll.sDesc = "";
  rRoll.nTarget = 0;
--- rRoll.sUser = User.getUsername();

  
  local nStart, nEnd, sTarget, sDescriptionParam = string.find(sParams, "([%d]+)%s*(.*)");
--Debug.console("createRoll: ",nStart, nEnd, sTarget, sDescriptionParam);
  if sTarget then
    rRoll.nTarget = tonumber(sTarget);
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
  
    rMessage.dicedisplay = 1; -- display total
    local nVal = rRoll.aDice[2].result + rRoll.nMod;
    if rRoll.aDice[1].result == 1 and rRoll.aDice[2].result == 1 then
      if rRoll.aDice[3].result == 1 then
        rMessage.text = rMessage.text .. "\nFUMBLE!";
      else
        rMessage.text = rMessage.text .. "\nFumble!";
      end
    end
    if rRoll.aDice[3].result == 10 and rRoll.aDice[2].result == 10 then
      if rRoll.aDice[1].result == 10 then
        rMessage.text = rMessage.text .. "\nCRITICAL!";
      else
        rMessage.text = rMessage.text .. "\nCritical!";
      end
    end
    rMessage.text = rMessage.text .. "\n[Result] "..nVal.." [Target] "..rRoll.nTarget;

    if nVal >= tonumber(rRoll.nTarget) then
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
