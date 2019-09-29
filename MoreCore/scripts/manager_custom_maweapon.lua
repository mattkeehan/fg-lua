---
--- Initialization
---

local sCmd = "maweapon";

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
		Debug.console("performAction: rRoll ", rRoll);
    ActionsManager.performAction(draginfo, rActor, rRoll);
  end   

end

function getMAweaponDice(rRoll)


rDie1 = rRoll.aDice[1];
nResult1 = rDie1.result;
		Debug.console("nResult1: ", nResult1);
		Debug.console("rRoll.nMod: ", rRoll.nMod);

        if rRoll.nMod == 1 then
        
            if rRoll.aDice[1].result >= 18 then
                rRoll.sMessage = "You hit AC 1 and higher.";
                elseif rRoll.aDice[1].result >= 17 then
                rRoll.sMessage = "You hit AC 2 and higher.";
                elseif rRoll.aDice[1].result >= 16 then
                rRoll.sMessage = "You hit AC 3 and higher.";
                elseif rRoll.aDice[1].result >= 15 then
                rRoll.sMessage = "You hit AC 4 and higher.";
                elseif rRoll.aDice[1].result >= 13 then
                rRoll.sMessage = "You hit AC 5 and higher.";
                elseif rRoll.aDice[1].result >= 11 then
                rRoll.sMessage = "You hit AC 6 and higher.";
                elseif rRoll.aDice[1].result >= 9 then
                rRoll.sMessage = "You hit AC 7 and higher.";
                elseif rRoll.aDice[1].result >= 7 then
                rRoll.sMessage = "You hit AC 8 only.";
                else
                rRoll.sMessage = "You miss.";
                end

			elseif rRoll.nMod == 2 then
            if rRoll.aDice[1].result >= 17 then
                rRoll.sMessage = "You hit AC 1 and higher.";
                elseif rRoll.aDice[1].result >= 16 then
                rRoll.sMessage = "You hit AC 2 and higher.";
                elseif rRoll.aDice[1].result >= 15 then
                rRoll.sMessage = "You hit AC 3 and higher.";
                elseif rRoll.aDice[1].result >= 14 then
                rRoll.sMessage = "You hit AC 4 and higher.";
                elseif rRoll.aDice[1].result >= 11 then
                rRoll.sMessage = "You hit AC 5 and higher.";
                elseif rRoll.aDice[1].result >= 10 then
                rRoll.sMessage = "You hit AC 6 and higher.";
                elseif rRoll.aDice[1].result >= 8 then
                rRoll.sMessage = "You hit AC 7 and higher.";
                elseif rRoll.aDice[1].result >= 6 then
                rRoll.sMessage = "You hit AC 8 only.";
                else
                rRoll.sMessage = "You miss.";
                end

			elseif rRoll.nMod == 3 then
            if rRoll.aDice[1].result >= 16 then
                rRoll.sMessage = "You hit AC 1 and higher.";
                elseif rRoll.aDice[1].result >= 15 then
                rRoll.sMessage = "You hit AC 2 and higher.";
                elseif rRoll.aDice[1].result >= 14 then
                rRoll.sMessage = "You hit AC 3 and higher.";
                elseif rRoll.aDice[1].result >= 13 then
                rRoll.sMessage = "You hit AC 4 and higher.";
                elseif rRoll.aDice[1].result >= 12 then
                rRoll.sMessage = "You hit AC 5 and higher.";
                elseif rRoll.aDice[1].result >= 9 then
                rRoll.sMessage = "You hit AC 6 and higher.";
                elseif rRoll.aDice[1].result >= 7 then
                rRoll.sMessage = "You hit AC 7 and higher.";
                elseif rRoll.aDice[1].result >= 5 then
                rRoll.sMessage = "You hit AC 8 only.";
                else
                rRoll.sMessage = "You miss.";
                end

			elseif rRoll.nMod == 4 then
            if rRoll.aDice[1].result >= 18 then
                rRoll.sMessage = "You hit AC 1 and higher.";
                elseif rRoll.aDice[1].result >= 17 then
                rRoll.sMessage = "You hit AC 2 and higher.";
                elseif rRoll.aDice[1].result >= 16 then
                rRoll.sMessage = "You hit AC 3 and higher.";
                elseif rRoll.aDice[1].result >= 14 then
                rRoll.sMessage = "You hit AC 4 and higher.";
                elseif rRoll.aDice[1].result >= 13 then
                rRoll.sMessage = "You hit AC 5 and higher.";
                elseif rRoll.aDice[1].result >= 11 then
                rRoll.sMessage = "You hit AC 6 and higher.";
                elseif rRoll.aDice[1].result >= 8 then
                rRoll.sMessage = "You hit AC 7 and higher.";
                elseif rRoll.aDice[1].result >= 6 then
                rRoll.sMessage = "You hit AC 8 only.";
                else
                rRoll.sMessage = "You miss.";
                end

			elseif rRoll.nMod == 5 then
            if rRoll.aDice[1].result >= 14 then
                rRoll.sMessage = "You hit AC 1 and higher.";
                elseif rRoll.aDice[1].result >= 13 then
                rRoll.sMessage = "You hit AC 3 and higher.";
                elseif rRoll.aDice[1].result >= 12 then
                rRoll.sMessage = "You hit AC 4 and higher.";
                elseif rRoll.aDice[1].result >= 11 then
                rRoll.sMessage = "You hit AC 5 and higher.";
                elseif rRoll.aDice[1].result >= 8 then
                rRoll.sMessage = "You hit AC 6 and higher.";
                elseif rRoll.aDice[1].result >= 6 then
                rRoll.sMessage = "You hit AC 7 and higher.";
                elseif rRoll.aDice[1].result >= 4 then
                rRoll.sMessage = "You hit AC 8 only.";
                else
                rRoll.sMessage = "You miss.";
                end

			elseif rRoll.nMod == 6 then
            if rRoll.aDice[1].result >= 18 then
                rRoll.sMessage = "You hit AC 1 and higher.";
                elseif rRoll.aDice[1].result >= 16 then
                rRoll.sMessage = "You hit AC 2 and higher.";
                elseif rRoll.aDice[1].result >= 15 then
                rRoll.sMessage = "You hit AC 3 and higher.";
                elseif rRoll.aDice[1].result >= 10 then
                rRoll.sMessage = "You hit AC 4 and higher.";
                elseif rRoll.aDice[1].result >= 9 then
                rRoll.sMessage = "You hit AC 5 and higher.";
                elseif rRoll.aDice[1].result >= 8 then
                rRoll.sMessage = "You hit AC 6 and higher.";
                elseif rRoll.aDice[1].result >= 7 then
                rRoll.sMessage = "You hit AC 7 and higher.";
                elseif rRoll.aDice[1].result >= 6 then
                rRoll.sMessage = "You hit AC 8 only.";
                else
                rRoll.sMessage = "You miss.";
                end

			elseif rRoll.nMod == 7 then
            if rRoll.aDice[1].result >= 12 then
                rRoll.sMessage = "You hit AC 1 and higher.";
                elseif rRoll.aDice[1].result >= 10 then
                rRoll.sMessage = "You hit AC 2 and higher.";
                elseif rRoll.aDice[1].result >= 9 then
                rRoll.sMessage = "You hit AC 3 and higher.";
                else
                rRoll.sMessage = "Your attack seems to have no effect.";
                end

			elseif rRoll.nMod == 8 then
            if rRoll.aDice[1].result >= 19 then
                rRoll.sMessage = "You hit.";
                elseif rRoll.aDice[1].result >= 18 then
                rRoll.sMessage = "You hit AC 1 and AC 3 and higher.";
                elseif rRoll.aDice[1].result >= 17 then
                rRoll.sMessage = "You hit AC 3 and higher.";
                elseif rRoll.aDice[1].result >= 13 then
                rRoll.sMessage = "You hit AC 4 and higher.";
                elseif rRoll.aDice[1].result >= 12 then
                rRoll.sMessage = "You hit AC 5 and higher.";
                elseif rRoll.aDice[1].result >= 10 then
                rRoll.sMessage = "You hit AC 6 and higher.";
                else
                rRoll.sMessage = "You hit.";
                end

                else
                rRoll.sMessage = "Set your weapon class correctly.";
                
                end
		
	
	rRoll.nMAweapon = nMAweapon;

	return rRoll;
