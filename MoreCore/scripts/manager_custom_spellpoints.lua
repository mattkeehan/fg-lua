-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "gumshoe"

local sCmd = "spellpoints";

function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
--	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
end

function performAction(draginfo, rActor, sParams)
Debug.console("performAction: ", draginfo, rActor, sParams);

	local rRoll = {};
	rRoll.sType = sCmd;
	rRoll.nMod = 0;
	local sSpellCost, sSpellName = sParams:match("(%d+)%s*(.*)");
--	Debug.chat("sSpellCost: ", sSpellCost, " sSpellName: ", sSpellName);
	local nodeWin = rActor.sCreatureNode;
	local sName = rActor.sName;
	local sModDesc, nMod = ModifierStack.getStack(true);
	local nTotalCost = tonumber(sSpellCost) + nMod;

	rRoll.sDesc = sSpellName;
	rRoll.nTotalCost = nTotalCost;
	rRoll.sModDesc = sModDesc;
--	Debug.chat("rRoll: ", rRoll);

--	Debug.console("performAction: ", rRoll);
 
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 0; -- display total


	local nSpellMax = tonumber(DB.getValue(nodeWin .. ".spells.max"));
--	Debug.chat("nSpellMax: ", nSpellMax);
	local nSpellCur = DB.getValue(nodeWin .. ".spells.cur");
	
	if nSpellMax == "nil" or nSpellMax == 0 then
		rMessage.text = sName .. " uses " .. rMessage.text .. " " .. rRoll.sModDesc;
		else if nSpellCur >= nTotalCost then
		rMessage.text = sName .. " uses " .. rMessage.text .. " " .. rRoll.sModDesc .. " (cost " .. nTotalCost .. ")";
		nSpellCur = nSpellCur - nTotalCost;
--		Debug.chat("nSpellCur: ", tonumber(nSpellCur)); 
		DB.setValue(nodeWin .. ".spells.cur", "number", tonumber(nSpellCur));
		else
		rMessage.text = sName .. " has insufficient power to use " .. rMessage.text;
		end
	end

	rMessage.text = rMessage.text .. rRoll.sModDesc;
	Comm.deliverChatMessage(rMessage);
	end   



