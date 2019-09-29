---
--- Initialization
---

local sCmd = "stuntdmg";

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

function getStuntDice(rRoll)
local rDie1, rDie2, rDie3;
local nResult1, nResult2, nResult3;

    rDie1 = rRoll.aDice[1];
    nResult1 = rDie1.result;
		Debug.console("nResult1: ", nResult1);

    rDie2 = rRoll.aDice[2];
    nResult2 = rDie2.result;
		Debug.console("nResult2: ", nResult2);

    rDie3 = rRoll.aDice[3];
    nResult3 = rDie3.result;
		Debug.console("nResult3: ", nResult3);

	
		-- nStunt = nResult1 - nResult2;
		
    local nStunt = 0;
		if nResult1 ~= nResult2 and nResult2 ~= nResult3 and nResult3 ~= nResult1 then
			Debug.console("No Stunt");
			nStunt = 0;
			rRoll.sMessage = "No Stunt Roll";
		else 
			Debug.console("Stunt");
			nStunt = nResult3;
			Debug.console("Stunt: ", nStunt);
			rRoll.sMessage = "Stunt " .. nStunt .. " points!";
		end	
	
	rRoll.nStunt = nStunt;
	rRoll.total = nResult1 + nResult2 + nResult3;

	return rRoll;
end



function onLanded(rSource, rTarget, rRoll)
--Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rRoll = getStuntDice(rRoll);
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "damage";
  Comm.deliverChatMessage(rMessage);
end


function createRoll(sParams)
  local rRoll = { };
  rRoll.aDice = {"d6","d6","d1006"};
		Debug.console("rRoll.aDice: ", rRoll.aDice);
  rRoll.sType = sCmd;
		Debug.console("rRoll.sType: ", sCmd);
  rRoll.sDesc = "";
  rRoll.nMod = 0;
  rRoll.nTarget = 0;
--- rRoll.sUser = User.getUsername();

  
  local nStart, nEnd, sMod, sDescriptionParam = string.find(sParams, "([+-]?[%d]+)%s*(.*)");
--Debug.console("createRoll: ",nStart, nEnd, sTarget, sDescriptionParam);
  if sMod then
    rRoll.nMod = tonumber(sMod);
		Debug.console("rRoll.nMod1: ", rRoll.nMod);
    rRoll.sDesc = sDescriptionParam;
		Debug.console("rRoll.sDesc: ", rRoll.sDesc);
		else
		rRoll.sDesc = sParams;
  end
  if rRoll.nMod > 0 then
    rRoll.sDesc = rRoll.sDesc .. " [+"..rRoll.nMod.."]";
  elseif rRoll.nMod < 0 then
    rRoll.sDesc = rRoll.sDesc .. " ["..rRoll.nMod.."]";
  end
--Debug.console("createRoll: ",rRoll);
  
  return rRoll;
end

function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  
    rMessage.dicedisplay = 1; 
	
    if rRoll.nStunt > 0 then
        rMessage.text = rMessage.text .. "\r\n[Stunt Roll]\n" .. rRoll.nStunt .. " Stunt Points\n" .. rRoll.aDice[1].result .. "," .. rRoll.aDice[2].result .. "," .. rRoll.aDice[3].result;
      else        
		rMessage.text = rMessage.text .. "\r\n" .. rRoll.aDice[1].result .. "," .. rRoll.aDice[2].result .. "," .. rRoll.aDice[3].result;
      end
 
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
