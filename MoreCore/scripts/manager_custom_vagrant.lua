-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "vagrant"
function onInit()
  CustomDiceManager.add_roll_type("vagrant", performAction, onLanded, true, "all");
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
  rRoll.sType = "vagrant";
  rRoll.nMod = 0;
  -- Removed to allow ChatManager.createBaseMessage function to create the right name - active character or player name if no characters are active.
  --rRoll.sUser = User.getUsername();
  rRoll.aDice = {"d6"};

    
  


  local sDesc = sParams:match("%s*(.*)");
  rRoll.sDesc = sDesc;
	local sDesc, nMod = ModifierStack.getStack(true);
  local count = nMod;
  rRoll.count = nMod;
  
  if count > 0 then
	rRoll.sBtype = "Bonus";
	Debug.console("count1: ", count);
	Debug.console("rRoll.sBtype: ", rRoll.sBtype);
  elseif count < 0 then
	rRoll.sBtype = "Malice";
	count = count * -1;
	Debug.console("count2: ", count);
	Debug.console("rRoll.sBtype: ", rRoll.sBtype);
  else
	rRoll.sBtype = "None";
	Debug.console("count3: ", count);
	Debug.console("rRoll.sBtype: ", rRoll.sBtype);
  end
  
  while count > 0 do
    table.insert(rRoll.aDice, "dF");
    count = count - 1;
  end

  return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function countMods(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
		local rMessage = ChatManager.createBaseMessage(nil, nil);
		rMessage.text1 = " ";
		rMessage.text2 = " ";
		local nMods = 0;
		for _,v in ipairs(rRoll.aDice) do
		
		Debug.console("rRoll.sBtype", rRoll.sBtype);
		
		if rRoll.sBtype == "Bonus" then
		if (v.result == 1) then
		nMods = nMods + 1;
		Debug.console("Bonus: ", nMods);
		end

		elseif rRoll.sBtype == "Malice" then
		if (v.result == -1) then
		nMods = nMods + 1;
		Debug.console("Malice: ", nMods);
		end

		else
		nMods = 0;
		Debug.console("None: ", nMods);
		end
		Debug.console("nMods: ", nMods);
	end

	if rRoll.sBtype == "Bonus" then
		if nMods >= 4 then
			rMessage.text1 = " And And ";
			elseif nMods >= 2 then
			rMessage.text1 = " And ";
			else
			rMessage.text1 = " ";
			end
		else
		end
		
	if rRoll.sBtype == "Malice" then
		if nMods >= 4 then
			rMessage.text1 = " And And ";
			elseif nMods >= 2 then
			rMessage.text1 = " And ";
			else
			rMessage.text1 = " ";
			end
		else
		end
		
	if rRoll.aDice[1].result == 1 then
			if rRoll.sBtype == "Bonus" then
				if nMods >= 1 then
				nMods = nMods -1;
					rMessage.text2 = "Success - Yes but (-) ";
					else
					end
				else
			rMessage.text2 = "Failure - No and (-) ";
			end
		elseif rRoll.aDice[1].result == 2 then
			if rRoll.sBtype == "Malice" then
				if nMods >= 1 then
					rMessage.text2 = "Failure - No and (-) ";
					else
					end
				else
			rMessage.text2 = "Success - Yes but (-) ";
			end
		elseif rRoll.aDice[1].result == 3 then
			if rRoll.sBtype == "Bonus" then
				if nMods >= 1 then
					rMessage.text2 = "Simple Success - Yes ";
					else
					end
				else
			rMessage.text2 = "Simple Failure - No ";
			end
		elseif rRoll.aDice[1].result == 4 then
			if rRoll.sBtype == "Malice" then
				if nMods >= 1 then
					rMessage.text2 = "Simple Failure - No ";
					else
					end
				else
			rMessage.text2 = "Simple Success - Yes ";
			end
		elseif rRoll.aDice[1].result == 5 then
			if rRoll.sBtype == "Bonus" then
				if nMods >= 1 then
					rMessage.text2 = "Success - Yes and (+) ";
					else
					end
				else
			rMessage.text2 = "Failure - No but (+) ";
			end
		else 
			if rRoll.sBtype == "Malice" then
				if nMods >= 1 then
					rMessage.text2 = "Failure - No but (+) ";
					else
					end
				else
			rMessage.text2 = "Success - Yes and (+) ";
			end
		end	

		
			
	Debug.console("nMods final: ", nMods);
	Debug.console("rMessage.text1: ", rMessage.text1);
	Debug.console("rRoll.sMessage: ", rRoll.sMessage);
  
  rRoll.nMods = nMods;
  rRoll.sMessage1 = rMessage.text1;
  rRoll.sMessage2 = rMessage.text2;
  return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 0; -- don't display total
  
  rMessage.text = rMessage.text .. "\r\n" .. rRoll.sBtype .. " " .. rRoll.nMods .. "\r\n"  .. rRoll.sMessage2 .. rRoll.sMessage1;
  
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
  rRoll = countMods(rRoll);
Debug.console("performAction: ", rRoll);
  rMessage = createChatMessage(rSource, rRoll);
Debug.console("performAction: ", rMessage);
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
end
