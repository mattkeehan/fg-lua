-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerDiceMechanic("rollAndKeep", processExplodingDices, processRollAndKeepResult)
	registerDiceMechanic("rollAndKeepDamage", processExplodingDices, processRollAndKeepDamageResult)
	registerDiceMechanic("explodingDices", processExplodingDices, processDefaultResults)
	registerDiceMechanic("explodingDiceSuccesses", processExplodingDiceSuccesses, processDefaultSuccessesResults)
	registerDiceMechanic("rollAndKeepDamageKatana", processExplodingPlus, processRollAndKeepDamageResult)
	registerDiceMechanic("rollAndKeepEmphasis", processExplodingEmphasis, processRollAndKeepResult)	
	registerDiceMechanic("repeatingOnes", processOnes, processRollAndKeepResult)
	Comm.registerSlashHandler("rnk", onRollAndKeepSlashCommand)
	Comm.registerSlashHandler("rnkd", onRollAndKeepDamageSlashCommand)
	Comm.registerSlashHandler("edie", onExplodingDiceSlashCommand)
	Comm.registerSlashHandler("edies", onExplodingDiceSuccessesSlashCommand)
	Comm.registerSlashHandler("rnkdk", onRollAndKeepDamageKatanaSlashCommand)
	Comm.registerSlashHandler("rnke", onRollAndKeepEmphasisSlashCommand)
end

function rollAndKeep(sDescription, nDices, nKeep)

	local aDices = {}
	for i=1, tonumber(nDices) do
		table.insert(aDices, "d10")
	end

	local rThrow = {}
	rThrow.type = "rollAndKeep"
	local sRollAndKeepPattern = nDices .. "k" .. nKeep


	if not sDescription and sDescription == "" then
		rThrow.description = sRollAndKeepPattern
	else
		rThrow.description = sDescription .. " (" .. sRollAndKeepPattern .. ")"
	end
	rThrow.secret = false

	local rSlot = {}
	rSlot.dice = aDices
	rSlot.custom = { keep = nKeep }
	rThrow.slots = { rSlot }

	Comm.throwDice(rThrow)
end

function rollAndKeepDamage(sDescription, nDices, nKeep)
Debug.console("rollAndKeepDamage");


	local aDices = {}
	for i=1, tonumber(nDices) do
		table.insert(aDices, "d10")
	end

	local rThrow = {}
	rThrow.type = "rollAndKeepDamage"
	local sRollAndKeepPattern = nDices .. "k" .. nKeep


	if not sDescription and sDescription == "" then
		rThrow.description = sRollAndKeepPattern
	else
		rThrow.description = sDescription .. " (" .. sRollAndKeepPattern .. ")"
	end
	rThrow.secret = false

	local rSlot = {}
	rSlot.dice = aDices
	rSlot.custom = { keep = nKeep }
	rThrow.slots = { rSlot }

	Comm.throwDice(rThrow)
end


function onExplodingDiceSlashCommand(sCmd, sParam)
	if sParam then
		local sDieString = sParam
		local sDescription1 = sParam
		local nSeparationStart, nSeparationEnd = sParam:find("%s+")
		if nSeparationStart then
			sDieString = sParam:sub(1, nSeparationStart-1)
			sDescription1 = sParam:sub(nSeparationEnd+1)
		end
		
		local aDices, nMod = StringManager.convertStringToDice(sDieString)
	
		local rThrow = {}
		rThrow.type = "explodingDices"
		rThrow.description = sDescription1
		rThrow.secret = false
	
		local rSlot = {}
		rSlot.dice = aDices
		rSlot.number = nMod
		rSlot.custom = {}
		rThrow.slots = { rSlot }
	
		Comm.throwDice(rThrow)
	end
end

function onExplodingDiceSuccessesSlashCommand(sCmd, sParam)
	if sParam then
		local sDieString = sParam
		local sDescription1 = sParam
		local nSeparationStart, nSeparationEnd = sParam:find("%s+")
		if nSeparationStart then
			sDieString = sParam:sub(1, nSeparationStart-1)
			sDescription1 = sParam:sub(nSeparationEnd+1)
		end
		
	local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParam, "([^%s]+)%s*(.*)");
Debug.console("sParam117: ", sParam);
Debug.console("nStart: ", nStart);
Debug.console("nEnd: ", nEnd);
Debug.console("sDicePattern: ", sDicePattern);
Debug.console("sDescriptionParam: ", sDescriptionParam);
	local sNum, sSize, sSuccessLevel = sDicePattern:match("(%d+)d([%dF]+)x(%d+)");
