-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local rsname = "MoreCore";
local rsmajorversion = 1;

function onInit()
	if User.isHost() or User.isLocal() then
		updateCampaign();
	end
	Module.onModuleLoad = onModuleLoad;

	DB.onAuxCharLoad = onCharImport;
	DB.onImport = onImport;
end

function onModuleLoad(sModule)
	local _, _, aMajor, _ = DB.getRulesetVersion(sModule);
	updateModule(sModule, aMajor[rsname]);
end

function onCharImport(nodePC)
	local _, _, aMajor, _ = DB.getImportRulesetVersion();
	updateChar(nodePC, aMajor[rsname]);
end

function onImport(node)
	local aPath = StringManager.split(node.getNodeName(), ".");
	if #aPath == 2 and aPath[1] == "charsheet" then
		local _, _, aMajor, _ = DB.getImportRulesetVersion();
		updateChar(node, aMajor[rsname]);
	end
end

function updateChar(nodePC, nVersion)
	if not nVersion then
		nVersion = 0;
	end
	
	if nVersion < 3 then
		if nVersion < 3 then
			migrateChar3(nodePC);
		end
	end
end

function updateCampaign()
	local _, _, aMajor, aMinor = DB.getRulesetVersion();
	Debug.console("aMajor: ", aMajor, " aMinor: ", aMinor);
	local major = aMajor[rsname];
	if not major then
		return;
	end
	
	if major > 0 and major < rsmajorversion then
		Debug.console("Major version: ", major);
		print("Migrating campaign database to latest data version. (" .. rsname ..")");
		DB.backup();
		
		if major < 2 then
			convertNotes2();
		end
		if major < 4 then
			convertImages4();
			convertItems4();
			convertPartyItems4();
		end
	end
end

function migrateChar3(nodeChar)
	if DB.getChildCount(nodeChar, "skilllist") > 0 then
		local nodeCategories = DB.createChild(nodeChar, "maincategorylist");
		local nodeCategory = DB.createChild(nodeCategories);
		local nodeAttributeList = DB.createChild(nodeCategory, "attributelist");
		if nodeAttributeList then
			for _,vSkill in pairs(DB.getChildren(nodeChar, "skilllist")) do
				local vNewSkill = nodeAttributeList.createChild();
				if vNewSkill then
					DB.copyNode(vSkill, vNewSkill);
					vSkill.delete();
				end
			end
		end
	end
	if DB.getChildCount(nodeChar, "skilllist") == 0 then
		DB.deleteChild(nodeChar, "skilllist");
	end
end

function convertChars3()
	for _,nodeChar in pairs(DB.getChildren("charsheet")) do
		migrateChar3(nodeChar);
	end
end

function updateModule(sModule, nVersion)
	if not nVersion then nVersion = 0; end
	if nVersion > 0 and nVersion < rsmajorversion then
		local nodeRoot = DB.getRoot(sModule);
		if not nodeRoot then return; end
		if nVersion < 4 then
			convertImages4(nodeRoot);
			convertItems4(nodeRoot);
		end
	end
end

function convertNotes2()
	for _,vNote in pairs(DB.getChildren("notes")) do
		local vText = DB.getChild(vNote, "text");
		if DB.getType(vText) == "string" then
			local sText = vText.getValue();
			sText = "<p>" .. sText:gsub("\n", "</p><p>") .. "</p>";
			DB.deleteChild(vNote, "text");
			DB.setValue(vNote, "text", "formattedtext", sText);
		end
	end
end
function convertImages4(nodeRoot)
	local sValue = DB.getValue("options.IMID", "");
	if sValue == "on" then return; end
	
	local aMappings = LibraryData.getMappings("image");
	for _,vMapping in ipairs(aMappings) do
		for _,vNode in pairs(DB.getChildren(DB.getPath(nodeRoot, vMapping))) do
			DB.deleteChild(vNode, "isidentified");
		end
	end
end

function convertItems4(nodeRoot)
	local sValue = DB.getValue("options.MIID", "");
	if sValue == "on" then return; end
	
	local aMappings = LibraryData.getMappings("item");
	for _,vMapping in ipairs(aMappings) do
		for _,vNode in pairs(DB.getChildren(DB.getPath(nodeRoot, vMapping))) do
			DB.deleteChild(vNode, "isidentified");
		end
	end

	local aMappings = LibraryData.getMappings("treasureparcel");
	for _,vMapping in ipairs(aMappings) do
		for _,vNode in pairs(DB.getChildren(DB.getPath(nodeRoot, vMapping))) do
			for _,vParcelItem in pairs(DB.getChildren(vNode, "itemlist")) do
				DB.deleteChild(vNode, "isidentified");
			end
		end
	end
end
function convertPartyItems4()
	local sValue = DB.getValue("options.MIID", "");
	if sValue == "on" then return; end
	
	for _,vParcelItem in pairs(DB.getChildren("partysheet.treasureparcelitemlist")) do
		DB.deleteChild(vNode, "isidentified");
	end
end

