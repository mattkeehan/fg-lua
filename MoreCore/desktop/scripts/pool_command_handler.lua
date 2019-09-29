--
-- DICE POOL SLASH HANDLERS
--

-- Initialization
function onInit()
  CustomDiceManager.add_roll_type("pool", processDie, nil, false, false)
  CustomDiceManager.add_roll_type("pooltype", processPoolType, nil, false, false)
  CustomDiceManager.add_roll_type("rollpool", processRollPool, nil, false, false)
end

function performAction(roll_type, draginfo, rActor, sParams)
  local roll_type_record = roll_types[roll_type];
  if roll_type_record then
    local perform_action = roll_type_record.perform_action;
    if perform_action then
      return perform_action(draginfo, rActor, sParams);
    end
  end
end

function processRollPool(draginfo, rActor, sParams)
  DicePool.roll();
end

function processPoolType(draginfo, rActor, sParams)
  if GameSystem.actions[sParams] == nil then
    ChatManager.SystemMessage("Usage: /pooltype [rolltype]");
  else
    DicePool.setType(sParams);
  end
end

function processDie(draginfo, rActor, sParams)
  if User.isHost() then
    if sParams == "reveal" then
      OptionsManager.setOption("REVL", "on");
      ChatManager.SystemMessage(Interface.getString("message_slashREVLon"));
      return;
    end
    if sParams == "hide" then
      OptionsManager.setOption("REVL", "off");
      ChatManager.SystemMessage(Interface.getString("message_slashREVLoff"));
      return;
    end
  end

  local sDice, sDesc = string.match(sParams, "%s*(%S+)%s*(.*)");
  
  if not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /pool [dice] [description]");
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

  if DicePool.isEnabled() then
    DicePool.addSlotAsDice(sDesc, aFinalDice);
    if nMod > 0 then
      ModifierStack.addSlot("", nMod);
    end
  else
    local rRoll = { sType = "dice", sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
    ActionsManager.actionDirect(nil, "dice", { rRoll });
  end
end