Debug.console("sNum: ", sNum);
Debug.console("sSize: ", sSize);
Debug.console("sSuccessLevel: ", sSuccessLevel);
	local nSuccessLevel = tonumber(sSuccessLevel);
Debug.console("nSuccessLevel: ", nSuccessLevel);
	local sDesc, nMod = ModifierStack.getStack(true);

Debug.console("sDieString: ", sDieString);
		local aDices, nMod = StringManager.convertStringToDice(sDieString)
Debug.console("aDices: ", aDices);
Debug.console("nMod: ", nMod);
	
		local rThrow = {}
		rThrow.type = "explodingDiceSuccesses"
		rThrow.description = sDescription1
		rThrow.secret = false
	
		local rSlot = {}
		rSlot.dice = aDices
		rSlot.number = nMod
		rSlot.custom = { successlevel = tonumber(sSuccessLevel) }
    rThrow.slots = { rSlot }
	
Debug.console("throwDice: ");
		Comm.throwDice(rThrow)
	end
end

function onRollAndKeepSlashCommand(sCmd, sParam)
	if sParam then
		local sRnkPattern, sDescriptionParam = sParam:match("(%d+k%d+)%s*(.*)")
		if sRnkPattern then
			local sDescription = "Roll & Keep"
			if sDescriptionParam then
				sDescription = sDescriptionParam
			end
			local sDices, sKeep = sParam:match("^(%d+)k(%d+)")
			rollAndKeep(sDescription, tonumber(sDices), tonumber(sKeep))
		end
	end
end

function onRollAndKeepDamageSlashCommand(sCmd, sParam)
Debug.console("onRollAndKeepDamageSlashCommand");
	if sParam then
		local sRnkPattern, sDescriptionParam = sParam:match("(%d+k%d+)%s*(.*)")
		if sRnkPattern then
			local sDescription = "Roll & Keep Damage"
			if sDescriptionParam then
				sDescription = sDescriptionParam
			end
			local sDices, sKeep = sParam:match("^(%d+)k(%d+)")
			rollAndKeepDamage(sDescription, tonumber(sDices), tonumber(sKeep))
		end
	end
end

local aDiceMechanicHandlers = {}
local aDiceMechanicResultHandlers = {}
function registerDiceMechanic(sDiceMechanicType, callback, callbackResults)
	aDiceMechanicHandlers[sDiceMechanicType] = callback
	if callbackResults then
		aDiceMechanicResultHandlers[sDiceMechanicType] = callbackResults
	end
end
function unregisterDiceMechanic(sDiceMechanicType)
	if aDiceMechanicHandlers then
		aDiceMechanicHandlers[sDiceMechanicType] = nil
		aDiceMechanicResultHandlers[sDiceMechanicType] = nil
	end
end

function onDiceLanded(draginfo)
	local sDragType = draginfo.getType()
	local bProcessed = false
	local bPreventProcess = false
	
	local rCustomData = draginfo.getCustomData() or {}
	
	-- dice handling
	for sType, fCallback in pairs(aDiceMechanicHandlers) do
		if sType == sDragType then
			bProcessed, bPreventProcess = fCallback(draginfo)
		end
	end
	
	-- results
	if not bPreventProcess then
		for sType, fCallback in pairs(aDiceMechanicResultHandlers) do
			if sType == sDragType then
				fCallback(draginfo)
			end
		end
	end
	
	return bProcessed
end

function decodeDiceResults(sSource)
	if not sSource then
		return {}
	end
	local aDieResults = {}
	local nIndex = 0
	while nIndex do
		local nStartIndex, nNextIndex = sSource:find("^d%d+:%d+:%d;", nIndex)
		if nNextIndex then
			local sDieSource = sSource:sub(nStartIndex, nNextIndex-1)
			local sType, sResult, sExploded = sDieSource:match("^(d%d+):(%d+):(%d)")
			table.insert(aDieResults, { type = sType, result = tonumber(sResult), exploded = tonumber(sExploded) })
			nIndex = nNextIndex + 1
		else
			nIndex = nil 
		end
	end
	return aDieResults
end
	
function encodeDiceResults(aDieResults)
	local sDieResults = ""
	for _,rDie in pairs(aDieResults) do
		sDieResults = sDieResults .. rDie.type .. ":" .. rDie.result .. ":" .. rDie.exploded .. ";"
	end
	return sDieResults
end

