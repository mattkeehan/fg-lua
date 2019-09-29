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
	ABOUT_STR = "MoreCore Ruleset (Version 1.46 beta). This ruleset adds features and flexibility to CoreRPG allowing you to play more game systems. This has grown from the MoreCore extension and adds a range of generic features.\r\nThis ruleset coded by damned and ianmward and additional thanks to Trenloe and others for their assistance along the way. This incorporates dice rolling extensions from Ikael, DMFirmy, Trenloe, Frostbyte, Imiri, Myrddin, Sibelius, ianmward and damned. Other devs may add new roll types.\r\nYou can Create a library of Rolls and you can drag Rolls into the MoreCore tab of the PC sheet and the Rolls field of the NPC sheet.",
	ABOUT_FONT = "emotefont",										-- about font
	ABOUT_ICON_NAME = "morecorelogo",							-- about icon
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

