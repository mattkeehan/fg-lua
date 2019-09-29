-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "dsadamage";

OOB_MSGTYPE_APPLYDMG = "applydmg";

-- MoreCore v0.60 
function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDMG, handleApplyDamage);
	
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, "action_damage");
end

function handleApplyDamage(msgOOB)
	local rSource = ActorManager.getActor(msgOOB.sSourceType, msgOOB.sSourceNode);
	local rTarget = ActorManager.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);
	if rTarget then
		rTarget.nOrder = msgOOB.nTargetOrder;
	end
	
	local nTotal = tonumber(msgOOB.nTotal) or 0;
	applyDamage(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sRollType, msgOOB.sDamage, nTotal);
end

function notifyApplyDamage(rSource, rTarget, bSecret, sRollType, sDesc, nTotal)
	if not rTarget then
		return;
	end
	local sTargetType, sTargetNode = ActorManager.getTypeAndNodeName(rTarget);
	if sTargetType ~= "pc" and sTargetType ~= "ct" then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDMG;
	
	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sRollType = sRollType;
	msgOOB.nTotal = nTotal;
	msgOOB.sDamage = sDesc;
	msgOOB.sTargetType = sTargetType;
	msgOOB.sTargetNode = sTargetNode;
	msgOOB.nTargetOrder = rTarget.nOrder;

	local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
	msgOOB.sSourceType = sSourceType;
	msgOOB.sSourceNode = sSourceNode;

	Comm.deliverOOBMessage(msgOOB, "");
end

function applyDamage(rSource, rTarget, bSecret, sRollType, sDamage, nTotal)
	Debug.console("Running applyDamage(rSource, rTarget, bSecret, sRollType, sDamage, nTotal): ", rSource, rTarget, bSecret, sRollType, sDamage, nTotal);
	local nTotalLP = 0;
	local nPRO = 0;
	local nWounds = 0;
	local nTotalDamage = 0;

	local aNotifications = {};
	local bRemoveTarget = false;
	
	local sTypeOutput = "Damage";  -- Use to indicate damage/heal
	
	-- Get health fields
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	if sTargetType ~= "pc" and sTargetType ~= "ct" then
		return;
	end
	
	if sTargetType == "pc" then
		nTotalLP = DB.getValue(nodeTarget, "health", 0);
		nPRO = DB.getValue(nodeTarget, "defence", 0);
		nWounds = DB.getValue(nodeTarget, "wounds", 0);
	else
		nTotalLP = DB.getValue(nodeTarget, "health", 0);
		nPRO = DB.getValue(nodeTarget, "defence", 0);
		nWounds = DB.getValue(nodeTarget, "wounds", 0);
	end
	
	Debug.console("LP, PRO, Wounds = ", nTotalLP, nPRO, nWounds);
	
	-- Apply the damage to the target, minus PRO (Protection)
	if nTotal > nPRO then
		nWounds = nWounds + (nTotal - nPRO);
		DB.setValue(nodeTarget, "wounds", "number", nWounds);
		nTotalDamage = nTotal - nPRO;
	end
	
	-- Output results
	messageDamage(rSource, rTarget, bSecret, sTypeOutput, sDamage, nTotalDamage, table.concat(aNotifications, " "));
	
end

function messageDamage(rSource, rTarget, bSecret, sDamageType, sDamageDesc, sTotal, sExtraResult)
	Debug.console("messageDamage function...");
	if not (rTarget or sExtraResult ~= "") then
		return;
	end
	
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};

	if sDamageType == "Heal" or sDamageType == "Temporary hit points" then
		msgShort.icon = "roll_heal";
		msgLong.icon = "roll_heal";
	else
		msgShort.icon = "roll_damage";
		msgLong.icon = "roll_damage";
	end

	msgShort.text = sDamageType .. " ->";
	msgLong.text = sDamageType .. " [" .. sTotal .. "] ->";
	if rTarget then
		msgShort.text = msgShort.text .. " [to " .. rTarget.sName .. "]";
		msgLong.text = msgLong.text .. " [to " .. rTarget.sName .. "]";
	end
	
	if sExtraResult and sExtraResult ~= "" then
		msgLong.text = msgLong.text .. " " .. sExtraResult;
	end
	
	ActionsManager.messageResult(bSecret, rSource, rTarget, msgLong, msgShort);
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
	Debug.console("dsadamage onLanded: ", rSource, rTarget, rRoll);
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rRoll = getDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rTarget, rRoll);
	rMessage.type = "dsadamage";
	Comm.deliverChatMessage(rMessage);
  
	-- Apply damage to the PC or CT entry referenced via OOBMessaging as only the GM can access all records in the CT
	notifyApplyDamage(rSource, rTarget, rMessage.secret, rRoll.sType, rMessage.text, nTotal);
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
  
  local rRoll = { sType = "dsadamage", sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
  Debug.console("performAction: ", draginfo, rActor, rRoll);
  
  ActionsManager.performAction(draginfo, rActor, rRoll);
  
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
function createChatMessage(rSource, rTarget, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  
	if rTarget then
		rMessage.text = rMessage.text .. " vs "..rTarget.sName;
	end 
  
    rMessage.text = rMessage.text .. "\n[Damage] " .. rRoll.aTotal;

    rMessage.dicedisplay = 1; -- display total
  
    rMessage.text = rMessage.text;

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
