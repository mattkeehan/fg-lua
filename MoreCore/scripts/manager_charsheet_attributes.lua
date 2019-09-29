-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	DB.addHandler("charsheet.*.abilities.*.tempmodifier", "onUpdate", onUpdate);
	CharacterListManager.addDecorator("bonuswidget", addBonuswidgetWidget);
end

function onUpdate(nodeInspiration)
	updateWidgets(nodeInspiration.getChild("..").getName());
end

function addBonuswidgetWidget(control, sIdentity)
	local widget = control.addBitmapWidget("bonuswidget");
	widget.setPosition("center", -15, -10);
	widget.setVisible(true);
	widget.setName("bonuswidget");

	updateWidgets(sIdentity);
end

function updateWidgets(sIdentity)
	local ctrlChar = CharacterListManager.getEntry(sIdentity);
	if not ctrlChar then
		return;
	end
	local widget = ctrlChar.findWidget("bonuswidget");
	if not widget then
		return;
	end	
end
