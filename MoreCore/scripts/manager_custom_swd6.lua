-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "swd6"
function onInit()
  CustomDiceManager.add_roll_type("swd6", performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
Debug.console("who am i?: ", rActor.sCreatureNode);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  if sDice == nil then
    ChatManager.SystemMessage("Usage: /swd6 [dice+modifier] [description]");
    return;
  else
    sDice = sDice;
  end

  if not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /swd6 [dice+modifier] [description]");
    return;
  end
  
  local aDice, nMod = StringManager.convertStringToDice(sDice);
--  Debug.chat("sDice: ", sDice, " aDice: ", aDice, " nMod: ", nMod);
  local sSign, nDice = string.match(sDice, "^([%-%+]?)(%d)");
--  Debug.chat("sSign: ", sSign, "nDice: ", nDice);
  if sSign == "-" then nDice = 0-nDice; end
--  Debug.chat("nDice: ", nDice);
  
  
  local rNode = rActor.sCreatureNode;
--  Debug.chat("rNode: ", rNode);
  DB.setValue(rNode .. ".roll_dice", "number", DB.getValue(rNode .. ".roll_dice", "number") + nDice);
  
--  Debug.chat("Sum: ", DB.getValue(rNode .. ".roll_dice", "number"));
  
  DB.setValue(rNode .. ".roll_bonus", "number", DB.getValue(rNode .. ".roll_bonus", "number") + nMod);
  DB.setValue(rNode .. ".roll_desc", "string", DB.getValue(rNode .. ".roll_desc", "string") .. ", " .. sDesc);
    
 return;
 
end   


function onLanded(rSource, rTarget, rRoll)
Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  local bIsSourcePC = (rSource and rSource.sType == "pc");

  local nTotal = rRoll.nMod;
  Debug.console("nTotal: ", nTotal);
  for k,v in pairs(rRoll.aDice) do
    nTotal = nTotal + v.result;
  end

  
-- set Init Value

local sMyNode = rRoll.sWho..".initresult";
							DB.setValue(sMyNode, "number", nTotal );
							
							
  Comm.deliverChatMessage(rMessage);
end


