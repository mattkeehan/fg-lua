-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "torg";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
  if sParams == "?" or string.lower(sParams) == "help" then
	createHelpMessage();	
	return;
  end
  
  Debug.console("performAction: ", draginfo, rActor, sParams);
  local sTraitValue, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");  

  local sBonusRoll = nil;
    
  if (sTraitValue == nil or sTraitValue:gsub("%s+", "") == '') then 
	sTraitValue = '0';
  end
  
  if tonumber(sTraitValue) ~= nil then
	sTraitValue = sTraitValue;
  elseif string.match(sTraitValue, "(%d+)") == nil then
	sTraitValue = 0;
	sDesc = sParams;
  else
	sTraitValue, sBonusRoll = string.match(sTraitValue, "(%d+)([[pu]%d*]*)");
  end
 
  if (sBonusRoll == nil or sBonusRoll:gsub("%s+", "") == '') then 
	sBonusRoll = nil;
  end
  
--  if (tonumber(sTraitValue) == nil) or (sBonusRoll == nill or string.match(sBonusRoll, "[pu]%d+") == nil) then
--    ChatManager.SystemMessage("Usage: /"..sCmd.." [trait/reroll type] [message]. '/"..sCmd.." ?' for details." );
--    return;
--  end
  	
  local sDice = "1d20+"..sTraitValue;
  
  if sDice == nil or not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /"..sCmd.." [trait/reroll type] [message]. '/"..sCmd.." ?' for details." );
    return;
  else
    local rRoll = createRoll(sDice, sBonusRoll, sDesc);
    Debug.console("performAction: rRoll ", rRoll);
    ActionsManager.performAction(draginfo, rActor, rRoll);
  end   
end

function getDieMax(sType)
Debug.console("getDieMax: ", sType);
  local sDie = string.match(sType, "d(%d+)");
  max = tonumber(sDie);
  return max;  
end

function initLastDice(aDice)
  aSavedDice = {};
  for i , v in ipairs (aDice) do
    aSavedDice[i] = { type=v.type, result=0, exploded=true };
  end
  return aSavedDice;
end

function onLanded(rSource, rTarget, rRoll)
  Debug.console("onLanded: ", rSource, rTarget, rRoll);
  
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
  
  local nTotal = 0;

  for i , v in ipairs (aSavedDice) do
    Debug.console("onLanded: last dice ", i, v);
    if v.exploded then
      w = aDice[k]; 
      k = k + 1; -- move on to next die for next time around
      v.result = v.result + w.result;
      if w.result == getDieMax(w.type) then
        aRerollDice[j] = w.type;

        j = j + 1;
        v.exploded = true;
      elseif w.result == 10 then
        aRerollDice[j] = w.type;

        j = j + 1;
        v.exploded = true;
      else
        v.exploded = false;
      end
    end
    nTotal = nTotal + v.result;
  end
  
  rRoll.aSavedDice = Json.stringify(aSavedDice);
