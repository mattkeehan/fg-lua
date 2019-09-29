-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "crit";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  if not sParams or sParams == "" then 
    sParams = "1d20c20";
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
	Debug.console("rRoll.sDesc: ", rRoll.sDesc);


  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	Debug.console("Preflightcheck: ", rRoll.sDesc);
  if not sDicePattern:match("(%d+)d([%dF]*)c(%d+)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#c#\" ";
    return rRoll;
  end

  local sDice, sCrit = sDicePattern:match("(%d+d[%dF]+)c(%d+)");
	
  local nCrit = tonumber(sCrit);
	Debug.console("sDicePattern: ", sDicePattern);
	Debug.console("nCrit 1st timer: ", nCrit);

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
  
  local rRoll = { sType = sCmd, sDesc = sDesc, aDice = aFinalDice, nMod = nMod, nCrit = tonumber(nCrit) };
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

  local nCrit = tonumber(rRoll.nCrit);
	Debug.console("nCrit (dropresults): ", nCrit);
	
	
    for _,v in ipairs(rRoll.aDice) do
	Debug.console("v.result: ", v.result);
	nTotal = nTotal + v.result;
	nDieRoll = v.result;
	Debug.console("rRoll.nMod 1: ", rRoll.nMod);
	end
	---nTotal = nTotal + rRoll.nMod;
	---rRoll.nMod = - rRoll.nMod;
	---nCrit = nCrit + rRoll.nMod;
	nTotalResult = nTotal + rRoll.nMod;
	
 	Debug.console("rRoll.aOp: ", rRoll.aOp);

	Debug.console("rRoll.nMod 1a: ", rRoll.nMod);



	if nDieRoll >= nCrit then
		Debug.console("Critical: ", nDieRoll);
		sCritResult = "Critical Success";
		elseif nDieRoll == 1 then
			Debug.console("Criticial Failure: ", nDieRoll);
			sCritResult = "Critical Failure";
		else sCritResult = "Result";
		end

	Debug.console("sCritResult: ", sCritResult);

  rRoll.aTotal = nTotal + rRoll.nMod;
  rRoll.aCrit = nCrit;
  rRoll.aCritResult = sCritResult;
  return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

  
	rMessage.text = rMessage.text .. "\n[" .. rRoll.aCritResult .. "] " .. rRoll.aTotal;
    rMessage.dicedisplay = 1; --  display total
  
    rMessage.text = rMessage.text;

  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll a set of dice, comparing the result against a target number.\n"; 
  rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the number to be rolled against "; 
  rMessage.text = rMessage.text .. "by supplying the \"/rolld\" command with parameters in the format of \"#d#<>#\", where the first # is the "; 
  rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
  rMessage.text = rMessage.text .. "x being the number to be rolled against - being either '<' for lower or '>' for higher.\n"; 
  rMessage.text = rMessage.text .. "If no parameters are supplied, the default parameters of \"1d20<11\" are used."; 
  Comm.deliverChatMessage(rMessage);
end
