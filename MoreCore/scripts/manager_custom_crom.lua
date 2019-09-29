-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "crom"
local sCmd = "crom";

function onInit()
--  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local rRoll = createRoll(sParams);
  ActionsManager.performAction(draginfo, rActor, rRoll);
Debug.console("performAction: ", rRoll);
end   


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
  local rRoll = {};
  rRoll.sType = sCmd;
  rRoll.nMod = 0;
  -- Removed to allow ChatManager.createBaseMessage function to create the right name - active character or player name if no characters are active.
  --rRoll.sUser = User.getUsername();
  rRoll.aDice = {};

    
  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
  if not sParams:match("(%d+)d([%dF]*)%s(.*)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d# <desc>\"";
    return rRoll;
  end

  local sNum, sSize, sDesc = sParams:match("(%d+)d([%dF]+)%s*(.*)");
  rRoll.sDesc = sDesc;
  local count = tonumber(sNum);
  Debug.console("count1: ", count);
	local sDesc, nMod = ModifierStack.getStack(true);
	local sNum = tonumber(sNum) + nMod;
  local count = count+nMod;
  Debug.console("count2: ", count);

  while count > 0 do
    table.insert(rRoll.aDice, "d" .. sSize);
    
    -- For d100 rolls, we also need to add a d10 dice for the ones place
    if sSize == "100" then
      table.insert(rRoll.aDice, "d10");
    end
    count = count - 1;
  end

  rRoll.sNum = sNum;
  rRoll.sSize = sSize;

  return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function countDamageEffects(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
		local nDamage = 0;
		local nEffects = 0;
		for _,v in ipairs(rRoll.aDice) do
	if (v.result == 1) then
		nDamage = nDamage + 1;
		elseif (v.result == 2) then
			nDamage = nDamage + 2;
		end
		Debug.console("nDamage: ", nDamage);
	if (v.result >= 5) then
		nEffects = nEffects + 1;
		end
		Debug.console("nEffects: ", nEffects);
	end

	Debug.console("nDamage final: ", nDamage);
	Debug.console("nEffects final: ", nEffects);
  
  rRoll.nDamage = nDamage;
  rRoll.nEffects = nEffects;
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 1; -- don't display total

  rMessage.text = rMessage.text .. " (" .. rRoll.sNum .. "d" .. rRoll.sSize .. ")\n# Damage = " .. rRoll.nDamage .. "\n# Effects/Damage = " .. rRoll.nEffects .. "/" .. (rRoll.nEffects+rRoll.nDamage);
  
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.type = sCmd;
  rMessage.text = rMessage.text .. "The \"/crom #d6\" command is used to roll a set of d6. 1s = 1 damage, 2s = 2 damage, and 5s and 6s equal 1 damage each and 1 complication.\n"; 
  Comm.deliverChatMessage(rMessage);
end


function onDiceTotal( messagedata )
	local sMyTotal = string.match(messagedata.text, "%d/(%d+)");
  Debug.console("onDiceTotal: ", sMyTotal, messagedata);
  return true, tonumber(sMyTotal);
end

---
--- This is the callback that gets triggered after the roll is completed.
---
function onLanded(rSource, rTarget, rRoll)
  rRoll = countDamageEffects(rRoll);
Debug.console("performAction: ", rRoll);
  rMessage = createChatMessage(rSource, rRoll);
Debug.console("performAction: ", rMessage);
  rMessage.type = sCmd;
  Comm.deliverChatMessage(rMessage);
end
