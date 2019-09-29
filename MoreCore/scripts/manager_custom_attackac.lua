-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "attackac";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  if not sParams or sParams == "" then 
    sParams = "#d#+#xH or #d#+#xL";
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
  rRoll = getDiceResults(rRoll, rTarget);
  rMessage = createChatMessage(rSource, rRoll);
  rMessage.type = "dice";
  Comm.deliverChatMessage(rMessage);
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
	Debug.console("rRoll.sDesc: ", rRoll.sDesc, "sDicePattern", sDicePattern);

  if sTarget then
    rRoll.nTarget = tonumber(sTarget);
	Debug.console("nTarget: ", rRoll.nTarget);
    rRoll.sDesc = sDescriptionParam;
	else
		rRoll.sDesc = sParams;
  end

  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	Debug.console("Preflightcheck: ", rRoll.sDesc);
  if not sDicePattern:match("([^%s]+)x(%u)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#+#xH or #d#+#xL\" ";
    return rRoll;
  end

  local sDice, sHighLow = sDicePattern:match("([^%s]+)x(%u)");
	
--  local thac0 = tonumber(sThac0);
	Debug.console("sDicePattern: ", sDicePattern);
--	Debug.console("sThac0: ", thac0);

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
  
 local rRoll = { sType = sCmd, sDesc = sDesc, aDice = aFinalDice, nMod = nMod, sHighLow = sHighLow };
 return(rRoll);
 
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function getDiceResults(rRoll, rTarget)
	nTotal = 0;

  local nTarget = tonumber(rRoll.nTarget);
	Debug.console("nTotal (nTarget): ", rRoll.nTarget);
	Debug.console("sDice: ", sDice);
	Debug.console("sDice (sDice): ", rRoll.sDice);
	local sHighLow = rRoll.sHighLow;
--	local nSuccessAC = 0;	
--	Debug.console("nSuccessAC: ", nSuccessAC);
	
    for _,v in ipairs(rRoll.aDice) do
	nTotal = nTotal + v.result;
	Debug.console("rRoll.nMod 1: ", rRoll.nMod);
	end
	nTotal = nTotal + rRoll.nMod;

 	Debug.console("nTotal: ", nTotal);

	Debug.console("rRoll.nMod 1a: ", rRoll.nMod);
	local sHitResult;


	if rTarget ~= nil then
		if sHighLow == "H" then
			if nTotal >= tonumber(DB.getValue(rTarget.sCTNode .. ".defence")) then
				sHitResult = "Hit!";
			elseif nTotal < tonumber(DB.getValue(rTarget.sCTNode .. ".defence")) then
				sHitResult = "Miss!";
			end 
		elseif sHighLow == "L" then
			if nTotal <= tonumber(DB.getValue(rTarget.sCTNode .. ".defence")) then
				sHitResult = "Hit!";
			elseif nTotal > tonumber(DB.getValue(rTarget.sCTNode .. ".defence")) then
				sHitResult = "Miss!";
			end 
		end
		
		else
			sHitResult = "No Target!";
		end	


	Debug.console("sHitResult: ", sHitResult);
	Debug.console("rTarget: ", rTarget);

  if rTarget ~= nil then
    sHitResult = sHitResult .. "\nvs "..rTarget.sName;
  end
	
  rRoll.aTotal = nTotal;
--  rRoll.aThac0 = thac0;
  rRoll.aHitResult = sHitResult;
  return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll, rTarget)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll, rTarget);

  
    rMessage.text = rMessage.text .. "\n[Attack] " .. rRoll.aTotal .. "\n" .. rRoll.aHitResult;

    rMessage.dicedisplay = 1; -- don't display total
  
    rMessage.text = rMessage.text;
  
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll a set of dice, removing a number of the lowest results.\n"; 
  rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the number of results to be dropped "; 
  rMessage.text = rMessage.text .. "by supplying the \"/rolld\" command with parameters in the format of \"#d#x#\", where the first # is the "; 
  rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
  rMessage.text = rMessage.text .. "x being the number of results to be dropped.\n"; 
  rMessage.text = rMessage.text .. "If no parameters are supplied, the default parameters of \"4d6x1\" are used."; 
  Comm.deliverChatMessage(rMessage);
end
