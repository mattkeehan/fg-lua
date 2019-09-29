-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v3.0 register "exalted"
local sCmd = "exalteddmg";

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
function countSuccess(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
		local nFailure = 0;
		local nSuccess = 0;
	for _,v in ipairs(rRoll.aDice) do
		-- Check the number of 1s
		if (v.result == 1) then
			nFailure = nFailure + 1;
			Debug.console("1 1s !");
			Debug.console("nFailure: ", nFailure);
		end
		-- Check the number of success
		if (v.result >= 7) then
			nSuccess = nSuccess + 1;
			Debug.console("1 succès !");
			Debug.console("nSuccess: ", nSuccess);
		end
	end
	
	Debug.console("nFailure final: ", nFailure);
	Debug.console("nSuccess final: ", nSuccess);

	rRoll.nFailure = nFailure;
	rRoll.nSuccess = nSuccess;
	return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 1; --  display total
	
	-- Verify botch condition (no successes and at least a 1s)
	if (rRoll.nFailure >= 1 and rRoll.nSuccess == 0) then
		rMessage.font ="emotefont";
		rMessage.text = rMessage.text .. "\nBotched Damage Roll!";
	elseif (rRoll.nSuccess == 0) then
		rMessage.font ="msgfont";
		rMessage.text = rMessage.text .. " \nDamage Roll\n (" .. rRoll.sNum .. "d" .. rRoll.sSize .. ")\n# 1s obtained = " .. rRoll.nFailure .. "\n# Successes = " .. rRoll.nSuccess;
	else
		rMessage.font ="oocfont";
		rMessage.text = rMessage.text .. " \nDamage Roll\n (" .. rRoll.sNum .. "d" .. rRoll.sSize .. ")\n# 1s obtained = " .. rRoll.nFailure .. "\n# Successes = " .. rRoll.nSuccess;
	end
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.type = sCmd;
  rMessage.text = rMessage.text .. "The \"/exalted #d10\" command is used to roll a set of d10. 7s and above are success. If you obtain no successes and at least one 1s, it's a botch!\n"; 
  Comm.deliverChatMessage(rMessage);
end


function onDiceTotal( messagedata )
	local nSuccessCount;
		for w in string.gmatch (messagedata.text, "(%d+)") do
			nSuccessCount = w
			Debug.console("nSuccessCount: ", nSuccessCount, tonumber(nSuccessCount));
		end
			Debug.console("last2: ", nSuccessCount, tonumber(nSuccessCount));
  return true, tonumber(nSuccessCount);
end

---
--- This is the callback that gets triggered after the roll is completed.
---
function onLanded(rSource, rTarget, rRoll)
  rRoll = countSuccess(rRoll);
Debug.console("performAction: ", rRoll);
  rMessage = createChatMessage(rSource, rRoll);
Debug.console("performAction: ", rMessage);
  rMessage.type = sCmd;
  Comm.deliverChatMessage(rMessage);
end