function processExplodingDices(draginfo)

	local isMaxResult = function(rDie)
		if tonumber(rDie.type:match("^d(%d+)")) == rDie.result then
			return 1
		else
			return 0
		end
	end

	local newRoll = function(draginfo, aDieResults, rCustomData, aExplodedDices)		
		local rThrow = {}
		rThrow.type = draginfo.getType()
		rThrow.description = draginfo.getDescription()
		rThrow.secret = draginfo.getSecret()
		rThrow.shortcuts = {}

		local rSlot = {}
		rSlot.number = draginfo.getNumberData()
		rSlot.dice = aExplodedDices
		rSlot.custom = rCustomData
		rThrow.slots = { rSlot }
	
		Comm.throwDice(rThrow)
	end

	local rCustomData = draginfo.getCustomData() or {}	
	local nKeep = rCustomData.keep
	local aPreviousDieResults = decodeDiceResults(rCustomData.rollresults)
	local aNewDieResults = {}
	for _, rDie in pairs(draginfo.getDieList() or {}) do
		table.insert(aNewDieResults, {type = rDie.type, result = rDie.result, exploded = isMaxResult(rDie)})
	end
	
	local aDieResults = {}
	if #aPreviousDieResults < 1 then
		aDieResults = aNewDieResults
	else
		for _, rDie in pairs(aPreviousDieResults) do
			if rDie.exploded == 1 then
				for nIndex, rNewDie in pairs(aNewDieResults) do
					if rNewDie.type == rDie.type then
						rDie.result = rDie.result + rNewDie.result
						rDie.exploded = rNewDie.exploded
						table.remove(aNewDieResults, nIndex)
						break
					end
				end
			end
			table.insert(aDieResults, rDie)
		end
	end
	
	local aExplodedDices = {}
	for _, rDie in pairs(aDieResults) do
		if rDie.exploded == 1 then
			table.insert(aExplodedDices, rDie.type)
		end
	end
	
	if #aExplodedDices > 0 then
		local rCustomData = { keep = nKeep, rollresults = encodeDiceResults(aDieResults) }
		newRoll(draginfo, aDieResults, rCustomData, aExplodedDices)
		return true, true
	end
	
	rCustomData.rollresults = encodeDiceResults(aDieResults)
	draginfo.setCustomData(rCustomData)

	return true
end

function processExplodingDiceSuccesses(draginfo)

Debug.console("nextFunction: ");
Debug.console("draginfo: ", draginfo);

	local isMaxResult = function(rDie)
		if tonumber(rDie.type:match("^d(%d+)")) == rDie.result then
			return 1
		else
			return 0
		end
	end

	local newRoll = function(draginfo, aDieResults, rCustomData, aExplodedDices)		
		local rThrow = {}
		rThrow.type = draginfo.getType()
		rThrow.description = draginfo.getDescription()
		rThrow.secret = draginfo.getSecret()
		rThrow.shortcuts = {}

		local rSlot = {}
		rSlot.number = draginfo.getNumberData()
		rSlot.dice = aExplodedDices
		rSlot.custom = rCustomData
		rThrow.slots = { rSlot }
	
		Comm.throwDice(rThrow)
	end

	local rCustomData = draginfo.getCustomData() or {}
	local nSuccessLevel = rCustomData.successlevel;
Debug.console("nSuccessLevel: ", nSuccessLevel);
	local nKeep = rCustomData.keep
	local nSuccessLevel = rCustomData.successlevel;
	local aPreviousDieResults = decodeDiceResults(rCustomData.rollresults)
	local aNewDieResults = {}
	for _, rDie in pairs(draginfo.getDieList() or {}) do
		table.insert(aNewDieResults, {type = rDie.type, result = rDie.result, exploded = isMaxResult(rDie)})
	end
	
	local aDieResults = {}
	if #aPreviousDieResults < 1 then
		aDieResults = aNewDieResults
	else
		for _, rDie in pairs(aPreviousDieResults) do
			if rDie.exploded == 1 then
				for nIndex, rNewDie in pairs(aNewDieResults) do
					if rNewDie.type == rDie.type then
						rDie.result = rDie.result + rNewDie.result
						rDie.exploded = rNewDie.exploded
						table.remove(aNewDieResults, nIndex)
						break
					end
				end
			end
			table.insert(aDieResults, rDie)
		end
	end
	
	local aExplodedDices = {}
	for _, rDie in pairs(aDieResults) do
		if rDie.exploded == 1 then
			table.insert(aExplodedDices, rDie.type)
		end
	end
	
	if #aExplodedDices > 0 then
		local rCustomData = { keep = nKeep, successlevel = nSuccessLevel, rollresults = encodeDiceResults(aDieResults) }
		newRoll(draginfo, aDieResults, rCustomData, aExplodedDices)
		return true, true
	end
	
	rCustomData.rollresults = encodeDiceResults(aDieResults)
	draginfo.setCustomData(rCustomData)

	return true
