-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "wegdamage";

OOB_MSGTYPE_APPLYDAMAGE = "applydamage";

-- MoreCore v0.60 
function onInit()
--  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
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
    ActionsManager2.performAction(draginfo, rActor, rTarget, rRoll);
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

if rTarget == nil and rRoll.rTarget ~= nil then 
	rTarget = rRoll.rTarget;
	end
	Debug.chat("another rTarget: ", rTarget);
if rTarget == nil and rRoll.rTarget ~= nil then 
	rTarget.sType = rRoll.rTargetsType;
	rTarget.sCreatureNode = rRoll.rTargetsCreatureNode;
	rTarget.sCTNode = rRoll.rTargetsCTNode;
	rTarget.sName = rRoll.rTargetsName;
	end
	Debug.chat("another rTarget 67: ", rTarget.sType, rTarget.sCreatureNode, rTarget.sCTNode, rTarget.sName);

  Debug.chat("onLanded: ", rTarget);
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
--    Debug.chat("onLanded: last dice ", i, v);
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
	Debug.chat("What is rTarget? ", rTarget);
	rRoll.rTargetsType = rTarget.sType;
	Debug.chat("did I save the rTargetsType? ", rRoll.rTargetsType);
	rRoll.rTargetsCreatureNode = rTarget.sCreatureNode;
	Debug.chat("did I save the rTargetsCreatureNode? ", rRoll.rTargetsCreatureNode);
	rRoll.rTargetsCTNode = rTarget.sCTNode;
	Debug.chat("did I save the rTargetsCTNode? ", rRoll.rTargetsCTNode);
	rRoll.rTargetsName = rTarget.sName;
	Debug.chat("did I save the rTargetsName? ", rRoll.rTargetsName);
    ActionsManager2.performAction(draginfo, rActor, rTarget, rRoll);
    return;
  else
    rRoll.aDice = aSavedDice;
--	Debug.console("aSavedDice: ", aSavedDice);
--	Debug.console("Result 1: ", rRoll.aDice[1].result);
--	Debug.console("Result 2: ", rRoll.aDice[2].result);
--	Debug.console("Result 3: ", rRoll.aDice[3].result);


			
	  local nTotal = 0;
	if rRoll.aDice[1].result == 1 then
	  local count = 0;
	  for i,v in ipairs (rRoll.aDice) do
		count = count + 1;
		Debug.console("Count1: ", count);
		nTotal = nTotal + rRoll.aDice[count].result;
		Debug.console("nTotal: ", nTotal);
		end
		Debug.console("Count: ", count);
		table.sort(rRoll.aDice, function(a,b) return a.result < b.result end);
		
		sMessage = "Blunder! Result ";
		Debug.console("sMessage: ", sMessage);
		nBlunder = rRoll.aDice[count].result + 1;
		Debug.console("nBlunder: ", nBlunder);
		nTotal = nTotal - nBlunder;
		Debug.console("nTotal Blunder: ", nTotal);
		end;
	if rRoll.aDice[1].result > 1 then
	  local count = 0;
	  for i,v in ipairs (rRoll.aDice) do
		count = count + 1;
		Debug.console("Count1: ", count);
		nTotal = nTotal + rRoll.aDice[count].result;
		Debug.console("nTotal: ", nTotal);
		
--		sMessage = "Result ";
		end
		end
		Debug.console("Count2: ", count);

		nWEGResult = nTotal + rRoll.nMod;
--		sMessage1 = sMessage .. nWEGResult;
--		Debug.console("sMessage1: ", sMessage1);
		rRoll.aTotal = nWEGResult;
		Debug.console("nWEGResult: ", nWEGResult);
	
  end

--  local rMessage = ActionsManager.createActionMessage(rSource, rRoll, rTarget);
--	Debug.chat("rMessage1: ", rMessage);
  rMessage = createChatMessage(rSource, rRoll, rTarget);
--	Debug.chat("rMessage2: ", rMessage);
  rMessage.dicedisplay = 1; -- display total
  rMessage.type = sCmd;
--  rMessage.text = rMessage.text .. " - ".. sMessage1;
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

	if rTarget == nil and rRoll.rTarget ~= nil then 
	rTarget = rRoll.rTarget;
	end
	Debug.chat("another rTarget2: ", rTarget);

  local rMessage = ActionsManager2.createActionMessage(rSource, rRoll, rTarget);
  
--	Debug.chat("rTarget!", rTarget);
	Debug.chat("rTarget.sCTNode!", rTarget.sCTNode);
	
  if rTarget ~= nil and rTarget.sCTNode ~= nil then
  
--	Debug.chat("Defense!", rTarget.sCTNode);
    myTargetDefense = tonumber(DB.getValue(rTarget.sCTNode .. ".defence"));
	local nMinDamage = rRoll.aTotal - myTargetDefense;
--	Debug.chat("nMinDamage!!!!");
	if nMinDamage < 0 then nMinDamage = 0; end
--    Debug.chat("nMinDamageAdjusted: ", nMinDamage);
	rMessage.text = rMessage.text .. "\n[Damage] " .. nMinDamage;
--	Debug.chat("nMinDamage: ", nMinDamage);
	rRoll.aTotal = nMinDamage;
--	Debug.chat("nDamage/atotal: ", rRoll.aTotal);
  else
    rMessage.text = rMessage.text .. "\n[Damage] " .. rRoll.aTotal .. " - Adjust for Defense";
--	Debug.chat("nDamage: ", rRoll.aTotal);
	end  

  rMessage.dicedisplay = 1; -- display total

  sendApplyDamage(rTarget, rRoll.aTotal);
  
	if rTarget ~= nil then
	rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
	end
	
	rRoll.nMinDamage = nMinDamage;
  return rMessage;


--  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
--  return rMessage;
end

function sendApplyDamage(rTarget, nDamage)
Debug.console("sendApplyDamage", rTarget, sDamage);
  if not rTarget then
    return;
  end
  
  local msgOOB = {};
  msgOOB.type = OOB_MSGTYPE_APPLYDAMAGE;
  
  msgOOB.nDamage = nDamage;

  local sTargetType, sTargetNode = ActorManager.getTypeAndNodeName(rTarget);
  msgOOB.sTargetType = sTargetType;
  msgOOB.sTargetNode = sTargetNode;

  Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyDamage(msgOOB)
  local rTarget = ActorManager.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);
  local nDamage = msgOOB.nDamage;

  Debug.console("handleApplyDamage", rTarget, nDamage);

  applyDamage(rTarget, nDamage);
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
