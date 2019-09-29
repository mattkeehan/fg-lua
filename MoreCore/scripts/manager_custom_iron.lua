-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "iron"
function onInit()
  CustomDiceManager.add_roll_type("iron", performAction, onLanded, true, "all", nil, nil, onDiceTotal);
end

function orderDiceResults(rRoll)
  -- Sort rRoll.aDice table based off a.result (the dice result)
    table.sort(rRoll.aDice, function(a,b) return a.result>b.result end)
  
  return rRoll;
end

function onDiceTotal( messagedata )
	Debug.console("onDiceTotal: ", messagedata);
	local diceRolled = 0;
	for Index, Value in pairs(messagedata.dice) do
			diceRolled = diceRolled + 1
	end

	if diceRolled == 3 then
			return true, (messagedata.dice[3].result + messagedata.diemodifier);
	elseif diceRolled == 4 then
			return true, (messagedata.dice[3].result + messagedata.dice[4].result + messagedata.diemodifier);
	else
			return true, 0;
	end
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);
  local sDice, sDesc = string.match(sParams, "([^%s]+)%s*(.*)");
  if sDice == nil then
    ChatManager.SystemMessage("Usage: /iron [challenge+dice+modifier] [description]");
    return;
  else
    sDice = sDice;
  end

  if not StringManager.isDiceString(sDice) then
    ChatManager.SystemMessage("Usage: /iron [challenge+dice+modifier] [description]");
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
  
  local rRoll = { sType = "pbta", sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
  Debug.console("performAction: ", draginfo, rActor, rRoll);
  
  ActionsManager.performAction(draginfo, rActor, rRoll);
end   



function onLanded(rSource, rTarget, rRoll)
		Debug.console("onLanded: ", rSource, rTarget, rRoll);
		local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
		local bIsSourcePC = (rSource and rSource.sType == "pc");

		local diceRolled = 0
		for Index, Value in pairs(rRoll.aDice) do
				diceRolled = diceRolled + 1
		end

		if diceRolled == 3 then
				Debug.console("diceRolled: ", diceRolled);
				local nTotal = rRoll.nMod;
  			  	Debug.console("nTotal1: ", nTotal);
  			  	nTotal = nTotal + rRoll.aDice[3].result;
  			  	Debug.console("nTotal2: ", nTotal);
  			  	x1 = rRoll.aDice[1].result;
  			  	Debug.console("x1: ", x1);
  			  	x2 = rRoll.aDice[2].result;
  			  	Debug.console("x2: ", x2);
  			  	if ( nTotal >= x1 and nTotal >= x2 ) then
  			  			rMessage.text = "\n" .. rMessage.text .. "\n[Strong Hit] ".. nTotal;
  			  	elseif (( nTotal >= x1 and nTotal < x2 ) or (nTotal >= x2 and nTotal < x1)) then
  			  			rMessage.text = "\n" .. rMessage.text .. "\n[Weak Hit] ".. nTotal;
  			  	else
  			  			rMessage.text = "\n" .. rMessage.text .. "\n[Miss] ".. nTotal;
  			  	end
  			  	if rTarget then
  			  			rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
  			  	end
  			  	Comm.deliverChatMessage(rMessage);
		elseif diceRolled == 4 then
                Debug.console("diceRolled: ", diceRolled);
                local nTotal = rRoll.nMod;
                Debug.console("nMod: ", nTotal);
                nTotal = nTotal + rRoll.aDice[3].result + rRoll.aDice[4].result;
                Debug.console("nTotal: ", nTotal);
                local x1 = rRoll.aDice[1].result;
                Debug.console("x1: ", x1);
                local x2 = rRoll.aDice[2].result;
                Debug.console("x2: ", x2);
                if ( nTotal >= x1 and nTotal >= x2 ) then
                        rMessage.text = "\n" .. rMessage.text .. "\n[Strong Hit] ".. nTotal;
                elseif (( nTotal >= x1 and nTotal < x2 ) or (nTotal >= x2 and nTotal < x1)) then
                        rMessage.text = "\n" .. rMessage.text .. "\n[Weak Hit] ".. nTotal;
                else
                        rMessage.text = "\n" .. rMessage.text .. "\n[Miss] ".. nTotal;
                end
                if rTarget then
                        rMessage.text = rMessage.text .. "\nvs "..rTarget.sName;
                end
                Comm.deliverChatMessage(rMessage);

  		else
				rMessage.dicedisplay = 0;
  			  	rMessage.text = "\n" .. rMessage.text .. "\nIronsworn roller only implemented for dice rolls with three or four total dice. Valid (and working) dice strings: 2dX+1d100Y+Z or 2dX+2d100Y+Z. Value reported is dY+Z.";
  			  	Comm.deliverChatMessage(rMessage);
  		end
end
