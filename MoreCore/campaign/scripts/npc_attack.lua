-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- NPC_ATTACK.LUA supports the Targetting and adding Attacker and Defender names to the Chat Window
-- File is largely a port of npc_roll.lua from CoreRPG

local bParsed = false;
local aComponents = {};

local bClicked = false;
local bDragging = false;
local nDragIndex = nil;

function parseComponents()
  aComponents = {};
  
  -- Get the comma-separated strings
  local aClauses, aClauseStats = StringManager.split(getValue(), ",;\r", true);
  
  -- Check each comma-separated string for a potential skill roll or auto-complete opportunity
  for i = 1, #aClauses do
    local nStarts, nEnds, sMod = string.find(aClauses[i], "([d%dF%+%-]+)%s*$");
 --   local nStarts, nEnds, sMod = string.find(aClauses[i], "([%-%+]?)(%d+)d?([%dF]*)");
    if nStarts then
      local sLabel = "";
      if nStarts > 1 then
        sLabel = StringManager.trim(aClauses[i]:sub(1, nStarts - 1));
      end
      local aDice, nMod = StringManager.convertStringToDice(sMod);
      
      -- Insert the possible skill into the skill list
      table.insert(aComponents, {nStart = aClauseStats[i].startpos, nLabelEnd = aClauseStats[i].startpos + nEnds, nEnd = aClauseStats[i].endpos, sLabel = sLabel, aDice = aDice, nMod = nMod });
    end
  end
  
  bParsed = true;
end

function onValueChanged()
  bParsed = false;
end

-- Reset selection when the cursor leaves the control
function onHover(bOnControl)
  if bOnControl then
    return;
  end

  if not bDragging then
    onDragEnd();
  end
end

-- Hilight skill hovered on
function onHoverUpdate(x, y)
  if bDragging or bClicked then
    return;
  end

  if not bParsed then
    parseComponents();
  end
  local nMouseIndex = getIndexAt(x, y);

  for i = 1, #aComponents, 1 do
    if aComponents[i].nStart <= nMouseIndex and aComponents[i].nEnd > nMouseIndex then
      setCursorPosition(aComponents[i].nStart);
      setSelectionPosition(aComponents[i].nEnd);

      nDragIndex = i;
      setHoverCursor("hand");
      return;
    end
  end
  
  nDragIndex = nil;
  setHoverCursor("arrow");
end

function getActor()
  local nodeActor = nil;
  local node = getDatabaseNode();
  if node then
    nodeActor = node.getChild("..");
  end
  
  return ActorManager.getActor("..", nodeActor);
end

function action(draginfo)
  local rActor = getActor();
  local poolType = DicePool.getType();
  if poolType == "dice" then
    poolType = "attack";
  end
  if nDragIndex then
    local nMod = aComponents[nDragIndex].nMod
    local sDesc = aComponents[nDragIndex].sLabel;
    local aFinalDice = aComponents[nDragIndex].aDice;
    if draginfo then
      if #(aComponents[nDragIndex].aDice) > 0 then
        if DicePool.isEnabled() then
          DicePool.addSlotAsDice(sDesc, aFinalDice);
          if nMod > 0 then
            ModifierStack.addSlot("", nMod);
          end
        else
          local rRoll = { sType = "attack", sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
          ActionsManager.performAction(draginfo, rActor, rRoll);
        end
      else
        draginfo.setType("number");
        draginfo.setDescription(sDesc);
        draginfo.setStringData(sDesc);
        draginfo.setNumberData(nMod);
      end
    else
      if #(aComponents[nDragIndex].aDice) > 0 then
        if DicePool.isEnabled() then
          DicePool.addSlotAsDice(sDesc, aFinalDice);
          if nMod > 0 then
            ModifierStack.addSlot("", nMod);
          end
        else
          local rRoll = { sType = poolType, sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
          ActionsManager.performAction(draginfo, rActor, rRoll);
        end
      else
        ModifierStack.addSlot(sDesc, nMod);
      end
    end
  end
end

function onDoubleClick(x, y)
  action();
  return true;
end

function onDragStart(button, x, y, draginfo)
  action(draginfo);

  bClicked = false;
  bDragging = true;
  
  return true;
end

function onDragEnd(draginfo)
  bClicked = false;
  bDragging = false;
  nDragIndex = nil;
  setHoverCursor("arrow");
  setCursorPosition(0);
  setSelectionPosition(0);
end

-- Suppress default processing to support dragging
function onClickDown(button, x, y)
  bClicked = true;
  return true;
end

-- On mouse click, set focus, set cursor position and clear selection
function onClickRelease(button, x, y)
  bClicked = false;
  setFocus();
  
  local n = getIndexAt(x, y);
  setSelectionPosition(n);
  setCursorPosition(n);
  
  return true;
end
