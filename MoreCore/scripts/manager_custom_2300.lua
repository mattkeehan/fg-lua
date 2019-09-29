-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "ad2300"
function onInit()
  CustomDiceManager.add_roll_type("ad2300", performAction, onLanded, true, "all");
end


function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  if sDice == nil then
    ChatManager.SystemMessage("Usage: /ad2300 [dice+modifier] [description]");
    return;
  else
    sDice = sDice;
  end

  if not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /ad2300 [dice+modifier] [description]");
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
  
  local rRoll = { sType = "ad2300", sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
  Debug.console("performAction: ", draginfo, rActor, rRoll);
  
  ActionsManager.performAction(draginfo, rActor, rRoll);
end   



function onLanded(rSource, rTarget, rRoll)
Debug.console("onLanded: ", rSource, rTarget, rRoll);
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  local bIsSourcePC = (rSource and rSource.sType == "pc");

  
  local nTotal = rRoll.nMod;
  Debug.console("nTotal1: ", nTotal)
  nTotal = nTotal + rRoll.aDice[1].result;
  Debug.console("nTotal2: ", nTotal)
  if nTotal >= 18 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Success vs Impossible (+FDRS)] ".. nTotal;
  elseif nTotal >= 14 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Success vs Formidable (+DRS)] ".. nTotal;
  elseif nTotal >= 10 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Success vs Difficult (+RS)] ".. nTotal;
  elseif nTotal >= 6 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Success vs Routine (+S)] ".. nTotal;
  elseif nTotal >= 2 then
    rMessage.text = "\n" .. rMessage.text .. "\n[Success vs Simple Only] ".. nTotal;
  else
    rMessage.text = "\n" .. rMessage.text .. "\n[Failure] ".. nTotal;
  end
  if rTarget then
    rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
  end

  Comm.deliverChatMessage(rMessage);
end