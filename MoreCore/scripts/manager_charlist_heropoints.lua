-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	DB.addHandler("charsheet.*.hero", "onUpdate", onUpdate);
	CharacterListManager.addDecorator("heroindicator", addHeroindicatorWidget);
end

function onUpdate(nodeInspiration)
	updateWidgets(nodeInspiration.getChild("..").getName());
end

function addHeroindicatorWidget(control, sIdentity)
	local widget = control.addBitmapWidget("heroindicator");
	widget.setPosition("center", -25, 15);
	widget.setVisible(false);
	widget.setName("heroindicator");

	local textwidget = control.addTextWidget("mini_name", "");
	textwidget.setPosition("center", -25, 15);
	textwidget.setVisible(false);
	textwidget.setName("heropointtext");
	
	updateWidgets(sIdentity);
end

function updateWidgets(sIdentity)
	local ctrlChar = CharacterListManager.getEntry(sIdentity);
	if not ctrlChar then
		return;
	end
	local widget = ctrlChar.findWidget("heroindicator");
	local textwidget = ctrlChar.findWidget("heropointtext");
	if not widget or not textwidget then
		return;
	end	
	local nHeroPoints = DB.getValue("charsheet." .. sIdentity .. ".hero", 0);
	if nHeroPoints <= 0 then
		widget.setVisible(false);
		textwidget.setVisible(false);
	else
		widget.setVisible(true);
		textwidget.setVisible(true);
		textwidget.setText(nHeroPoints);
	end
end
