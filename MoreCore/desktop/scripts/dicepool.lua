-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local control = nil;
slots = {};
dicekeys = {};
local rollType = "dice";

local nLocked = 0;
local bLockReset = false;
local aDiceUsed = {};

function roll()
  if control then
    control.dice.onDoubleClick();
  end
end

function setType(type)
Debug.console("DicePool.setType: ", type);
  rollType = type;
end

function getType()
  return rollType;
end

function getDiceKey(sButton)
  local bState = dicekeys[sButton];
  
  if nLocked > 0 then
    aDiceUsed[sButton] = true;
  else
    if bState then
      setDiceKey(sButton, false, true);
    end
  end
  
  return bState;
end

function setDiceKey(sButton, bState, bUpdateWnd)
  if not sButton then
    return;
  end
  if sButton == "" then
    return;
  end
  
  dicekeys[sButton] = bState;
  
  if bUpdateWnd then
    local wndMod = Interface.findWindow("dicepool", "");
    if wndMod and wndMod[sButton] then
      if bState then
        wndMod[sButton].setValue(1);
      else
        wndMod[sButton].setValue(0);
      end
    end
  end
end

function registerControl(ctrl)
  control = ctrl;
  
  activate();
end

function activate()
  OptionsManager.registerCallback("TPOOL", update);

  update();
end

function update()
  if control then
    if OptionsManager.isOption("TPOOL", "off") then
      control.base.setVisible(false);
      control.label.setVisible(false);
      control.enabled.setVisible(false);
      control.enabled.setValue(0);
    else
      control.base.setVisible(true);
      control.label.setVisible(true);
      control.enabled.setVisible(true);
      control.enabled.setValue(1);
    end
  end
end

function updateControl()

  if control then
    control.label.setValue(Interface.getString("dicepool_label_dicepool"));
    control.dice.reset();
    local dice = getAllDice();
    for _,v in ipairs(dice) do
      control.dice.addDie(v);
    end
      
    control.base.resetCounters();
    for i = 1, #slots do
      control.base.addCounter();
    end
    
    if hoverslot and hoverslot ~= 0 and slots[hoverslot] then
      control.label.setValue(slots[hoverslot].description);
    end
  end
end

function isEmpty()
  if  #slots == 0 then
    return true;
  end

  return false;
end

function getAllDice()
  local all = {};
  
  for i = 1, #slots do
--Debug.console("getAllDice ", i, slots[i].description, slots[i].dice);
    local dice = slots[i].dice;
    for k,v in ipairs(dice) do
--Debug.console("getAllDice ", i, k, v);
      table.insert(all, v.type);
    end
  end
  
  return all;
end

function getDescription(forcebonus)
  local s = "";
  
  if not forcebonus and #slots == 1 then
--Debug.console("getDescription ", slots[1].description);
    s = slots[1].description;
  else
    local aDice = {};
    
    for i = 1, #slots do
--Debug.console("getDescription ", i, slots[i].description);
       if slots[i].description ~= "" then
         table.insert(aDice, slots[i].description);
       end
    end
    
    s = table.concat(aDice, ", ");
  end
  
  return s;
end


function addSlotAsDice(description, dice)
Debug.console("addSlot: ",description, dice);
  local aDice = {};
  if #slots < 6 then
    for _,d in ipairs(dice) do
      table.insert(aDice, {type = d});
    end
    table.insert(slots, { ['description'] = description, ['dice'] = aDice });
  end
  
  updateControl();
end

function addSlot(description, dice)
Debug.console("addSlot: ",description, dice);
  if #slots < 6 then
    table.insert(slots, { ['description'] = description, ['dice'] = dice });
  end
  
  updateControl();
end

function removeSlot(number)
  table.remove(slots, number);
  updateControl();
end

function reset()
  slots = {};
  updateControl();
end

function hoverDisplay(n)
  hoverslot = n;
  updateControl();
end

function getStack(forcebonus)
  local sDesc = "";
  local aDice = {};
  
  if not isEmpty() then
    sDesc = getDescription(forcebonus);
    aDice = getAllDice();
  end

  if nLocked == 0 then
    reset();
  end
  
  return sDesc, aDice;
end

-- Lock handling
-- Used to keep the Dice stack from being cleared when making multiple rolls (i.e. full attack)
function lock()
  if nLocked == 0 then
    bLockReset = false;
  end
  nLocked = nLocked + 1;
end

function unlock(bReset)
  nLocked = nLocked - 1;
  if nLocked < 0 then
    nLocked = 0;
  end
  if bReset then
    bLockReset = bLockReset or bReset;
  end
    
  if nLocked == 0 and bLockReset then
    reset();

    for k,_ in pairs(aDiceUsed) do
      setDiceKey(k, false, true);
    end
    aDiceUsed = {};
  end
end

function isEnabled()
  if control then
    return (control.enabled.getValue() == 1);
  end
  return false;
end

function onInit()
  Comm.registerSlashHandler("pool", processPool);

  OptionsManager.registerOption2("TPOOL", false, "option_header_game", "option_label_TPOOL", "option_entry_cycler", 
      { labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" });
end

function processPool(sCommand, sParams)
  local sDice, sDesc = string.match(sParams, "%s*(%S+)%s*(.*)");
  
  if not StringManager.isDiceString(sDice) then
    SystemMessage("Usage: /pool [dice] [description]");
    return;
  end
  
  local aDice, nMod = StringManager.convertStringToDice(sDice);
  
  local aRulesetDice = Interface.getDice();
  local aFinalDice = {};
  local aNonStandardResults = {};
  for k,v in ipairs(aDice) do
    if StringManager.contains(aRulesetDice, v) then
      table.insert(aFinalDice, { type = v } );
    elseif v:sub(1,1) == "-" and StringManager.contains(aRulesetDice, v:sub(2)) then
      table.insert(aFinalDice, { type = v });
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
  
  addSlot(sDesc, aFinalDice);
  if nMod > 0 then
    ModifierStack.addSlot("", nMod);
  end
end