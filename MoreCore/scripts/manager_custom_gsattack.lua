-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "gsattack"

local sCmd = "gsattack";

function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
--	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all", nil, nil, onDiceTotal)
end

function performAction(draginfo, rActor, sParams)
--	Debug.console("performAction: ", draginfo, rActor, sParams);

	local rRoll = createRoll(sParams);
	ActionsManager.performAction(draginfo, rActor, rRoll);
--	Debug.console("performAction: ", rRoll);
end   


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
  local rRoll = {};
  rRoll.sType = sCmd;
  rRoll.nMod = 0;
  -- Removed to allow ChatManager.createBaseMessage function to create the right name - active character or player name if no characters are active.
  --rRoll.sUser = User.getUsername();
  rRoll.aDice = {"d6"};

	

	local sAttackMod, sDesc = sParams:match("(%-?%d+)%s*(.*)");
	local sModDesc, nMod = ModifierStack.getStack(true);
	local nAttackMod = tonumber(sAttackMod);

	rRoll.sDesc = sDesc;
	rRoll.nMod = nMod;
	rRoll.nAttackMod = nAttackMod;
	rRoll.sModDesc = sModDesc;
	Debug.console("rRoll46: ", rRoll);
  return rRoll;
end



---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.dicedisplay = 1; -- display total

  rMessage.text = rMessage.text .. " [" .. rRoll.nMod .. "] " .. rRoll.sModDesc;
  
  return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "The \"/successes\" command is used to roll a set of dice and report the number of dice that meet or exceed a success target number.\n"; 
  rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the success target number"; 
  rMessage.text = rMessage.text .. "by supplying the \"/successes\" command with parameters in the format of \"#d# #\", where the first # is the "; 
  rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
  rMessage.text = rMessage.text .. "space being the success target number for each dice."; 
  Comm.deliverChatMessage(rMessage);
end


---
--- This is the callback that gets triggered after the roll is completed.
---
function onLanded(rSource, rTarget, rRoll)
Debug.console("performAction(gsattack): ", rRoll);
  rMessage = createChatMessage(rSource, rRoll);
  rRoll = getDiceResults(rRoll, rTarget);
  

  rMessage.type = sDice;
	rMessage.text = "Attack!\n" .. rMessage.text .. "\nDice Result [" .. rRoll.nDiceResult .. "]\n" .. rRoll.sHitResult;

	Comm.deliverChatMessage(rMessage);
end

function getDiceResults(rRoll, rTarget)
	nTotal = 0;
	nDiceResult = 0;


	local nDiceResult = rRoll.aDice[1].result + rRoll.nMod + rRoll.nAttackMod;
	Debug.console("nDiceResult: ", nDiceResult);
--  	rRoll.aDice[1].result = rRoll.nMod + rRoll.nAttackMod + rRoll.aDice[1].result;

	if rTarget ~= nil then
		Debug.console("rTarget: ", rTarget);
			rRoll.nTargetNum = DB.getValue(rTarget.sCTNode .. ".defence")
			else rRoll.nTargetNum = 4;
			end 

	local sHitResult;
    if rTarget ~= nil then
		sHitResult = " vs " .. rTarget.sName;
		else sHitResult = " ";
    end
	
	if nDiceResult >= rRoll.nTargetNum then
		sHitResult = "Hit!" .. sHitResult;
		else
		sHitResult = "Miss!" .. sHitResult;
		end
	
		Debug.console("sHitResult: ", sHitResult);

		rRoll.nTargetNum = nTargetNum;
		rRoll.sHitResult = sHitResult;
		rRoll.nDiceResult = nDiceResult;
		
		Debug.console("rRoll: ", rRoll);

	return rRoll;
end
