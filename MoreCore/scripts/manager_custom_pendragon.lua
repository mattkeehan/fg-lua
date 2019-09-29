-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
local sCmd = "pendragon";
function onInit()
 CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end
function performAction(draginfo, rActor, sParams)
 if not sParams or sParams == "" then 
  createHelpMessage();
  return;
 end
 if sParams == "?" or string.lower(sParams) == "help" then
  createHelpMessage();    
 else
  local rRoll = createRoll(sParams);
  ActionsManager.performAction(draginfo, rActor, rRoll);
 end
end
function onLanded(rSource, rTarget, rRoll)
 local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
 local xMod = math.max(rRoll.nTarget + rRoll.nMod - 20, 0);
 local xTarget = math.max(math.min(rRoll.nTarget + rRoll.nMod, 20),0); 
 rRoll.nMod = xMod;
 rRoll.nTarget = xTarget;
 rMessage = createChatMessage(rSource, rRoll);
 rMessage.type = "dice";
 Comm.deliverChatMessage(rMessage);
end
  
---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
 local rRoll = {};
 rRoll.sType = sCmd;
 rRoll.nMod = 0;
 rRoll.aDice = { "d20" };
 rRoll.nTarget = 0;
 local nStart, nEnd, sTarget, sDescriptionParam = string.find(sParams, "([%d]+)%s*(.*)");
 if sTarget then
    rRoll.nTarget = tonumber(sTarget);
    rRoll.sDesc = sDescriptionParam;
 else
  rRoll.sDesc = sParams;
 end 
 return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
 local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
 local sResult;
 local nTotal = ActionsManager.total(rRoll);
 
 if nTotal > 19 then
  if rRoll.nTarget > 19 then
   sResult = "CRITICAL";
  else
   sResult = "FUMBLE";
  end    
 else
  if nTotal > rRoll.nTarget then
   sResult = "FAIL";
  else
   if nTotal == rRoll.nTarget then
    sResult = "CRITICAL";
   else
    sResult = "SUCCESS";
   end
  end      
 end
 if nTotal > 20 then
  rMessage.text = rMessage.text .. "\n[Target " .. rRoll.nTarget .. "] " .. "\n[" .. sResult .. "] " .. nTotal .. " --> 20";
 else
  if sResult == "CRITICAL" then
   rMessage.text = rMessage.text .. "\n[Target " .. rRoll.nTarget .. "] " .. "\n[" .. sResult .. "] " .. nTotal .. " --> 20";
  else
   rMessage.text = rMessage.text .. "\n[Target " .. rRoll.nTarget .. "] " .. "\n[" .. sResult .. "] " .. nTotal;
  end
 end
 return rMessage;
end
---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.." <target>\n"; 
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll 1d20, comparing the result to the specified target value. "; 
  rMessage.text = rMessage.text .. "The roll accepts modifiers from the Modifier box which are added to or subtracted from the target value. For a value greater than 20, the target is deemed to be 20 and the excess greater than 20 is added to the die roll. "; 
  rMessage.text = rMessage.text .. "A roll less than the target value is a success, greater than the target value is a failure. A roll exactly equal to the target value is a critical success. A fumble occurs on a roll of 20 unless the target value is 20, in which case there is no chance to fumble. "
  rMessage.text = rMessage.text .. "The result, along with a message is output to the chat window."; 
  Comm.deliverChatMessage(rMessage);
end