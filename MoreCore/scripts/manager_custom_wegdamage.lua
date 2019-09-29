-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "wegdamage";

OOB_MSGTYPE_APPLYDAMAGE = "applydamage";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
  OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDAMAGE, handleApplyDamage);
end

function onDiceTotal( messagedata )
--  Debug.chat("messagedata.text: ", messagedata.text);
	local sDamageValue = string.match(messagedata.text, "%s(%d+)");
	local nDamageValue = tonumber(sDamageValue);
--  Debug.chat("onDiceTotal nDamageValue: ", nDamageValue);
  return true, nDamageValue;
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
  Debug.console("onLanded-wegdamage-49: ", rSource, rTarget, rRoll);
  
  if rTarget then
	Debug.console("rTarget is not nil: ", rTarget);
	  if rRoll.sTargetsName == nil then
		Debug.console("rRoll.rTarget is nil");
		rTargetsType = rTarget.sType;
		rRoll.rTargetsType = rTargetsType;
		Debug.console("rTargetsType: ", rRoll.rTargetsType);
		rTargetsCreatureNode = rTarget.sCreatureNode;
		rRoll.rTargetsCreatureNode = rTargetsCreatureNode;
		Debug.console("rTargetsCreatureNode: ", rRoll.rTargetsCreatureNode);
		rTargetsCTNode = rTarget.sCTNode;
		rRoll.rTargetsCTNode = rTargetsCTNode;
		Debug.console("rTargetsCTNode: ", rRoll.rTargetsCTNode);
		rTargetsName = rTarget.sName;
		rRoll.rTargetsName = rTargetsName;
		Debug.console("rTargetsName: ", rRoll.rTargetsName);
		end
	else
	if rRoll.rTargetsName == nil then
		rRoll.rTargetsName = "No Target Selected";
		Debug.console("rTarget is nil 67: ", rRoll.rTargetsName);
		end
	end

  if rRoll.rTargetsName ~= nil then
		Debug.console("rRoll.rTargetsType: ", rRoll.rTargetsType);
		Debug.console("rRoll.rTargetsCreatureNode: ", rRoll.rTargetsCreatureNode);
		Debug.console("rRoll.rTargetsCTNode: ", rRoll.rTargetsCTNode);
		Debug.console("rRoll.rTargetsName: ", rRoll.rTargetsName);
	else
	rRoll.rTargetsName = "No Target Selected";
		Debug.console("rTargetsName is nil: ", rRoll.rTargetsName);
	end



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
      if w.result == 6 and w.type == 'd6' then
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
	  local count = 0;
	  for i,v in ipairs (rRoll.aDice) do
		count = count + 1;
		Debug.console("Count1: ", count);
		nTotal = nTotal + rRoll.aDice[count].result;
		Debug.console("nTotal: ", nTotal);
		
		sMessage = "Result ";
		end
		Debug.console("Count2: ", count);

		nWEGResult = nTotal + rRoll.nMod;
--		sMessage1 = sMessage .. nWEGResult;
--		Debug.console("sMessage1: ", sMessage1);
		rRoll.aTotal = nWEGResult;
		Debug.console("nWEGResult: ", nWEGResult);
	
  end

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  rMessage = createChatMessage(rSource, rRoll);
  rMessage.dicedisplay = 1; -- display total
  rMessage.type = sCmd;
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
  
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll, rTarget)  

	Debug.console("createChatMessage 191: ", rRoll);

	if rRoll.rTargetsCTNode ~= nil then
	Debug.console("createChatMessage 194: ", rRoll.rTargetsCTNode);

	rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Debug.console("rMessage 197: ", rMessage);
    myTargetDefense = tonumber(DB.getValue(rRoll.rTargetsCTNode .. ".defence"));
	Debug.console("myTargetDefense: ", myTargetDefense);
	
	local nMinDamage = rRoll.aTotal - myTargetDefense;
	if nMinDamage < 0 then nMinDamage = 0; end
	rMessage.text = rMessage.text .. "\n[Damage] " .. nMinDamage;
	rRoll.aTotal = nMinDamage;
	Debug.console("nMinDamage: ", nMinDamage);
	else
    rMessage.text = rMessage.text .. "\n[Damage] " .. rRoll.aTotal .. " - Adjust for Defense";
	end  

  rMessage.dicedisplay = 1; -- display total

  sendApplyDamage(rRoll, nMinDamage);
  
	if rRoll.rTargetsName ~= nil then
	rMessage.text = rMessage.text .. "\nvs "..rRoll.rTargetsName;
	end
	
	rRoll.nMinDamage = nMinDamage;
  return rMessage;


--  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
--  return rMessage;
end

function sendApplyDamage(rRoll, nMinDamage)
Debug.console("sendApplyDamage 226", rRoll, rRoll.nMinDamage);

  local msgOOB = {};
  msgOOB.type = OOB_MSGTYPE_APPLYDAMAGE;
  
  msgOOB.nDamage = rRoll.aTotal;

  local sTargetType = rRoll.rTargetsType;
  local sTargetNode = rRoll.rTargetsCTNode;
	Debug.console("sTargetType 238", sTargetType);
	Debug.console("sTargetNode 239", sTargetNode);
  msgOOB.sTargetType = sTargetType;
  msgOOB.sTargetNode = sTargetNode;

  Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyDamage(msgOOB)
  local rTarget = ActorManager.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);
  local nDamage = msgOOB.nDamage;

  Debug.console("handleApplyDamage", rTarget, nDamage);

  applyDamage(rRoll.rTargetsCTNode, rRoll.aTotal);
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
