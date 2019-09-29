-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "tiny"
local sCmd = "tiny";

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



function countEvens(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
		local nSuccessess = 0;
		for _,v in ipairs(rRoll.aDice) do
	if (v.result == 5) then
		nSuccessess = nSuccessess + 1;
		end
	if (v.result == 6) then
		nSuccessess = nSuccessess + 1;
		end
		Debug.console("nSuccessess: ", nSuccessess);
	end

	Debug.console("nSuccessess final: ", nSuccessess);
  
  rRoll.nSuccessess = nSuccessess;
  
  if (nSuccessess >= 1) then
	rRoll.rMessage = "Success";
	else
		rRoll.rMessage = "Failure";
	end
  
	Debug.console("rRoll.rMessage: ", rRoll.rMessage);

	return rRoll;
end


---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 1; -- display total

  rMessage.text = rMessage.text .. " (" .. rRoll.sNum .. "d" .. rRoll.sSize .. ")\n# Successes = " .. rRoll.nSuccessess .. ")\n " .. rRoll.rMessage;
  
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.type = sCmd;
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
  rRoll = countEvens(rRoll);
Debug.console("performAction: ", rRoll);
  rMessage = createChatMessage(rSource, rRoll);
Debug.console("performAction: ", rMessage);
  rMessage.type = sCmd;
  Comm.deliverChatMessage(rMessage);
end

function onDiceTotal( messagedata )

	local sMyTotal = string.match(messagedata.text, "sses...(%d+)");
  Debug.console("onDiceTotal: ", sMyTotal, " MessageData: ", messagedata);
  return true, tonumber(sMyTotal);
end
