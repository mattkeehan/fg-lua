--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
  CustomDiceManager.add_roll_type("mutant", performAction, onMutant, false, false)
  ActionsManager.registerModHandler("mutant", modMutant);
  if DicePool ~= nil then
    DicePool.setType("mutant");
  end
end

function processMutant(sCommand, sParams)
local rActor = nil;
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
  performAction(sCommand, rActor, sParams);
end

function performAction(sCommand, rActor, sParams)  

  local sDice, sDesc = string.match(sParams, "%s*(%S+)%s*(.*)");
  
  if not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /mutant [dice] [description]");
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
  
  local rRoll = { sType = "mutant", sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
  ActionsManager.actionDirect(nil, "mutant", { rRoll });
end

function modMutant(rSource, rTarget, rRoll)
--  Debug.console("modDice: ", rRoll);
  for cnt=1, #rRoll.aDice do
    if rRoll.aDice[cnt] == "d066" then
      rRoll.aDice[cnt] = "d6";
      table.insert(rRoll.aDice, "d6");
    elseif rRoll.aDice[cnt] == "d0666" then
      rRoll.aDice[cnt] = "d6";
      table.insert(rRoll.aDice, "d6");
      table.insert(rRoll.aDice, "d6");
    end
  end
end

local pushing = false;
local reRollDice = nil;
local reRollActor = nil;
local aSavedDice = nil;

function onMutant(rSource, rTarget, rRoll)
--Debug.console("onDice: ", rRoll);

  if pushing and aSavedDice ~= nil then
    for cnt=1, #aSavedDice do
      table.insert(rRoll.aDice, aSavedDice[cnt]);
    end
    aSavedDice = nil;
  end
  aSavedDice = {};
  reRollDice = {};
  reRollDice.aDice = {};
  reRollDice.nMod = 0;
  reRollDice.sType = rRoll.sType;
  reRollDice.sDesc = rRoll.sDesc;
  reRollActor = rSource;


--  Debug.console("onDice: ", rRoll);
  for cnt=1, #rRoll.aDice do
    if rRoll.aDice[cnt].type == "d061" then
      -- BaseDice
      if rRoll.aDice[cnt].result > 1 and rRoll.aDice[cnt].result < 6 then
        table.insert(reRollDice.aDice, rRoll.aDice[cnt].type);
      else
        local die = {};
        die.type = rRoll.aDice[cnt].type;
        die.result = rRoll.aDice[cnt].result
        table.insert(aSavedDice, die);
      end
      rRoll.aDice[cnt].type = "d6y"..rRoll.aDice[cnt].result;
      rRoll.aDice[cnt].result = 0;
    elseif rRoll.aDice[cnt].type == "d062" then
      -- SkillDice
      if rRoll.aDice[cnt].result < 6 then
        local die = {}
        die.type = rRoll.aDice[cnt].type;
        table.insert(reRollDice.aDice, die.type);
      else
        local die = {};
        die.type = rRoll.aDice[cnt].type;
        die.result = rRoll.aDice[cnt].result
        table.insert(aSavedDice, die);
      end
      rRoll.aDice[cnt].type = "d6g"..rRoll.aDice[cnt].result;
      rRoll.aDice[cnt].result = 0;
    elseif rRoll.aDice[cnt].type == "d063" then
      -- BaseDice
      if rRoll.aDice[cnt].result > 1 and rRoll.aDice[cnt].result < 6 then
        local die = {}
        die.type = rRoll.aDice[cnt].type;
        table.insert(reRollDice.aDice, die.type);
      else
        local die = {};
        die.type = rRoll.aDice[cnt].type;
        die.result = rRoll.aDice[cnt].result
        table.insert(aSavedDice, die);
      end
      rRoll.aDice[cnt].type = "d6b"..rRoll.aDice[cnt].result;
      rRoll.aDice[cnt].result = 0;
    elseif (rRoll.aDice[cnt].type == "d6") and (cnt < #rRoll.aDice-1) and (rRoll.aDice[cnt+1].type == "d6") and (rRoll.aDice[cnt+2].type == "d6") then
      rRoll.aDice[cnt].result = rRoll.aDice[cnt].result * 100;
    elseif (rRoll.aDice[cnt].type == "d6") and (cnt < #rRoll.aDice) and (rRoll.aDice[cnt+1].type == "d6") then
      rRoll.aDice[cnt].result = rRoll.aDice[cnt].result * 10;
    end
--   Debug.console("onDice: ", rRoll.aDice[cnt])
  end

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  Comm.deliverChatMessage(rMessage);

  if pushing then
    reRollDice = nil;
    aSavedDice = nil;
    pushing = false;
  end
end

function onPushRoll()
-- Debug.console("onPushRoll: ", reRollDice, aSavedDice);
  if reRollDice ~= nil and ((#reRollDice.aDice > 0) or (#aSavedDice > 0)) then
    pushing = true;
    reRollDice.sDesc = "[PUSH] " .. reRollDice.sDesc;
    ActionsManager.performAction(nil, reRollActor, reRollDice);
    reRollDice = nil;
  end
end