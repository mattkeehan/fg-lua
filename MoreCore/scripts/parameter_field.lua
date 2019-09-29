
function onInit()
    -- name of the checkbox that determines if this parameter field should be enabled
    local myName = getName();
    local paramEnabledNodeName = myName .. "_hidden";
    
    -- find the checkbox node in the DB, if not found, make one
    local nodeWin = window.getDatabaseNode();
    local peNode = nodeWin.getChild(paramEnabledNodeName);
    if( peNode == nil ) then
        peNode = DB.createChild(nodeWin,paramEnabledNodeName,"number")
        peNode.setValue(0);
    end

    -- watch for changes to the hide/show checkbox for this param
    DB.addHandler( peNode.getPath(),"onUpdate", visCheckBoxUpdated);
	
    
	-- watch for changes to the formula enable/disable, since we want to hide the parameters if the formula is disabled
    local formulaNode = nodeWin.getChild("parameter_formula_enabled");
    if( formulaNode == nil ) then
        formulaNode = DB.createChild(nodeWin,"parameter_formula_enabled","number")
        formulaNode.setValue(0);
    end
	DB.addHandler( formulaNode.getPath(),"onUpdate", visCheckBoxUpdated);
	
    -- force an update to the visiblity of this parameter
    visCheckBoxUpdated(peNode);
    
    -- watch this parameter for changes and update the formula as needed --
    local thisParamNode = nodeWin.getChild(myName);
    if( thisParamNode == nil ) then
        thisParamNode = DB.createChild(nodeWin,myName,"number")
        thisParamNode.setValue(0);
    end
    DB.addHandler( thisParamNode.getPath(),"onUpdate", updateFormula);
    
	--watch for changes to the Tooltip Field
	local tooltipNodeName = myName .. "_tooltip";
	local tooltipNode = nodeWin.getChild(tooltipNodeName)
	if( tooltipNode == nil ) then
		tooltipNode = DB.createChild(nodeWin,tooltipNodeName,"string");
		tooltipNode.setValue("Parameter");
	else
		setTooltipText(tooltipNode.getValue());
	end
	
	DB.addHandler( tooltipNode.getPath(),"onUpdate", updateToolTip );
end

function visCheckBoxUpdated(nodeUpdated)
	local nodeWin = window.getDatabaseNode();
    local formulaNode = nodeWin.getChild("parameter_formula_enabled");
    
	-- if the formula isn't enabled hide the parameters
	if ( formulaNode.getValue() == 0 ) then
		setVisible(false);
	else
		local myName = getName();
		local paramEnabledNodeName = myName .. "_hidden";
		local peNode = nodeWin.getChild(paramEnabledNodeName);
    	
		-- update the visibility of this parameter field
		if( peNode.getValue() == 1 ) then
			setVisible(false);
		else
			setVisible(true);
		end
	end
end

function updateFormula(nodeUpdated)
    -- called when this field's db node is updated
    ParameterManager.updateCommand(window.getDatabaseNode());
end

function updateToolTip(nodeUpdated)
	setTooltipText(nodeUpdated.getValue());
end
