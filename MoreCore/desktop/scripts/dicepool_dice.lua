-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onClickDown(button, x, y)
	if button == 2 then
		DicePool.reset();
		return true;
	end
end

function onDrop(x, y, draginfo)
Debug.console("onDrop: ", draginfo);
	return window.base.onDrop(x, y, draginfo);
end

function onDragStart(button, x, y, draginfo)
	-- Create a composite drag type so that a simple drag into the chat window won't use the modifiers twice
	draginfo.setType(DicePool.getType());
	draginfo.setDescription(DicePool.getDescription());
	draginfo.setDieList(DicePool.getAllDice());
  draginfo.setStringData(DicePool.getDescription());

	local basedata = draginfo.createBaseData(DicePool.getType());
	basedata.setDescription(DicePool.getDescription());
	basedata.setDieList(DicePool.getAllDice());
	basedata.setStringData(DicePool.getDescription());
	
	return true;
end

function onDragEnd(draginfo)
	DicePool.reset();
end

function onDoubleClick(x,y)
  if DicePool.isEmpty() then
    return;
  end
  local rRoll = { sType = DicePool.getType(), sDesc = DicePool.getDescription(), aDice = DicePool.getAllDice(), nMod = 0 };
  ActionsManager.performAction(nil, nil, rRoll);
  DicePool.reset();
end