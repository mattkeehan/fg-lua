-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

aDefaultSidebarState = {
	["gm"] = "charsheet,note,image,table,story,quest,npc,battle,item,treasureparcel,cas,char_ability",
	["play"] = "charsheet,note,image,story,npc,item,cas,char_ability",
	["create"] = "charsheet,cas,char_ability",
};

local wLibrary = nil;
local aSidebarOrder = {};

function onInit()
	Interface.onDesktopInit = onDesktopInit;
	Interface.onDesktopClose = onDesktopClose;
end

function onDesktopInit()
	if type(CampaignRegistry.sidebar) ~= "string" then
		CampaignRegistry.sidebar = nil;
	end
	LibraryData.initialize();
	reset();
end

function onDesktopClose()
	CampaignRegistry.sidebar = table.concat(aSidebarOrder, ",");
end

function reset()
	for _,v in ipairs(aSidebarOrder) do
		DesktopManager.removeLibraryDockShortcut(v);
	end
	aSidebarOrder = {};
	if not CampaignRegistry.sidebar or (CampaignRegistry.sidebar == "") then
		if User.isLocal() then
			CampaignRegistry.sidebar = aDefaultSidebarState["create"];
		elseif User.isHost() then
			CampaignRegistry.sidebar = aDefaultSidebarState["gm"];
		else
			CampaignRegistry.sidebar = aDefaultSidebarState["play"];
		end
	end
	local aSavedOrder = StringManager.split(CampaignRegistry.sidebar, ",", true);
	for _,v in ipairs(aSavedOrder) do
		if LibraryData.getRecordTypeInfo(v) then
			table.insert(aSidebarOrder, v);
			DesktopManager.addLibraryDockShortcut(v);
		end
	end
end

function registerWindow(wNewLibrary)
	wLibrary = wNewLibrary;
	
	for _,vRecordType in ipairs(LibraryData.getRecordTypes()) do
		if not LibraryData.isHidden(vRecordType) then
			local w = wLibrary.recordlist.createWindow();
			w.setRecordType(vRecordType);
		end
	end
	wLibrary.recordlist.applySort();
end

function unregisterWindow()
	wLibrary = nil;
end

function showSidebarTitleText(bState)
	bShowSidebarTitleText = bState;
end

function toggleIndex(sRecordType)
	local rRecordType = LibraryData.getRecordTypeInfo(sRecordType);
	if not rRecordType then
		return;
	end
	
	if rRecordType.fToggleIndex then
		rRecordType.fToggleIndex();
		return;
	end
	
	local sDisplayIndex = "masterindex";
	if rRecordType.sDisplayIndex then
		sDisplayIndex = rRecordType.sDisplayIndex;
	end
	
	local aMappings = LibraryData.getMappings(sRecordType);
	Interface.toggleWindow(sDisplayIndex, aMappings[1]);
end

function resetSidebar(sMode)
	if sMode == "all" then
		local aAllOrder = StringManager.split(aDefaultSidebarState["gm"], ",", true);
		local aAllRecordTypes = LibraryData.getRecordTypes();
		for _,vRecordType in pairs(aAllRecordTypes) do
			if not StringManager.contains(aAllOrder, vRecordType) and not LibraryData.isHidden(vRecordType) then
				table.insert(aAllOrder, vRecordType);
			end
		end
		CampaignRegistry.sidebar = table.concat(aAllOrder, ",");
	else
		CampaignRegistry.sidebar = aDefaultSidebarState[sMode];
	end
	
	reset();
end

function onSidebarOptionChanged(sRecordType, nValue)
	local rRecordType = LibraryData.getRecordTypeInfo(sRecordType);
	if not rRecordType then
		return;
	end
	
	setSidebarButtonState(sRecordType, (nValue == 1));
end
function getSidebarButtonState(sRecordType)
	return StringManager.contains(aSidebarOrder, sRecordType);
end
function setSidebarButtonState(sRecordType, bState)
	local bCurrentState = getSidebarButtonState(sRecordType);
	if bState == bCurrentState then
		return;
	end
	
	if bState then
		table.insert(aSidebarOrder, sRecordType);
		DesktopManager.addLibraryDockShortcut(sRecordType);
	else
		for k,v in ipairs(aSidebarOrder) do
			if v == sRecordType then
				table.remove(aSidebarOrder, k);
				break;
			end
		end
		DesktopManager.removeLibraryDockShortcut(sRecordType);
	end
end

function setDefaultSidebarState(sMode, sNewDefaultState)
	aDefaultSidebarState[sMode] = sNewDefaultState;
end
