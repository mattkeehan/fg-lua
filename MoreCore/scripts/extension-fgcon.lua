--[[ 
======================================================================
FG Copyright: 'Fantasy Grounds' is a trademark of SmiteWorks Ltd. 
© 2004-2015 SmiteWorks Ltd. ALL RIGHTS RESERVED.
All other copyrights and trademarks are the property of their respective owners.
======================================================================
--]]

-- -------------------------------------------------------------------
-- Constants
-- NOTE: Since Lua does not support immutable constants, they are going in a table
-- Alternately, they could be declared as individual local variables 
-- of any scope, albeit with chaotic code maintenance. Hopefully, this way
-- is still quick, maintainable, and self-documenting
-- -------------------------------------------------------------------
local const = {
	LINK_STR = "http://www.fg-con.com",
	ABOUT_STR = "Visit http://www.fg-con.com for the best online RPG convention. Every year in May and October.",
	ABOUT_FONT = "emotefont",										-- about font
	ABOUT_ICON_NAME = "fgcon",							-- about icon
	DOUBLE_SPACE = '\n\n',
	RETURN = '\r\n',
}


-- -------------------------------------------------------------------
-- Function: mlDoAbout
-- Description: show the extension about text
-- Params: launch: true if sending the launch message
-- Returns: N/A
-- -------------------------------------------------------------------
local function extDoAbout(isLaunch)
	local msg = {sender = "", font = const.ABOUT_FONT,icon=const.ABOUT_ICON_NAME};
	msg.text = const.ABOUT_STR;
	if (isLaunch) then
		ChatManager.registerLaunchMessage(msg);
	else 
		Comm.addChatMessage(msg);
	end
end


-- -------------------------------------------------------------------
-- Function: onInit
-- Description: the FG extension primary init routine -- GLOBAL / EXTERNAL
-- Params: N/A
-- Returns: N/A
-- -------------------------------------------------------------------
function onInit()
	-- initVars();											-- initialize defaults
	-- printDebug("onInit");
	-- Comm.registerSlashHandler("ml", doMoodLighting);	-- install our handler
	extDoAbout(true);									-- show launch version info
end

-- -------------------------------------------------------------------

