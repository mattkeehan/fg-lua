
function onInit()
    -- name of the checkbox that determines if this parameter field should be enabled
    local myName = getName();
    local trackEnabledNodeName = myName .. "_hidden";

    -- find the checkbox node in the DB, if not found, make one
    local nodeWin = window.getDatabaseNode();
    local teNode = nodeWin.getChild(trackEnabledNodeName);
    if( teNode == nil ) then
        teNode = DB.createChild(nodeWin,trackEnabledNodeName,"number")
        teNode.setValue(0);
    end

    -- watch for changes to the hide/show checkbox for this param
    DB.addHandler( teNode.getPath(),"onUpdate", visCheckBoxUpdated);


	-- watch for changes to the formula enable/disable, since we want to hide the parameters if the formula is disabled
    local trackerNode = nodeWin.getChild("tracker_enabled");
    if( trackerNode == nil ) then
        trackerNode = DB.createChild(nodeWin,"tracker_enabled","number")
        trackerNode.setValue(0);
    end
	DB.addHandler( trackerNode.getPath(),"onUpdate", visCheckBoxUpdated);

    -- force an update to the visiblity of this parameter
    visCheckBoxUpdated(teNode);

    -- watch this parameter for changes and update the formula as needed --
    --[[local thisTrackNode = nodeWin.getChild(myName);
    if( thisTrackNode == nil ) then
        thisTrackNode = DB.createChild(nodeWin,myName,"number")
        thisTrackNode.setValue(0);
    end
    DB.addHandler(thisTrackNode.getPath(),"onUpdate", updateFormula);]]

	--watch for changes to the Tooltip Field
	local tooltipNodeName = myName .. "_tooltip";
	local tooltipNode = nodeWin.getChild(tooltipNodeName)
	if( tooltipNode == nil ) then
		tooltipNode = DB.createChild(nodeWin,tooltipNodeName,"string");
		tooltipNode.setValue("Tracker");
	else
		setTooltipText(tooltipNode.getValue());
	end

	DB.addHandler( tooltipNode.getPath(),"onUpdate", updateToolTip );

  registerMenuItem("Reset", "resettemp", 3);
  registerMenuItem("reset All", "resetalltemp", 4);
end

function visCheckBoxUpdated(nodeUpdated)
	local nodeWin = window.getDatabaseNode();
    local trackerNode = nodeWin.getChild("tracker_enabled");

	-- if the formula isn't enabled hide the parameters
	if ( trackerNode.getValue() == 0 ) then
		setVisible(false);
	else
		local myName = getName();
		local trackEnabledNodeName = myName .. "_hidden";
		local teNode = nodeWin.getChild(trackEnabledNodeName);

		-- update the visibility of this parameter field
		if( teNode.getValue() == 1 ) then
			setVisible(false);
		else
			setVisible(true);
		end
	end
end

function updateToolTip(nodeUpdated)
	setTooltipText(nodeUpdated.getValue());
end