end

function processDefaultResults(draginfo)
	
	local rCustomData = draginfo.getCustomData() or {}
	local aDieResults = decodeDiceResults(rCustomData.rollresults)

	local rMessage = ChatManager.createBaseMessage()
    rMessage.dicedisplay = 1; --  display total
	rMessage.font = "systemfont"
	rMessage.text = draginfo.getDescription()
	rMessage.dice = aDieResults
	rMessage.diemodifier = draginfo.getNumberData()
	Comm.deliverChatMessage(rMessage)

	return true
end

function processDefaultSuccessesResults(draginfo)
	
	local rCustomData = draginfo.getCustomData() or {}
	local nSuccessLevel = rCustomData.successlevel;
Debug.console("processDefaultSuccessesResults: nSuccessLevel: ", nSuccessLevel);

	local aDieResults = decodeDiceResults(rCustomData.rollresults)
Debug.console("processDefaultSuccessesResults: aDieResults: ", aDieResults);
  local nSuccesses = 0;
	for _, rDie in pairs(aDieResults) do
    if rDie.result >= nSuccessLevel then
      nSuccesses = nSuccesses + 1;
    end
  end

	local rMessage = ChatManager.createBaseMessage()
	rMessage.font = "systemfont"
	rMessage.text = draginfo.getDescription() .. "\nTarget="..nSuccessLevel.."\n"..nSuccesses.." Successes\n";
	rMessage.dice = aDieResults
	rMessage.diemodifier = draginfo.getNumberData()

	Comm.deliverChatMessage(rMessage)

	return true
end

function processRollAndKeepResult(draginfo)

local sDesc, nMod = ModifierStack.getStack(true);

	local getTotalKeepResult = function(aDieResults, nKeep)
		local nTotal = 0
		for i=1, nKeep do
			nTotal = nTotal + aDieResults[i].result
		end
		return nTotal
	end
	
	local rCustomData = draginfo.getCustomData() or {}

	local aDieResults = decodeDiceResults(rCustomData.rollresults)
	table.sort(aDieResults, function(a,b) return a.result > b.result end)

	local nKeep = rCustomData.keep

	local rMessage = ChatManager.createBaseMessage()
	rMessage.font = "systemfont"
	Debug.console("getDescription: ", draginfo.getDescription());
	rMessage.text = draginfo.getDescription()
	rMessage.dice = aDieResults
	Comm.deliverChatMessage(rMessage)
	
	local rResultMessage = { font = "systemfont" }
	rResultMessage.text = "[Keep " .. nKeep .. " " .. sDesc .. "]"
	rResultMessage.dice = {}
	rResultMessage.diemodifier = getTotalKeepResult(aDieResults, nKeep) + nMod
	Comm.deliverChatMessage(rResultMessage)

	return true
end

function processRollAndKeepDamageResult(draginfo)
Debug.console("processRollAndKeepDamageResult");

local sDesc, nMod = ModifierStack.getStack(true);


	local getTotalKeepResult = function(aDieResults, nKeep)
		local nTotal = 0
		for i=1, nKeep do
			nTotal = nTotal + aDieResults[i].result
		end
		return nTotal
	end
	
	local rCustomData = draginfo.getCustomData() or {}

	local aDieResults = decodeDiceResults(rCustomData.rollresults)
	table.sort(aDieResults, function(a,b) return a.result > b.result end)

	local nKeep = rCustomData.keep

	local rMessage = ChatManager.createBaseMessage()
	rMessage.font = "systemfont"
	Debug.console("getDescription: ", draginfo.getDescription());
	rMessage.text = draginfo.getDescription()
	rMessage.dice = aDieResults

	Comm.deliverChatMessage(rMessage)
	
	local rResultMessage = { font = "systemfont" }
	rResultMessage.type = "damage";
	Debug.console("rResultMessage.type: ", rMessage.type);
	rResultMessage.text = "[Keep " .. nKeep .. " " .. sDesc .. "]"
	rResultMessage.dice = {}
	rResultMessage.diemodifier = getTotalKeepResult(aDieResults, nKeep) + nMod
	Comm.deliverChatMessage(rResultMessage)

	return true
