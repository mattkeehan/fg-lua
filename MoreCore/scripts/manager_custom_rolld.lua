-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "rolld";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  if not sParams or sParams == "" then 
    sParams = "4d6x1";
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
  rRoll = dropDiceResults(rRoll);
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

  -- If no number to drop is specified, we will assume it is 0
  if(not sParams:match("(%d+)d([%dF]*)x(%d+)%s*(.*)") and sParams:match("(%d+)d([%dF]+)%s*(.*)")) then
    sDicePattern = sDicePattern .. "x0"
  end
  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
  if not sDicePattern:match("(%d+)d([%dF]*)x(%d+)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#x#\"";
    return rRoll;
  end

  local sNum, sSize, sDrop = sDicePattern:match("(%d+)d([%dF]+)x(%d+)");
  local count = tonumber(sNum);
  local drop = tonumber(sDrop);

  if (drop > count) then
    rRoll.sDesc = "You cannot drop more results than the number of dice being rolled.";
    return rRoll;
  end

  while count > 0 do
    table.insert(rRoll.aDice, "d" .. sSize);
    
    -- For d100 rolls, we also need to add a d10 dice for the ones place
    if sSize == "100" then
      table.insert(rRoll.aDice, "d10");
    end
    count = count - 1;
  end
  
  rRoll.nDrop = drop;

  return rRoll;
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function dropDiceResults(rRoll)
  if #(rRoll.aDice) < 2 then return rRoll end
  local len = #(rRoll.aDice) or 0;
  local drop = tonumber(rRoll.nDrop) or 0;
  local dropped = {};
  local kept = {};
  
  table.sort(rRoll.aDice, function(a,b) return a.result < b.result end);
  local count = 1;
  while count <= len do
    if count <= drop then
      table.insert(dropped, rRoll.aDice[count]);
    else
      table.insert(kept, rRoll.aDice[count]);
    end
    count = count + 1;
  end

  rRoll.aDice = kept;
  rRoll.aDropped = dropped;
  return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  if #(rRoll.aDice) > 0 then
    rMessage.text = rMessage.text .. "\n[KEPT]";
    for _,v in ipairs(rRoll.aDice) do
      rMessage.text = rMessage.text .. " " .. v.result;
    end
  end
  if #(rRoll.aDice) > 0 and #(rRoll.aDropped) > 0 then
    rMessage.text = rMessage.text .. "\n";
  end
  if #(rRoll.aDropped) > 0 then
    rMessage.text = rMessage.text .. "[DROPPED]";
    for _,v in ipairs(rRoll.aDropped) do
      rMessage.text = rMessage.text .. " " .. v.result;
    end
  end
  
    rMessage.text = rMessage.text;

  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll a set of dice, removing a number of the lowest results.\n"; 
  rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the number of results to be dropped "; 
  rMessage.text = rMessage.text .. "by supplying the \"/rolld\" command with parameters in the format of \"#d#x#\", where the first # is the "; 
  rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
  rMessage.text = rMessage.text .. "x being the number of results to be dropped.\n"; 
  rMessage.text = rMessage.text .. "If no parameters are supplied, the default parameters of \"4d6x1\" are used."; 
  Comm.deliverChatMessage(rMessage);
end
