function onInit()
    -- find the checkbox node in the DB, if not found, make one
    local nodeWin = window.getDatabaseNode();
	
	-- Get corrent clichatcommand to use as the default value for the formula
	local clichatcommand = nodeWin.getChild("clichatcommand");
	local initFormula = "";
	if( clichatcommand ~= nil ) then 
		initFormula = clichatcommand.getValue();
	end	
	
    local formula = nodeWin.getChild("parameter_formula");
    if( formula == nil ) then
        formula = DB.createChild(nodeWin,"parameter_formula","string")
        formula.setValue(initFormula);
    end

	if( formula.getValue() == "" and initFormula ~= "" ) then
        formula.setValue(initFormula);
	end
	
    -- watch for changes to the formula
    DB.addHandler( formula.getPath(),"onUpdate", updateFormula);
    
    local formulaEnabled = nodeWin.getChild("parameter_formula_enabled");
    if( formulaEnabled == nil ) then
        formulaEnabled = DB.createChild(nodeWin,"parameter_formula_enabled","number")
        formulaEnabled.setValue(0);
    end

    -- watch for changes to the formula enabled checkbox
    DB.addHandler( formulaEnabled.getPath(),"onUpdate", updateFormula);

    -- watch for changes to the formula enabled checkbox
    DB.addHandler( nodeWin.getChild("refa_path").getPath(),"onUpdate", updateFormula);
    DB.addHandler( nodeWin.getChild("refb_path").getPath(),"onUpdate", updateFormula);
    DB.addHandler( nodeWin.getChild("refc_path").getPath(),"onUpdate", updateFormula);
	
	
	-- if enabled, and if a formula is specified, then update clichatcommand
	if( formula ~= "" and formula ~= clichatcommand and formulaEnabled.getValue() == 1 ) then
		updateFormula(formula);
	end
        
end

function updateFormula(nodeUpdated)
    ParameterManager.updateCommand(window.getDatabaseNode());
end