end

--New Dice Mechanics for L5R4E by Sibelius, based on Ikael L5R dice mechanics

function onRollAndKeepDamageKatanaSlashCommand(sCmd, sParam)
Debug.console("onRollAndKeepDamageKatanaSlashCommand");
	if sParam then
		local sRnkPattern, sDescriptionParam = sParam:match("(%d+k%d+)%s*(.*)")
		if sRnkPattern then
			local sDescription = "Roll & Keep Damage Roll for katanas (w/kenjutsu 7+)"
			if sDescriptionParam then
				sDescription = sDescriptionParam
			end
			local sDices, sKeep = sParam:match("^(%d+)k(%d+)")
			rollAndKeepDamageKatana(sDescription, tonumber(sDices), tonumber(sKeep))
		end
	end
end

function rollAndKeepDamageKatana(sDescription, nDices, nKeep)
Debug.console("rollAndKeepDamageKatana");

	local aDices = {}
	for i=1, tonumber(nDices) do
		table.insert(aDices, "d10")
	end

	local rThrow = {}
	rThrow.type = "rollAndKeepDamageKatana"
	local sRollAndKeepPattern = nDices .. "k" .. nKeep

	if not sDescription and sDescription == "" then
		rThrow.description = sRollAndKeepPattern
	else
		rThrow.description = sDescription .. " (" .. sRollAndKeepPattern .. " with exploding 9s)"
	end
	rThrow.secret = false

	local rSlot = {}
	rSlot.dice = aDices
	rSlot.custom = { keep = nKeep }
	rThrow.slots = { rSlot }

	Comm.throwDice(rThrow)
end

function processExplodingPlus(draginfo)

	local isMaxResult = function(rDie)
		if tonumber("9") == rDie.result or tonumber("10") == rDie.result then
			return 1
		else
			return 0
		end
	end

	local newRoll = function(draginfo, aDieResults, rCustomData, aExplodedDices)		
		local rThrow = {}
		rThrow.type = draginfo.getType()
		rThrow.description = draginfo.getDescription()
		rThrow.secret = draginfo.getSecret()
		rThrow.shortcuts = {}

		local rSlot = {}
		rSlot.number = draginfo.getNumberData()
		rSlot.dice = aExplodedDices
		rSlot.custom = rCustomData
		rThrow.slots = { rSlot }
	
		Comm.throwDice(rThrow)
	end

	local rCustomData = draginfo.getCustomData() or {}	
	local nKeep = rCustomData.keep
	local nSuccessLevel = rCustomData.successlevel
	
	local aPreviousDieResults = decodeDiceResults(rCustomData.rollresults)
	local aNewDieResults = {}
	for _, rDie in pairs(draginfo.getDieList() or {}) do
		table.insert(aNewDieResults, {type = rDie.type, result = rDie.result, exploded = isMaxResult(rDie)})
	end
	
	local aDieResults = {}
	if #aPreviousDieResults < 1 then
		aDieResults = aNewDieResults
	else
		for _, rDie in pairs(aPreviousDieResults) do
			if rDie.exploded == 1 then
				for nIndex, rNewDie in pairs(aNewDieResults) do
					if rNewDie.type == rDie.type then
						rDie.result = rDie.result + rNewDie.result
						rDie.exploded = rNewDie.exploded
						table.remove(aNewDieResults, nIndex)
						break
					end
				end
			end
			table.insert(aDieResults, rDie)
		end
	end
	
	local aExplodedDices = {}
	for _, rDie in pairs(aDieResults) do
		if rDie.exploded == 1 then
			table.insert(aExplodedDices, rDie.type)
		end
	end
	
	if #aExplodedDices > 0 then
		local rCustomData = { keep = nKeep, successlevel = nSuccessLevel, rollresults = encodeDiceResults(aDieResults) }
		newRoll(draginfo, aDieResults, rCustomData, aExplodedDices)
		return true, true
	end
	
	rCustomData.rollresults = encodeDiceResults(aDieResults)
	draginfo.setCustomData(rCustomData)

	return true
end

function onRollAndKeepEmphasisSlashCommand(sCmd, sParam)
	if sParam then
		local sRnkPattern, sDescriptionParam = sParam:match("(%d+k%d+)%s*(.*)")
		if sRnkPattern then
			local sDescription = "Roll & Keep (Skills with Emphasis)"
			if sDescriptionParam then
				sDescription = sDescriptionParam
			end
			local sDices, sKeep = sParam:match("^(%d+)k(%d+)")
			rollAndKeepEmphasis(sDescription, tonumber(sDices), tonumber(sKeep))
		end
	end
