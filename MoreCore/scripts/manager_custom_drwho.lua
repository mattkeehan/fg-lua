-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "drwho"
function onInit()
  CustomDiceManager.add_roll_type("drwho", performAction, onLanded, true, "all");
end

function orderDiceResults(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
    table.sort(rRoll.aDice, function(a,b) return a.result>b.result end)
  
  return rRoll;
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sTarget, sDesc = string.match(sParams, "([^%s]+)x(%d+)%s*(.*)");
  if sDice == nil then
    ChatManager.SystemMessage("Usage: /drwho [dice+modifier'x'difficulty] [description]");
    return;
  else
    sDice = sDice;
  end

  if not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /drwho [dice+modifier'x'difficulty] [description]");
    return;
  end
  
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
    sDesc = string.format("%s (%s)", sDesc, sDice);
  else
    sDesc = sDice;
  end
  if #aNonStandardResults > 0 then
    sDesc = sDesc .. table.concat(aNonStandardResults, "");
  end
  
  local rRoll = { sType = "drwho", sDesc = sDesc, aDice = aFinalDice, nMod = nMod, sTarget = sTarget };
  Debug.console("performAction: ", draginfo, rActor, rRoll);
  
  ActionsManager.performAction(draginfo, rActor, rRoll);
end   



function onLanded(rSource, rTarget, rRoll)
Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  local bIsSourcePC = (rSource and rSource.sType == "pc");

  rRoll = orderDiceResults(rRoll);
  
  local nTotal = rRoll.nMod;
  local nTarget = tonumber(rRoll.sTarget);
  Debug.console("nTotal1: ", nTotal)
--  Debug.chat("nTarget: ", nTarget)
  nTotal = nTotal + rRoll.aDice[1].result + rRoll.aDice[2].result;
  Debug.console("nTotal2: ", nTotal)
  if nTarget >= 30 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Nearly Impossible";
  elseif nTarget >= 27 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Improbable";
  elseif nTarget >= 24 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Very Difficult";
  elseif nTarget >= 21 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Difficult";
  elseif nTarget >= 18 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Hard";
  elseif nTarget >= 15 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Tricky";
  elseif nTarget >= 12 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Normal";
  elseif nTarget >= 9 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Easy";
  elseif nTarget >= 6 then 
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Really Easy";
  else
    rMessage.text = "\n" .. rMessage.text .. "\n[Difficulty] Really, Really Easy";
	end
	
  if nTotal >= nTarget+9 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Roll Total] " .. nTotal .. "\n[Result] Success and something unexpected... ";
  elseif nTotal >= nTarget+4 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Roll Total] " .. nTotal .. "\n[Result] Success ... ";
  elseif nTotal >= nTarget then
    rMessage.text = "\n" .. rMessage.text .. "\n[Roll Total] " .. nTotal .. "\n[Result] Success but you didnt see that coming ... ";
  elseif nTotal >= nTarget-3 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Roll Total] " .. nTotal .. "\n[Result] Failure but it could have been worse ... ";
  elseif nTotal >= nTarget-8 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Roll Total] " .. nTotal .. "\n[Result] Failure ... ";
  else
    rMessage.text = "\n" .. rMessage.text .. "\n[Roll Total] " .. nTotal .. "\n[Result] Failure and it looks nasty ... ";
  end
  if rTarget then
    rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
  end

  Comm.deliverChatMessage(rMessage);
end
