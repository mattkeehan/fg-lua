-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "cskill";

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
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
end


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
  local rRoll = { };
  rRoll.aDice = {"d6","d6","d6"};
  rRoll.sType = sCmd;
  rRoll.nMod = 0;
  rRoll.sDesc = "";
  rRoll.nTarget = 0;
--- rRoll.sUser = User.getUsername();

  
  local nStart, nEnd, sCharacteristic, sDescriptionParam = string.find(sParams, "([%d]+)%s*(.*)");
Debug.console("createRoll: ",nStart, nEnd, sCharacteristic, sDescriptionParam);
  if sCharacteristic then
    rRoll.nCharacteristic = tonumber(sCharacteristic);
	rRoll.nCharMod = math.floor(rRoll.nCharacteristic/5);
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
  
    rMessage.dicedisplay = 0; -- don't display total
    local nVal = rRoll.aDice[1].result + rRoll.aDice[2].result + rRoll.aDice[3].result;
	Debug.console("nVal: ",nVal);
    local nTarget = 9 + rRoll.nCharMod + rRoll.nMod;
	Debug.console("nTarget: ",nTarget);

	if nVal <= nTarget then
		sResult = "Success"
		else 
		sResult = "Failure"
		end
    rMessage.text = rMessage.text .. "\n[Characteristic] ".. rRoll.nCharacteristic .. "\n[Roll] ".. nVal .. " [Target] ".. nTarget .. " \n[Result] " .. sResult;


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