--  Debug.chat("rRoll.aSavedDice: ", rRoll.aSavedDice);

  Debug.console("aRerollDice: ",#aRerollDice, aRerollDice);
  if #aRerollDice > 0 then
    rRoll.aDice = aRerollDice;
    ActionsManager.performAction(draginfo, rActor, rRoll);
    return;
  else
    rRoll.aDice = aSavedDice;
  end

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  rMessage = createChatMessage(rSource, rRoll);

  rMessage.type = "dice";

--  Debug.chat("nMod: ", rRoll.nMod);
  
  local nFirstDice = rRoll.aDice[1].result;
--  Debug.chat("nFirstDice: ", nFirstDice);
--  Debug.chat("nTotal: ", nTotal);
--  Debug.chat("rMessage: ", rMessage);

  local bBonusRoll = false;
  local sBonusRollType = '';
  local nBonusRollPrevious = 0;

  -- parse the bonus roll info
  if (rRoll.sBonusRoll ~= nil and string.match(rRoll.sBonusRoll, 'p%d+') ~= nil) then
	bBonusRoll = true;
    sBonusRollType = 'p';
	nBonusRollPrevious = tonumber(string.match(rRoll.sBonusRoll, '%d+')); 
  elseif (rRoll.sBonusRoll ~= nil and string.match(rRoll.sBonusRoll, 'u%d+') ~= nil) then
	bBonusRoll = true;
    sBonusRollType = 'u';
	nBonusRollPrevious = tonumber(string.match(rRoll.sBonusRoll, '%d+'));
  end
  
  if tonumber(nBonusRollPrevious) == nil then
    nBonusRollPrevious = 0;
  end
  
  if (nFirstDice < 10 and sBonusRollType == 'p') then
	nTotal = 10;
  end
  
  nTotal = nTotal + nBonusRollPrevious;
  rMessage.text = rMessage.text .. "\nDie Total " .. nTotal;
  
  if bBonusRoll then
    rMessage.text = rMessage.text .. " (" .. nBonusRollPrevious .. "+ "; 
	if sBonusRollType == 'p' then
      rMessage.text = rMessage.text .. "Poss)";
	else
      rMessage.text = rMessage.text .. "Up)";	
	end
  end

  local nBonus = 0;
  
  if nTotal >= 21 then
    nBonus = math.ceil((nTotal - 20)/5) + 7;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +"..nBonus;
  elseif nTotal == 20 then
    nBonus = 7;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +7";
  elseif nTotal == 19 then
    nBonus = 6;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +6";
  elseif nTotal == 18 then
    nBonus = 5;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +5";
  elseif nTotal == 17 then
     nBonus = 4;
--	Debug.chat("nBonus: ", nBonus);
   rMessage.text = rMessage.text .. "\nBonus +4";
  elseif nTotal == 16 then
    nBonus = 3;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +3";
  elseif nTotal == 15 then
    nBonus = 2;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +2";
  elseif nTotal >= 13 then
    nBonus = 1;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +1";
  elseif nTotal >= 11 then
    nBonus = 0;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus +0";
  elseif nTotal >= 9 then
    nBonus = -1;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -1";
  elseif nTotal >= 7 then
    nBonus = -2;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -2";
  elseif nTotal >= 5 then
    nBonus = -4;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -4";
  elseif nTotal >= 4 then
    nBonus = -4;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -4";
  elseif nTotal >= 3 then
    nBonus = -6;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -6";
  elseif nTotal >= 2 then
    nBonus = -8;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -8";
  else
    nBonus = -10;
--	Debug.chat("nBonus: ", nBonus);
    rMessage.text = rMessage.text .. "\nBonus -10";
  end

  local nCheck = nBonus + rRoll.nMod;
  
  if (nFirstDice == 1 and not bBonusRoll) then
    rMessage.text = rMessage.text .. "\n ** CRITICAL FAILURE! **";
  elseif (nFirstDice <= 4 and not bBonusRoll) then
   rMessage.text = rMessage.text .. "\nAction Total ".. nCheck .. "\n  (Possible Mishap)";
  elseif nTotal >= 60 then
    rMessage.text = rMessage.text .. "\nAction Total ".. nCheck .. "\n ** GLORY! **";
  else
    rMessage.text = rMessage.text .. "\nAction Total ".. nCheck;  
  end
  
  if rTarget then
    rMessage.text = rMessage.text .. "\nvs ".. rTarget.sName;
  end
  
  rMessage.dicedisplay = 0; -- don't display total
  Comm.deliverChatMessage(rMessage);
end

---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sDice, sBonusRoll, sDesc)
  local aDice, nMod = StringManager.convertStringToDice(sDice);

  local rRoll = { };
  rRoll.aDice = aDice;
  rRoll.sType = sCmd;
  rRoll.nMod = nMod;
  rRoll.sBonusRoll = sBonusRoll;
  rRoll.sDesc = sDesc;
--- rRoll.sUser = User.getUsername();

--Debug.console("createRoll: ",rRoll);
  
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.." <optional: trait|add-on params>\n";   
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll 1d20, exploding on 10 and 20. The dice total is then checked on the Bonus Chart for an action total.  A roll of 1 on the initial die roll is a fumble (automatic failure) and roll of 4 or less is a possible mishap. Dice totals over 60 are a Glory result. "; 
  rMessage.text = rMessage.text .. "If a trait value (any integer) is provided, it is added to the bonus number (along with any modifiers from the Modifier box) to get the action total. \n";   
  rMessage.text = rMessage.text .. "This will become an 'Up' or 'Possibility' add-on roll by providing the add-on paramaters in the format of \"#?#\" where the first # is the trait value, ? is either 'u' or 'p' and the final # is the original die roll. For example, \"/"..sCmd.." 8p12\" would indicate a possibility was spent to add to an original roll of 12, testing a trait with a value of 8. \n"; 
  rMessage.text = rMessage.text .. "The result, along with an optional message is output to the chat window."; 
  Comm.deliverChatMessage(rMessage);
end
