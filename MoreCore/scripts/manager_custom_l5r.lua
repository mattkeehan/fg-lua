-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v3.0 register "ring"
local sCmd = "ring";

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
  rRoll.aDice = {};

  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
  if not sParams:match("(%d+)%s(.*)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d# <desc>\"";
    return rRoll;
  end

	local sNum, sDesc = sParams:match("(%d+)%s*(.*)");
	rRoll.sDesc = sDesc;
	local sDesc, nMod = ModifierStack.getStack(true);
	rRoll.sDesc = rRoll.sDesc .. "\n" .. sDesc;
	local nNum = tonumber(sNum)
	rRoll.nNum = nNum;
	local nMod = nMod;
	local count1 = nNum;
	local count2 = nMod;
	Debug.console("count2: ", count2);
	Debug.console("count1: ", count1);

  while count1 > 0 do
    table.insert(rRoll.aDice, "d6");
    count1 = count1 - 1;
  end
  while count2 > 0 do
    table.insert(rRoll.aDice, "d12");
    count2 = count2 - 1;
  end

  return rRoll;
end

---
--- This function steps through each die result and checks if it is greater than or equal to the success target number
--- adding to the success count if it is.
---
function countSuccess(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
		local nBlank = 0;
		local nSuccess = 0;
		local nSuccessStrife = 0;
		local nSuccessOpportunity = 0;
		local nExplosiveSuccessStrifeD6 = 0;
		local nExplosiveSuccessStrifeD12 = 0;
		local nExplosiveSuccess = 0;
		local nOpportunity = 0;
		local nOpportunityStrife = 0;
		
	for _,v in ipairs(rRoll.aDice) do
		if (v.result == 1) or (v.result == 12) then
			nBlank = nBlank + 1;
			Debug.console("nBlank: ", nBlank);
		end
		if (v.result == 2) or (v.result == 11) then
			nSuccess = nSuccess + 1;
			Debug.console("nSuccess: ", nSuccess);
		end
		if (v.result == 3) or (v.result == 10) then
			nSuccessStrife = nSuccessStrife + 1;
			Debug.console("nSuccessStrife: ", nSuccessStrife);
		end
		if (v.result == 4) and v.type == "d12" then
			nSuccessOpportunity = nSuccessOpportunity + 1;
			Debug.console("nSuccessOpportunity: ", nSuccessOpportunity);
		end
		if (v.result == 4) and v.type == "d6" then
			nOpportunity = nOpportunity + 1;
			Debug.console("nOpportunity: ", nOpportunity);
		end
		if (v.result == 5) and v.type == "d6" then
			nExplosiveSuccessStrifeD6 = nExplosiveSuccessStrifeD6 + 1;
			Debug.console("nExplosiveSuccessStrifeD6: ", nExplosiveSuccessStrifeD6);
		end
		if (v.result == 5) and v.type == "d12" then
			nExplosiveSuccessStrifeD12 = nExplosiveSuccessStrifeD12 + 1;
			Debug.console("nExplosiveSuccessStrifeD12: ", nExplosiveSuccessStrifeD12);
		end
		if (v.result == 6) and v.type == "d6"  then
			nOpportunityStrife = nOpportunityStrife + 1;
			Debug.console("nOpportunityStrife: ", nOpportunityStrife);
		end
		if (v.result == 6) and v.type == "d12" then
			nExplosiveSuccess = nExplosiveSuccess + 1;
			Debug.console("nExplosiveSuccess: ", nExplosiveSuccess);
		end
		if (v.result >= 7) and (v.result <= 9) then
			nOpportunity = nOpportunity + 1;
			Debug.console("nOpportunity: ", nOpportunity);
		end
	end
	

		rRoll.nBlank = nBlank;
		rRoll.nSuccess = nSuccess;
		rRoll.nSuccessStrife = nSuccessStrife;
		rRoll.nSuccessOpportunity = nSuccessOpportunity;
		rRoll.nExplosiveSuccessStrifeD6 = nExplosiveSuccessStrifeD6;
		rRoll.nExplosiveSuccessStrifeD12 = nExplosiveSuccessStrifeD12;
		rRoll.nExplosiveSuccess = nExplosiveSuccess;
		rRoll.nOpportunity = nOpportunity;
		rRoll.nOpportunityStrife = nOpportunityStrife;
		
		rRoll.nTotalSuccess = nSuccess + nSuccessStrife + nExplosiveSuccess + nSuccessOpportunity + nExplosiveSuccessStrifeD6 + nExplosiveSuccessStrifeD12;
		rRoll.nExplodingD6 = nExplosiveSuccessStrifeD6;
		rRoll.nExplodingD12 = nExplosiveSuccess + nExplosiveSuccessStrifeD12;
		rRoll.nExplosiveSuccessStrife = nExplosiveSuccessStrifeD6 + nExplosiveSuccessStrifeD12;
		rRoll.nTotalStrife = nSuccessStrife + nExplosiveSuccessStrifeD6 + nExplosiveSuccessStrifeD12 + nOpportunityStrife;
		rRoll.nTotalOpportunity = nOpportunity + nSuccessOpportunity + nOpportunityStrife;

		
	return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 0; --  display total
	
--		Debug.console("rRoll: ", rRoll);
--		Debug.console("rSource: ", rSource);
--		Debug.console("Totals: ", rRoll.nTotalSuccess, rRoll.nTotalOpportunity, rRoll.nTotalStrife);

		DB.setValue(rSource.sCreatureNode .. ".result.success", "number", rRoll.nSuccess);
		DB.setValue(rSource.sCreatureNode .. ".result.success_opportunity", "number", rRoll.nSuccessOpportunity);
		DB.setValue(rSource.sCreatureNode .. ".result.success_strife", "number", rRoll.nSuccessStrife);
		DB.setValue(rSource.sCreatureNode .. ".result.exploding", "number", rRoll.nExplosiveSuccess);
		DB.setValue(rSource.sCreatureNode .. ".result.exploding_strife", "number", rRoll.nExplosiveSuccessStrife);
		DB.setValue(rSource.sCreatureNode .. ".result.opportunity", "number", rRoll.nOpportunity);
		DB.setValue(rSource.sCreatureNode .. ".result.opportunity_strife", "number", rRoll.nOpportunityStrife);

		DB.setValue(rSource.sCreatureNode .. ".extra.d6s", "number", rRoll.nExplodingD6);
		DB.setValue(rSource.sCreatureNode .. ".extra.d12s", "number", rRoll.nExplodingD12);
		
		rMessage.font ="emotefont";
		rMessage.text = rMessage.text .. "\n[Keep " .. rRoll.nNum .. "]";

--		if rRoll.nBlank >= 1 then
--			rMessage.text = rMessage.text .. "\nBlanks [ " .. rRoll.nBlank  .. " ]";
--		end
--		if rRoll.nSuccess >= 1 then
--			rMessage.text = rMessage.text .. "\nSuccess [ " .. rRoll.nSuccess  .. " ]";
--		end
--		if rRoll.nSuccessStrife >= 1 then
--			rMessage.text = rMessage.text .. "\nSuccess+Strife [ " .. rRoll.nSuccessStrife  .. " ]";
--		end
--		if rRoll.nSuccessOpportunity >= 1 then
--			rMessage.text = rMessage.text .. "\nSuccess+Opportunity [ " .. rRoll.nSuccessOpportunity  .. " ]";
--		end
		if rRoll.nExplosiveSuccess >= 1 then
			rMessage.text = rMessage.text .. "\nExplosiveSuccess (Add d12) [ " .. rRoll.nExplosiveSuccess  .. " ]";
		end
		if rRoll.nExplosiveSuccessStrifeD6 >= 1 then
			rMessage.text = rMessage.text .. "\nExplosiveSuccess+Strife (Add d6) [ " .. rRoll.nExplosiveSuccessStrifeD6  .. " ]";
		end
		if rRoll.nExplosiveSuccessStrifeD12 >= 1 then
			rMessage.text = rMessage.text .. "\nExplosiveSuccess+Strife (Add d12) [ " .. rRoll.nExplosiveSuccessStrifeD12  .. " ]";
		end
--		if rRoll.nOpportunity >= 1 then
--			rMessage.text = rMessage.text .. "\nOpportunity [ " .. rRoll.nOpportunity  .. " ]";
--		end
--		if rRoll.nOpportunityStrife >= 1 then
--			rMessage.text = rMessage.text .. "\nOpportunity+Strife [ " .. rRoll.nOpportunityStrife  .. " ]";
--		end

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
