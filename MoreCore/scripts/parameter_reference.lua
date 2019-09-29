function onInit()
	registerMenuItem("Reset Reference", "resettemp", 5);
end

function onMenuSelection(item)
	local nodeWin = window.getDatabaseNode();
	if item == 5 then
		setValue("Drag Field or Roll Here");
		nodeWin.getChild(getName() .. "_path").setValue("");
	end
end


function onDrop(x, y, draginfo)
	local sDragType = draginfo.getType();
	
	local dragnode = draginfo.getDatabaseNode();
	if( dragnode ~= nil ) then
		local dragPath = dragnode.getPath();
		local nodeWin = window.getDatabaseNode();
		local myPath = nodeWin.getPath();
		
		
		if( myPath ~= dragPath ) then
			local myPathParts = dotsplit(myPath,"%.");
			local dragPathParts = dotsplit(dragPath,"%.");
			
			local refPath = "";
			local pathStarted = 0;
			local relPathBeginsAt = #myPathParts;
			
			
			
			if( myPathParts[1] == dragPathParts[1] ) then
				for k,v in ipairs(dragPathParts) do
					if( pathStarted == 0 and v ~= myPathParts[k] ) then
						pathStarted = 1;
					end
					
					if( pathStarted == 1 ) then
						if( k < #dragPathParts ) then
							refPath = refPath .. v .. ".";
						else
							refPath = refPath .. v;
						end
					else
						relPathBeginsAt = relPathBeginsAt - 1;
					end
				end
				
				for i=1,relPathBeginsAt+1 do
					refPath = "." .. refPath;
				end
			end

			local refNameNode = dragnode.getChild("name");
			local refP1Node = dragnode.getChild("p1");
			
			local myName = getName();
			local myLetter = string.sub(myName,4,5);
			
			if( draginfo.isType("shortcut") and refNameNode ~= nil and refP1Node ~= nil ) then
				setValue(refNameNode.getValue() .. " : ("..myLetter.."1),("..myLetter.."2),("..myLetter.."3)");
				nodeWin.getChild(myName.."_path").setValue(refPath);
			else
				local dragNodeCurVal = dragnode.getValue();
				if( type(dragNodeCurVal) == "string" or type(dragNodeCurVal) == "number" ) then
					setValue(refPath .. " : ("..myLetter..") available");
					nodeWin.getChild(myName.."_path").setValue(refPath);
				else
					local chatMsg = {};
					chatMsg.text = "Invalid field for reference";
					chatMsg.sender = "MoreCore Reference field";
					
					Comm.addChatMessage(chatMsg);
				end
			end
			ParameterManager.updateCommand(nodeWin);
			
		end
		return true;
	end 
	
end

function dotsplit(s)
	result = {}
	for m in (s.."."):gmatch("(.-)%.") do
		table.insert(result, m);
	end
	return result;
end						