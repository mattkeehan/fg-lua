-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- MoreCore v0.60 register "attack"
function onInit()
  Debug.console("onInit: registerResultHandler");
  ActionsManager.registerResultHandler("attack", onAttack);
end

 
-- MoreCore v0.60 aTargetting: XXXXXXXXXXX
-- MoreCore v0.60 performAction: XXXXXXXXXXX
function performRoll(draginfo, rActor, rRoll)

  aTargeting = ActionsManager.getTargeting(rActor, nil, rRoll.sType, { rRoll });

  Debug.console("ManagerAttack.performRoll: aTargeting: ", aTargeting);
   
  ActionsManager.performAction(draginfo, rActor, rRoll);
end


-- MoreCore v0.60 rMessage: XXXXXXXXXXX
-- MoreCore v0.60 bIsSourcePC: XXXXXXXXXXX
-- onAttack is called when an attack roll complete (as it was registered as a ResultHandler for “attack” actions). It is called either: once with rTarget nil if there is not assigned target; or once for each assigned target, each with the same set of result dice.
-- The function first creates a default message as in the standard CoreRPG, then appends the targeting information, before finally writing the result to the chat window.
function onAttack(rSource, rTarget, rRoll)
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  local bIsSourcePC = (rSource and rSource.sType == "pc");


  if rTarget then
    rMessage.text = rMessage.text .. " vs "..rTarget.sName;
  end

  Comm.deliverChatMessage(rMessage);
end