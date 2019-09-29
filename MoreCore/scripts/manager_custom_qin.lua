---
--- Initialization
---

local sCmd = "qin";

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

function getQinDice(rRoll)


rDie1 = rRoll.aDice[1];
nResult1 = rDie1.result;
		Debug.console("nResult1: ", nResult1);
if nResult1 == 10 then
	nResult1 = 0;
		Debug.console("nResult1a: ", nResult1);
	end;

rDie2 = rRoll.aDice[2];
nResult2 = rDie2.result;
		Debug.console("nResult2: ", nResult2);
if nResult2 == 10 then
	nResult2 = 0;
		Debug.console("nResult2a: ", nResult2);
	end;

	
		-- nQin = nResult1 - nResult2;
		
		if nResult1 == 0 and nResult2 == 0 then
			Debug.console("Catastrophic Failure 0+0!");
			rRoll.sMessage = "Catastrophic Failure 0+0!";
			elseif nResult1 == nResult2 then
				Debug.console("Perfect Harmony, Critical Success! ");
				rRoll.sMessage = "Perfect Harmony, Critical Success! ";
				elseif nResult1 < nResult2 then
					nQin = nResult1 - nResult2;
					Debug.console("nMod! ", rRoll.nMod);
					nQin = nQin + rRoll.nMod;
					Debug.console("Yin! ", nQin);
					rRoll.sMessage = "Yin! ";
					else 
						Debug.console("nMod! ", rRoll.nMod);
						nQin = nResult2 - nResult1 + rRoll.nMod;
						Debug.console("Yang! ", nQin);
						rRoll.sMessage = "Yang! ";
			end	
	
	rRoll.qin = nQin;

	return rRoll;
end



function onLanded(rSource, rTarget, rRoll)
--Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rRoll = getQinDice(rRoll);
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
end


function createRoll(sParams)
  local rRoll = { };
  rRoll.aDice = {"d10","d10"};
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
    rRoll.nMod1 = tonumber(sMod);
		Debug.console("rRoll.nMod1: ", rRoll.nMod1);
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
	
	if rRoll.aDice[1].result == 10 then
		rRoll.aDice[1].result = 0;
		end
	if rRoll.aDice[2].result == 10 then
		rRoll.aDice[2].result = 0;
		end
    if rRoll.aDice[1].result == 0 and rRoll.aDice[2].result == 0 then
        rMessage.text = rMessage.text .. "\r\n[Catastrophic Failure]\n(0,0)";
      elseif rRoll.aDice[1].result == rRoll.aDice[2].result then
			rMessage.text = rMessage.text .. "\r\n[Perfect Harmony, Critical Success]\n(" .. rRoll.aDice[1].result .. "," .. rRoll.aDice[2].result .. ")";
		elseif rRoll.aDice[1].result > rRoll.aDice[2].result then
				nQin = rRoll.aDice[1].result - rRoll.aDice[2].result;
				nQin = nQin + rRoll.nMod;
				rMessage.text = rMessage.text .. "\r\n[Yin]\n(" .. rRoll.aDice[1].result .. "," .. rRoll.aDice[2].result .. ") " .. nQin;
			elseif rRoll.aDice[2].result > rRoll.aDice[1].result then
					nQin = rRoll.aDice[2].result - rRoll.aDice[1].result;
					nQin = nQin + rRoll.nMod;
					rMessage.text = rMessage.text .. "\r\n[Yang]\n(" .. rRoll.aDice[1].result .. "," .. rRoll.aDice[2].result .. ") " .. nQin;
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
