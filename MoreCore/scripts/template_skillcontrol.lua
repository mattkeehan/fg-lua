
slots = {};

max = 0;
maxcols = 1;
countnode = nil;

function on1Drag(button, x, y, dragdata)
  local desc = getName();
  if titlefield and titlefield[1] then
    desc = window[titlefield[1]].getValue();
  end
  if title and title[1] then
    desc = title[1];
  end
  dragdata.setType("number");
  dragdata.setNumberData(countnode.getValue());
  dragdata.setDescription(desc);
  return true;
end

local 1doubleclicked = false;
local oldvalue = 0;

function 1onClickDown(...)
  return true;
end

function onDoubleclick(x,y)
  countnode.setValue(oldvalue);
  else
    oldvalue = countnode.getValue();
    if Input.isControlPressed() then
      countnode.setValue(0);
		local msg = {font = "msgfont", icon = sTrackersIcon};
		local rActor = ActorManager.getActor("pc", window.getDatabaseNode().getParent().getParent());
		local nodeWin = window.getDatabaseNode();
		local sTrackersName = nodeWin.getChild("name").getValue();
		msg.text = rActor.sName .. " has reset " .. sTrackersName .. " (was " .. oldvalue .. ")";
		Comm.deliverChatMessage(msg);
		
    else
		if countnode.getValue() < tonumber(window.getDatabaseNode().getChild("number_trackers").getValue()) then
			if Input.isAltPressed() then
				txt1 = " (no spend)";
				else
				txt1 = " ";
				countnode.setValue(countnode.getValue() - 1);
				end
							local rActor = ActorManager.getActor("pc", window.getDatabaseNode().getParent().getParent());
							local nodeWin = window.getDatabaseNode();
							local sTrackersName = nodeWin.getChild("name").getValue();
							local sTrackersIcon = nodeWin.getChild("trackers_icon").getValue();
							local nSkillPoints = tonumber(window.getDatabaseNode().getChild("number_trackers").getValue());
							local msg = {font = "msgfont", icon = sTrackersIcon};
							msg.text = rActor.sName .. " is using " .. sTrackersName .. " (" .. countnode.getValue() .. " of " .. nSkillPoints .. ")" .. txt1;
								if Input.isShiftPressed() then
									ModifierStack.addSlot(sTrackersName, 1);
									msg.text = msg.text .. " (mod applied)";
									end
							Comm.deliverChatMessage(msg);
							else 
							local rActor = ActorManager.getActor("pc", window.getDatabaseNode().getParent().getParent());
							local nodeWin = window.getDatabaseNode();
							local sTrackersName = nodeWin.getChild("name").getValue();
							local nSkillPoints = tonumber(window.getDatabaseNode().getChild("number_trackers").getValue());
							local msg = {font = "msgfont", icon = sTrackersName};
							msg.text = rActor.sName .. " is out of " .. sTrackersName;
							Comm.deliverChatMessage(msg);
					end
				else
		local msg = {font = "msgfont", icon = sTrackersIcon};
		local rActor = ActorManager.getActor("pc", window.getDatabaseNode().getParent().getParent());
		local nodeWin = window.getDatabaseNode();
		local sTrackersName = nodeWin.getChild("name").getValue();
		msg.text = rActor.sName .. " has unspent 1 point of " .. sTrackersName .. ".";
		Comm.deliverChatMessage(msg);
        countnode.setValue(countnode.getValue() + 1);
      end
      checkBounds();
    end
  end
  updateSlots();
  return true;
end

function getValue()
  return countnode.getValue();
end

function setValue(count)
  countnode.setValue(count);
  checkBounds();
end

function updateSlots()
  -- Clear
  for k, v in ipairs(slots) do
    v.destroy();
  end
  
  slots = {};

  -- Construct based on values
  local c = countnode.getValue();

  local col = 0;
  local row = 0;

  for i = 1, max do
    local widget = nil;

    if i <= c then
      widget = addBitmapWidget(stateicons[1].on[1]);
    else
      widget = addBitmapWidget(stateicons[1].off[1]);
    end

    local posx = spacing[1].horizontal[1] * (col+0.5);
    local posy = spacing[1].vertical[1] * (row+0.5);
    widget.setPosition("topleft", posx, posy);
    
    col = col + 1;
    if col >= maxcols then
      col = 0;
      row = row + 1;
    end
    
    slots[i] = widget;
  end
end

function getSlotState(x, y)
  local c = countnode.getValue();

  local col = 0;
  local row = 0;
  
  local state = false;

  for i = 1, max do
    local widget = nil;

    if i <= c then
      state = true;
    else
      state = false;
    end

    local posx = spacing[1].horizontal[1] * col;
    local posy = spacing[1].vertical[1] * row;

    if x > posx and x < posx + spacing[1].horizontal[1] and
       y > posy and y < posy + spacing[1].vertical[1] then
      return state;
    end
    
    col = col + 1;
    if col >= maxcols then
      col = 0;
      row = row + 1;
    end
  end
  
  return state;
end

function checkBounds()
  if countnode.getValue() > max then
    countnode.setValue(max);
  elseif countnode.getValue() < 0 then
    countnode.setValue(0);
  end
end

function onMenuSelection(...)
  countnode.setValue(0);
  updateSlots();
end

function onInit()
	DB.addHandler(DB.getPath(window.getDatabaseNode(), "number_trackers"), "onUpdate", updateTrackerMax);
	updateTrackerMax();
	end

function onClose()
    DB.removeHandler(DB.getPath(window.getDatabaseNode(), "number_trackers"), "onUpdate", updateTrackerMax);
end
	
function updateTrackerMax()
  local nodename = getName();
--	Debug.console("nodename: ", nodename);
  local rows = 1;
  registerMenuItem("Clear", "erase", 4);
  
    max = 1;
	local nodeWin = window.getDatabaseNode();
--    Debug.console("nodeWin: ", nodeWin);
    max = tonumber(DB.getValue(nodeWin,"number_trackers",1));
--    Debug.console("max: ", DB.getValue(nodeWin,"number_trackers"));
--    Debug.console("max: ", max);


  
  if source and source[1] then
	Debug.console("source: ", source, source[1]);
    nodename = source[1];
  end
  
  rows = tonumber(rowcount[1]);
  if rows and max then
    maxcols = math.ceil(max/rows);
  end
  
  countnode = window.getDatabaseNode().getChild(nodename);
  if not countnode then
    countnode = window.getDatabaseNode().createChild(nodename,"number");
    countnode.setValue(tonumber(default[1]));
  end
  
  countnode.onUpdate = updateSlots;
  
  updateSlots();
end



