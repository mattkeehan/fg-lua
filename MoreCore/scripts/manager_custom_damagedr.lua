-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "damagedr";

OOB_MSGTYPE_APPLYDAMAGE = "applydamage";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
  OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDAMAGE, handleApplyDamage);
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  if not sParams or sParams == "" then 
    sParams = "1d6";
  end

  if sParams == "?" or string.lower(sParams) == "help" then
    createHelpMessage();    
  else
    local rRoll = createRoll(sParams);
    ActionsManager.performAction(draginfo, rActor, rRoll);
  end   

end


function onLanded(rSource, rTarget, rRoll)
Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rRoll = getDiceResults(rRoll);
  rMessage = createChatMessage(rSource, rRoll, rTarget);
  rMessage.type = "damage";
  Comm.deliverChatMessage(rMessage);
end


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
  local rRoll = {};
  rRoll.sType = sCmd;
  rRoll.nMod = 0;
--- rRoll.sUser = User.getUsername();
  rRoll.aDice = {};
  rRoll.aDropped = {};

  local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
  rRoll.sDesc = sDescriptionParam;

  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
  if not sDicePattern:match("(%d+)d([%dF]*)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#+#\" ";
    return rRoll;
  end

  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
	
  local aDice, nMod = StringManager.convertStringToDice(sDice);
  local aRulesetDice = Interface.getDice();
  local aFinalDice = {};
  local aNonStandardResults = {};
  for k,v in ipairs(aDice) do
    if StringManager.contains(aRulesetDice, v) then
      table.insert(aFinalDice, v);
    elseif v:sub(1,1) == "-" and StringManager.contains(aRulesetDice, v:sub(2)) then
      table.insert(aFinalDice, v);
    else
      local sSign, sDieSides = v:match("^([%-%+]?)[dD]([%dF]+)");
      if sDieSides then
        local nResult;
        if sDieSides == "F" then
          local nRandom = math.random(3);
          if nRandom == 1 then
            nResult = -1;
          elseif nRandom == 3 then
            nResult = 1;
          end
        else
          local nDieSides = tonumber(sDieSides) or 0;
          nResult = math.random(nDieSides);
        end
        nMod = nMod + nResult;
        table.insert(aNonStandardResults, string.format(" [%s=%d]", v, nResult));
       
      end
    end
  end


  if sDesc ~= "" then
  sDesc = rRoll.sDesc;
  else
    sDesc = sDice;
  end
  if #aNonStandardResults > 0 then
    sDesc = sDesc .. table.concat(aNonStandardResults, "");
  end
  
	local rRoll = { sType = sCmd, sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
	return(rRoll);

 
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function getDiceResults(rRoll)
nTotal = 0;

 
    for _,v in ipairs(rRoll.aDice) do
	nTotal = nTotal + v.result;
	end
	nTotal = nTotal + rRoll.nMod;

  rRoll.aTotal = nTotal;
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll, rTarget)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  
  
  
  if rTarget ~= nil and rTarget.sCTNode ~= nil then
	Debug.chat("DR!!!!");
    myTargetArmor = tonumber(DB.getValue(rTarget.sCTNode .. ".defence"));
	local nMinDamage = rRoll.aTotal - myTargetArmor;
	Debug.chat("nMinDamage!!!!");
	if nMinDamage < 0 then nMinDamage = 0; end
    Debug.console("nMinDamage: ", nMinDamage);
  rMessage.text = rMessage.text .. "\n[Damage] " .. nMinDamage;
	Debug.chat("nMinDamage: ", nMinDamage);
	rRoll.aTotal = nMinDamage;
	Debug.chat("nDamage/atotal: ", rRoll.aTotal);
  else
    rMessage.text = rMessage.text .. "\n[Damage] " .. rRoll.aTotal;
	Debug.chat("nDamage: ", rRoll.aTotal);

	end  
  

  rMessage.dicedisplay = 1; -- display total

  sendApplyDamage(rTarget, rRoll.aTotal);
  if rTarget ~= nil then
	rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
	end
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll a set of dice, removing a number of the lowest results.\n"; 
  rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the number of results to be dropped "; 
  rMessage.text = rMessage.text .. "by supplying the \"/rolld\" command with parameters in the format of \"#d#x#\", where the first # is the "; 
  rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
  rMessage.text = rMessage.text .. "x being the number of results to be dropped.\n"; 
  rMessage.text = rMessage.text .. "If no parameters are supplied, the default parameters of \"4d6x1\" are used."; 
  Comm.deliverChatMessage(rMessage);
end

function applyDamage(rTarget, nDamage)
  local myTargetWounds;

  
  if rTarget ~= nil and rTarget.sCTNode ~= nil then
    myTargetWounds = tonumber(DB.getValue(rTarget.sCTNode .. ".wounds"));
    Debug.console("myTargetWounds: ", myTargetWounds);
  
    local myTargetNewWounds = myTargetWounds + nDamage;
    Debug.console("myTargetNewWounds: ", myTargetNewWounds);
  
    local myTarget = rTarget.sCTNode .. ".wounds";
    Debug.console("myTarget: ", myTarget);
    DB.setValue(myTarget, "number", myTargetNewWounds );
  end;
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