end

function rollAndKeepEmphasis(sDescription, nDices, nKeep)

	local aDices = {}
	for i=1, tonumber(nDices) do
		table.insert(aDices, "d10")
	end

	local rThrow = {}
	rThrow.type = "rollAndKeepEmphasis"
	local sRollAndKeepPattern = nDices .. "k" .. nKeep


	if not sDescription and sDescription == "" then
		rThrow.description = sRollAndKeepPattern .. " (skill emphasis)"
	else
		rThrow.description = sDescription .. " (" .. sRollAndKeepPattern .. " repeating 1s once due to skill emphasis)"
	end
	rThrow.secret = false

	local rSlot = {}
	rSlot.dice = aDices
	rSlot.custom = { keep = nKeep }
	rThrow.slots = { rSlot }

	Comm.throwDice(rThrow)
end


function processExplodingEmphasis(draginfo)

	local isOne = function(rDie)
		if 1 == rDie.result then
			return 2
		else
			if tonumber(rDie.type:match("^d(%d+)")) == rDie.result then
				return 1
			else
				return 0
			end
		end	
	end
	
	local rCustomData = draginfo.getCustomData()	
	local nKeep = rCustomData.keep
		
	local aDieResults = {}
	for _, rDie in pairs(draginfo.getDieList() or {}) do
		table.insert(aDieResults, {type = rDie.type, result = rDie.result, exploded = isOne(rDie)})
	end
	
	local oneDices = {}
	for _, rDie in pairs(aDieResults) do
		if rDie.exploded == 2 then
			table.insert(oneDices, rDie.type)
		end
	end
		
	local aExplodedDices = {}
	for _, rDie in pairs(aDieResults) do
		if rDie.exploded == 1 then
			table.insert(aExplodedDices, rDie.type)
		end
	end

	if #oneDices == 0 and #aExplodedDices > 0 then
		draginfo.setType("rollAndKeep")
		processExplodingDices(draginfo)
		return true, true
	end
	
	if #oneDices == 0 and #aExplodedDices == 0 then
		draginfo.setType("rollAndKeep")
		processExplodingDices(draginfo)
		return true
	end

	rCustomData.rollresults = encodeDiceResults(aDieResults)

	local rThrow = {}
	rThrow.type = "repeatingOnes"
	rThrow.description = draginfo.getDescription()
	rThrow.secret = draginfo.getSecret()
	rThrow.shortcuts = {}

	local rSlot = {}
	rSlot.dice = oneDices
	rSlot.custom = rCustomData
	rThrow.slots = { rSlot }
	
	Comm.throwDice(rThrow)
	return true, true		
end	
	
function processOnes(draginfo)	
	
	local isMaxResult = function(rDie)
		if tonumber(rDie.type:match("^d(%d+)")) == rDie.result then
			return 1
		else
			return 0
		end
	end
	
	local rCustomData = draginfo.getCustomData()	
	local nKeep = rCustomData.keep
	local nSuccessLevel = rCustomData.successlevel
	
	local aPreviousDieResults = decodeDiceResults(rCustomData.rollresults)
	
	local aNewDieResults = {}
	for _, rDie in pairs(draginfo.getDieList() or {}) do
		table.insert(aNewDieResults, {type = rDie.type, result = rDie.result, exploded = isMaxResult(rDie)})
	end
	
	local aDieResults = {}
	for _, rDie in pairs(aPreviousDieResults) do
		if rDie.exploded == 2 then
			for nIndex, rNewDie in pairs(aNewDieResults) do
				if rNewDie.type == rDie.type then
					rDie = rNewDie
					table.remove(aNewDieResults, nIndex)
					break
				end
			end
		end
		table.insert(aDieResults, rDie)
	end
		
	local aExplodedDices = {}
	for _, rDie in pairs(aDieResults) do
		if rDie.exploded == 1 then
			table.insert(aExplodedDices, rDie.type)
		end
	end
		
	local rCustomData = { keep = nKeep, successlevel = nSuccessLevel, rollresults = encodeDiceResults(aDieResults) }
	draginfo.setType("rollAndKeep")
	draginfo.setCustomData(rCustomData)
	draginfo.setDieList ({})
	
	if #aExplodedDices > 0 then
		processExplodingDices(draginfo)
		return true, true
	else
		processExplodingDices(draginfo)
		return true
	end
end