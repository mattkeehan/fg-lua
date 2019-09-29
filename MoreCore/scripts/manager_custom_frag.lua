-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "frag"
function onInit()
  CustomDiceManager.add_roll_type("frag", performAction, onLanded, true, "all");
end

function orderDiceResults(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
    table.sort(rRoll.aDice, function(a,b) return a.result>b.result end)
  
  return rRoll;
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  if sDice == nil then
    ChatManager.SystemMessage("Usage: /frag [dice+modifier] [description]");
    return;
  else
    sDice = sDice;
  end

  if not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /frag [dice+modifier] [description]");
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
  
  local rRoll = { sType = "frag", sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
  Debug.console("performAction: ", draginfo, rActor, rRoll);
  
  ActionsManager.performAction(draginfo, rActor, rRoll);
end   



function onLanded(rSource, rTarget, rRoll)
Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  local bIsSourcePC = (rSource and rSource.sType == "pc");

 
  local aDice = rRoll.aDice;


  local nTotal = rRoll.nMod;
  Debug.console("nTotal1: ", nTotal)
  Debug.console("rRoll: ", rRoll)

  
  for i , v in ipairs (aDice) do
    Debug.console("onLanded: last dice ", i, v);
    nTotal = nTotal + v.result;
  end


  Debug.console("nTotal2: ", nTotal)
  if nTotal >= 18 then
    rMessage.text = "\n" .. rMessage.text .. "\nImpossible Success! (EMDI) ";
  elseif nTotal >= 16 then
    rMessage.text = "\n" .. rMessage.text .. "\nDifficult Success (+EM) ";
  elseif nTotal >= 12 then
    rMessage.text = "\n" .. rMessage.text .. "\nModerate Success (+E) ";
  elseif nTotal >= 8 then
    rMessage.text = "\n" .. rMessage.text .. "\nEasy Success Only";
  else
    rMessage.text = "\n" .. rMessage.text .. "\nFailure";
  end
  if rTarget then
    rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
  end

  Comm.deliverChatMessage(rMessage);
end