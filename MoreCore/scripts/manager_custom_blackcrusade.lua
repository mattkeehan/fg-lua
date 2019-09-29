-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "blackcrusade";

-- MoreCore v0.60 
function onInit()
--  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  if not sParams or sParams == "" then 
    sParams = "1d100x50";
  end

  if sParams == "?" or string.lower(sParams) == "help" then
    createHelpMessage();    
  else
    local rRoll = createRoll(sParams);
    ActionsManager.performAction(draginfo, rActor, rRoll);
  end   

end


function onLanded(rSource, rTarget, rRoll)
Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rRoll = getDiceResults(rRoll);
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = sCmd;
  Comm.deliverChatMessage(rMessage);
end

function onDiceTotal( messagedata )
	local sMyTotal = string.match(messagedata.text, "t:%s(%d+)");
  Debug.console("onDiceTotal: ", sMyTotal, messagedata);
  return true, tonumber(sMyTotal);
end

---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
  local rRoll = {};
  rRoll.sType = sCmd;
  rRoll.nMod = 0;
--- rRoll.sUser = User.getUsername();
  rRoll.aDice = {};
  rRoll.aDropped = {};
  
  local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
  rRoll.sDesc = sDescriptionParam;
	Debug.console("rRoll.sDesc: ", rRoll.sDesc);


  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	Debug.console("Preflightcheck: ", rRoll.sDesc);
  if not sDicePattern:match("(%d+)d([%dF]*)x(%d+)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#x#\" ";
    return rRoll;
  end

  local sDice, sSuccessTarget = sDicePattern:match("(%d+d[%dF]+)x(%d+)");
	
  local SuccessTarget = tonumber(sSuccessTarget);
	Debug.console("sDicePattern: ", sDicePattern);
	Debug.console("SuccessTarget 1st timer: ", SuccessTarget);

  Debug.console("sDice: ", sDice);
  local aDice, nMod = StringManager.convertStringToDice(sDice);
  
  local aRulesetDice = Interface.getDice();
  local aFinalDice = {};
  local aNonStandardResults = {};
  for k,v in ipairs(aDice) do
    if StringManager.contains(aRulesetDice, v) then
      table.insert(aFinalDice, v);
    elseif v:sub(1,1) == "-" and StringManager.contains(aRulesetDice, v:sub(2)) then
      table.insert(aFinalDice, v);
    else
      local sSign, sDieSides = v:match("^([%-%+]?)[dD]([%dF]+)");
      if sDieSides then
        local nResult;
        if sDieSides == "F" then
          local nRandom = math.random(3);
          if nRandom == 1 then
            nResult = -1;
          elseif nRandom == 3 then
            nResult = 1;
          end
        else
          local nDieSides = tonumber(sDieSides) or 0;
          nResult = math.random(nDieSides);
        end
        
        if sSign == "-" then
          nResult = 0 - nResult;
        end
        
        nMod = nMod + nResult;
        table.insert(aNonStandardResults, string.format(" [%s=%d]", v, nResult));
      end
    end
  end


  if sDesc ~= "" then
  Debug.console("sDesc: ", sDesc);
  sDesc = rRoll.sDesc;
  Debug.console("rRoll.sDesc: ", rRoll.sDesc);
  else
    sDesc = sDice;
  end
  if #aNonStandardResults > 0 then
    sDesc = sDesc .. table.concat(aNonStandardResults, "");
  end
  
  local rRoll = { sType = sCmd, sDesc = sDesc, aDice = aFinalDice, nMod = nMod, nSuccessTarget = tonumber(SuccessTarget) };
  Debug.console("performAction: ", draginfo, rActor, rRoll);
  
  ActionsManager.performAction(draginfo, rActor, rRoll);
  
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function getDiceResults(rRoll)
nTotal = 0;
nDiff = 0;
nFail = 0;
nSuccess = 0;
nWorking = 0;

  local SuccessTarget = tonumber(rRoll.nSuccessTarget);
	Debug.console("SuccessTarget (dropresults): ", SuccessTarget);
	
	
    for _,v in ipairs(rRoll.aDice) do
	nTotal = nTotal + v.result;
	Debug.console("rRoll.nMod 1: ", rRoll.nMod);
	end
	nTotal = nTotal + rRoll.nMod;

	Debug.console("rRoll.nMod 1a: ", rRoll.nMod);


	if nTotal > SuccessTarget then
		nDiff = nTotal - SuccessTarget;
		Debug.console("nDiff FAIL: ", nDiff);
		nWorking = math.floor(nDiff / 10);
		Debug.console("nWorking: ", nWorking);
		if nWorking == 0 then
			sResult = "1 Degree of Failure";
		elseif nWorking > 0 then
			sResult = (nWorking +1) .. " Degrees of Failure";
		end
		Debug.console("Success/Fail: ", sResult);
			
	elseif nTotal <= SuccessTarget then
		nDiff = SuccessTarget - nTotal;
		Debug.console("nDiff SUCCESS: ", nDiff);
		nWorking = math.floor(nDiff / 10);
		Debug.console("nWorking: ", nWorking);
		if nWorking == 0 then
			sResult = "1 Degree of Success";
		elseif nWorking > 0 then
			sResult = (nWorking +1) .. " Degrees of Success";
		end
		Debug.console("Success/Fail: ", sResult);

		end
	
  rRoll.aTotal = nTotal;
  rRoll.aSuccessTarget = SuccessTarget;
  rRoll.aResult = sResult;
  return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.text = rMessage.text .. "\n(Difficulty: " .. rRoll.aSuccessTarget .. ")\n[Roll] " .. rRoll.aTotal .. "\nResult: " .. rRoll.aResult;
    rMessage.dicedisplay = 1; -- display total
    rMessage.text = rMessage.text;
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll percentage dice and comparing to a target number.\n"; 
  rMessage.text = rMessage.text .. "Rolling equal to or under the target is a success and over the target is a fail. For every 10 points"; 
  rMessage.text = rMessage.text .. " above or below the target the Degree of Success/Failure increases by 1."; 
  Comm.deliverChatMessage(rMessage);
end
