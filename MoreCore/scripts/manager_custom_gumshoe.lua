-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "gumshoe"

local sCmd = "gumshoe";

function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
--	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
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
  rRoll.aDice = {"d6"};

    
  
  local sTargetNum, sDesc = sParams:match("(%d+)%s*(.*)");
  Debug.console("count1: ", count);
	local sModDesc, nMod = ModifierStack.getStack(true);
	local nTargetNum = tonumber(sTargetNum);

	rRoll.sDesc = sDesc;
	rRoll.nMod = nMod;
	rRoll.nTargetNum = nTargetNum;
	rRoll.sModDesc = sModDesc;
	Debug.console("rRoll: ", rRoll);
  return rRoll;
end



---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 1; -- display total

  rMessage.text = rMessage.text .. " [" .. rRoll.nMod .. "] " .. rRoll.sModDesc;
  
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/successes\" command is used to roll a set of dice and report the number of dice that meet or exceed a success target number.\n"; 
  rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the success target number"; 
  rMessage.text = rMessage.text .. "by supplying the \"/successes\" command with parameters in the format of \"#d# #\", where the first # is the "; 
  rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
  rMessage.text = rMessage.text .. "space being the success target number for each dice."; 
  Comm.deliverChatMessage(rMessage);
end


---
--- This is the callback that gets triggered after the roll is completed.
---
function onLanded(rSource, rTarget, rRoll)
Debug.console("performAction: ", rRoll);
  rMessage = createChatMessage(rSource, rRoll);
	local nDiceResult = rRoll.aDice[1].result;
--  	rRoll.aDice[1].result = rRoll.nMod + rRoll.aDice[1].result;

Debug.console("performAction: ", rMessage);
  rMessage.type = sDice;
--  	rMessage.text = rMessage.text .. "\nTotal Result [" .. rRoll.aDice[1].result+rRoll.nMod .. "]";

  if rRoll.aDice[1].result+rRoll.nMod >= tonumber(rRoll.nTargetNum) then
	rMessage.text = rMessage.text .. "\nDice Result [" .. nDiceResult .. "]\n[Success vs " .. tonumber(rRoll.nTargetNum) .. " Difficulty]";
	else
	rMessage.text = rMessage.text .. "\nDice Result [" .. nDiceResult .. "]\n[Fail vs " .. tonumber(rRoll.nTargetNum) .. " Difficulty]";
	end
  Comm.deliverChatMessage(rMessage);
end
