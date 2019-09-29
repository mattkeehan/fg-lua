-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "wrathdmgm"
local sCmd = "wrathdmgm";

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
  if not sParams:match("(%d+)d([%dF]*)x(%d+)%s(.*)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#x# <desc>\"";
    return rRoll;
  end

  local sNum, sSize, sWrathMod, sDesc = sParams:match("(%d+)d([%dF]+)x(%d+)%s(.*)");
  Debug.console("sNum: ", sNum, " sSize: ", sSize, " sWrathMod: ", sWrathMod, " sDesc: ", sDesc) ;
  local sModDesc, nModNum = ModifierStack.getStack(true);
  
  local count = tonumber(sNum)+nModNum;

  while count > 0 do
    table.insert(rRoll.aDice, "d" .. sSize);
    
    -- For d100 rolls, we also need to add a d10 dice for the ones place
    if sSize == "100" then
      table.insert(rRoll.aDice, "d10");
    end
    count = count - 1;
  end
  
  rRoll.sDesc = sDesc .. "\r" .. sModDesc;
  rRoll.nWrathMod = tonumber(sWrathMod);

  return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function orderDiceResults(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
	local nTotal = tonumber(rRoll.nWrathMod);
	Debug.console("nTotal: ", nTotal);
	local x = 1;
   for _,v in ipairs(rRoll.aDice) do
	Debug.console("rRoll.aDice: ", rRoll.aDice);
	if rRoll.aDice[x].result == 1 then 
		nTotal = nTotal + 0;
	Debug.console("nTotal: 123 ", nTotal, x);
		elseif rRoll.aDice[x].result >= 4 then 
		nTotal = nTotal + 2;
	Debug.console("nTotal: 6 ", nTotal, x);
		elseif rRoll.aDice[x].result > 1 and rRoll.aDice[x].result < 4 then
		nTotal = nTotal + 1;
	Debug.console("nTotal: 45 ", nTotal, x);
		end
	x = x + 1;
	Debug.console("nTotal: ", nTotal, x);
	end
	Debug.console("nTotal Final: ", nTotal);

	rRoll.damage = "\rDamage " .. nTotal;
--	Debug.chat("nFloor: ", nFloor);
--	Debug.chat("rRoll.damage: ", rRoll.damage);
--	Debug.chat("rRoll: ", rRoll);
  return rRoll;

end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  rMessage.text = rMessage.text .. rRoll.damage;
  
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
  rRoll = orderDiceResults(rRoll);
Debug.console("performAction: ", rRoll);
  rMessage = createChatMessage(rSource, rRoll);
Debug.console("performAction: ", rMessage);
  rMessage.type = sCmd;
  Comm.deliverChatMessage(rMessage);
end


function onDiceTotal( messagedata )
	local sMyTotal = string.match(messagedata.text, "Damage%s(%d+)");
  Debug.console("onDiceTotal: ", sMyTotal, messagedata);
  return true, tonumber(sMyTotal);
end
