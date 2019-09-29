---
--- Initialization
---
function onInit()
	Comm.registerSlashHandler("morecorehelp", processRoll);
end

---
---	This is the function that is called when the successes slash command is called.
---
function processRoll(sCommand, sParams)
		createHelpMessage();		
end


---
--- This function creates the help text message for output.
---
function createHelpMessage()	
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "The MoreCore User Manual can be found here:\r\n http://www.diehard-gaming.com/mchelp.html"; 
	Comm.deliverChatMessage(rMessage);
end