end



function onLanded(rSource, rTarget, rRoll)
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rRoll = getMAweaponDice(rRoll);
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
end


function createRoll(sParams)
  local rRoll = { };
  rRoll.aDice = {"d20"};
		Debug.console("rRoll.aDice: ", rRoll.aDice);
  rRoll.sType = sCmd;
		Debug.console("rRoll.sType: ", sCmd);
  rRoll.sDesc = "";
  rRoll.nMod = 0;
  rRoll.nTarget = 0;
--- rRoll.sUser = User.getUsername();

  
  local nStart, nEnd, sMod, sDescriptionParam = string.find(sParams, "([%d]+)%s*(.*)");
--Debug.console("createRoll: ",nStart, nEnd, sTarget, sDescriptionParam);
  if sMod then
    rRoll.nMod = tonumber(sMod);
		Debug.console("rRoll.nMod1: ", rRoll.nMod);
    rRoll.sDesc = sDescriptionParam;
		Debug.console("rRoll.sDesc: ", rRoll.sDesc);
		else
		rRoll.sDesc = sParams;
  end
--Debug.console("createRoll: ",rRoll);
  
  return rRoll;
end

function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  
    rMessage.dicedisplay = 0; -- don't display total

	rMessage.text = rMessage.text .. ": " .. rRoll.sMessage;
 
  return rMessage;
end



function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.." <modifier> <message>\n"; 
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command rolls 2d10, one Yin and one Yang dice. "; 
  rMessage.text = rMessage.text .. "Two Zero's is a catastrophic failure while any other matching dice is Perfect Harmony and a Critical Success. "; 
  rMessage.text = rMessage.text .. "If the dice are different the reported result is the difference between the dice and whether the result is Yin or Yang."; 
  Comm.deliverChatMessage(rMessage);
end
