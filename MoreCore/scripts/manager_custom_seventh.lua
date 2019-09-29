-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "seventh"
function onInit()
  CustomDiceManager.add_roll_type("seventh", performAction, onLanded, true, "all");
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
  rRoll.sType = "seventh";
  rRoll.nMod = 0;
  -- Removed to allow ChatManager.createBaseMessage function to create the right name - active character or player name if no characters are active.
  --rRoll.sUser = User.getUsername();
  rRoll.aDice = {};

    
  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
  if not sParams:match("(%d+)d([%dF]*)%s(.*)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d# <desc>\"";
    return rRoll;
  end

  local sNum, sSize, sDesc = sParams:match("(%d+)d([%dF]+)%s(.*)");
  
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

  return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function orderDiceResults(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
    table.sort(rRoll.aDice, function(a,b) return a.result<b.result end)
--	Debug.chat("rRoll.aDice: ", rRoll.aDice);
	local nTotal = 0;
	local x = 1;
   for _,v in ipairs(rRoll.aDice) do
	nTotal = nTotal + rRoll.aDice[x].result;
	x = x + 1;
	end
	nFloor = math.floor(nTotal/10);
	if nFloor < 1 then
		nMinRaises = 0;
		nMaxRaises = 0;
		elseif nFloor < 2 then
			nMinRaises = 0;
			nMaxRaises = 1;
		else 
			if (nFloor % 2 == 0) then
				nMinRaises = nFloor / 2; 
				nMaxRaises = nFloor;
				else nMinRaises = nFloor / 2;
					nMaxRaises = nFloor;
			end
		end
	rRoll.raises = "\rRaises (min) " .. nMinRaises .. " (max) " .. nMaxRaises;
--	Debug.chat("nFloor: ", nFloor);
--	Debug.chat("rRoll.raises: ", rRoll.raises);
--	Debug.chat("rRoll: ", rRoll);
  return rRoll;

end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  rMessage.text = rMessage.text .. rRoll.raises;
  
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
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
end
