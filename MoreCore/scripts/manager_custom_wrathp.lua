-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "wrathp"
function onInit()
-- Debug.chat("onInit");
  CustomDiceManager.add_roll_type("wrathp", performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
-- Debug.chat("performAction");
-- Debug.console("performAction: ", draginfo, rActor, sParams);
  local rRoll = createRoll(sParams);
-- Debug.chat("performAction2");
-- Debug.console("performAction2");
  ActionsManager.performAction(draginfo, rActor, rRoll);
-- Debug.console("performAction: ", rRoll);
end   


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
-- Debug.chat("createRoll");
  local rRoll = {};
  rRoll.sType = "wrathp";
  rRoll.nMod = 0;
  -- Removed to allow ChatManager.createBaseMessage function to create the right name - active character or player name if no characters are active.
  --rRoll.sUser = User.getUsername();
  rRoll.aDice = {};

    
  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
  if not sParams:match("(%d+)d([%dF]*)p(%d+)%s(.*)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d# <desc>\"";
    return rRoll;
  end

  local sNum, sSize, sWrath, sDesc = sParams:match("(%d+)d([%dF]+)p(%d+)%s*(.*)");
  rRoll.sDesc = sDesc;
--  local count = tonumber(sNum) - toNumber(sWrathDice);
--  Debug.console("count1: ", count);
	local sModDesc, nMod = ModifierStack.getStack(true);
	sModDesc = "\r" .. sModDesc;
	local nNum = tonumber(sNum) + nMod;
	local nWrath1 = tonumber(sWrath);
	local nWrath2 = tonumber(sWrath);
	local count = nNum - nWrath1;
--  Debug.console("count2: ", count);
  
  while nWrath1 > 0 do
	table.insert(rRoll.aDice, "d3006");
	nWrath1 = nWrath1 - 1;
	end
  while count > 0 do
    table.insert(rRoll.aDice, "d" .. sSize);
    count = count - 1;
  end

--  Debug.chat(rRoll.aDice);
  rRoll.nWrath2 = nWrath2;
  rRoll.nNum = nNum;
  rRoll.sSize = sSize;
  rRoll.sModDesc = sModDesc;
  return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function countSuccesses(rRoll)
-- Debug.chat("countSuccesses");
		local nSuccess = 0;
		local nFailure = 0;
		local nExtraSuccess = 0;
		
		local nEpicFailure = 0;
		local nEpicSuccess = 0;
		local nWrathFailure = 0;
		local nWrathSuccess = 0;
		
		local nWrath2 = tonumber(rRoll.nWrath2);
	Debug.console("nWrath2: ", nWrath2);
		local sWrathResult = nil;
	Debug.console("sWrathResult: ", sWrathResult);
--	Debug.chat("count? ", #rRoll.aDice);
  for cnt=1, #rRoll.aDice do
--		for _,v in ipairs(rRoll.aDice) do
		if (rRoll.aDice[cnt].result == 1) and cnt <= nWrath2 then
--			Debug.chat("#1!");
			nFailure = nFailure + 1;
			if not sWrathResult and cnt <= nWrath2 then sWrathResult = "Epic Failure!";
				else sWrathResult = sWrathResult .. " Epic Failure!";
				end
			elseif (rRoll.aDice[cnt].result > 1) and (rRoll.aDice[cnt].result < 4) and cnt <= nWrath2 then
			nFailure = nFailure + 1;
			if not sWrathResult and cnt <= nWrath2 then sWrathResult = "Failure!";
				else sWrathResult = sWrathResult .. " Failure!";
				end
			elseif (rRoll.aDice[cnt].result > 3) and (rRoll.aDice[cnt].result < 6) and cnt <= nWrath2 then
			nSuccess = nSuccess + 1;
			if not sWrathResult and cnt <= nWrath2 then sWrathResult = "Success!";
				else sWrathResult = sWrathResult .. " Success!";
				end
			elseif (rRoll.aDice[cnt].result == 6) and cnt <= nWrath2 then
			nEpicSuccess = nEpicSuccess + 1;
			if not sWrathResult and cnt <= nWrath2 then sWrathResult = "Epic Success!";
				else sWrathResult = sWrathResult .. " Epic Success!";
				end
			elseif (rRoll.aDice[cnt].result < 4) and cnt > nWrath2 then
			nFailure = nFailure + 1;
			elseif (rRoll.aDice[cnt].result > 3) and (rRoll.aDice[cnt].result < 6) and cnt > nWrath2 then
			nSuccess = nSuccess + 1;
			elseif (rRoll.aDice[cnt].result == 6) and cnt > nWrath2 then
			nEpicSuccess = nEpicSuccess + 1;
			
			end
--			Debug.console("nEpicFailure: ", nEpicFailure, " nFailure: ", nFailure,  " nSuccess: ", nSuccess, " nEpicSuccess: ", nEpicSuccess);

--		end


	end
		-- BaseDice
		
  rRoll.nSuccess = nSuccess;
  rRoll.nFailure = nFailure;
  rRoll.nExtraSuccess = nExtraSuccess;

  rRoll.nEpicFailure = nEpicFailure;
  rRoll.nWrathSuccess = nWrathSuccess;
  rRoll.nWrathFailure = nWrathFailure;
  rRoll.nEpicSuccess = nEpicSuccess;

  rRoll.sWrathResult = sWrathResult;
  
	return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
--Debug.chat("createChatMessage");
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 0; -- don't display total

  rMessage.text = rMessage.text .. " (" .. rRoll.nNum .. "d" .. rRoll.sSize .. ")" .. rRoll.sModDesc .. "\rPsychic Die: " .. rRoll.sWrathResult .. "\rFails: " .. rRoll.nFailure .. ", Successes: " .. rRoll.nSuccess .. ", Epic Success: " .. rRoll.nEpicSuccess;
  
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
--Debug.chat("onLanded!");
  rRoll = countSuccesses(rRoll);
--Debug.console("performAction: ", rRoll);
  rMessage = createChatMessage(rSource, rRoll);
--Debug.console("performAction: ", rMessage);
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
end
