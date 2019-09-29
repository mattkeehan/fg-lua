
-- Called when the formula, or one of the parameters has been updated 
-- to update the clichatcommand
function updateCommand(nodeWin)
	if not nodeWin.getChild("tracker_enabled").getValue() == 1 then
		if not nodeWin.getChild("clichatcommand").getValue() then
			local formula = "";
			else
			local formula = nodeWin.getChild("clichatcommand").getValue();
			end
		end
	
    if( nodeWin ~= nil ) then
        local formulaEnabledNode = nodeWin.getChild("parameter_formula_enabled")
    
        if( formulaEnabledNode ~= nil ) then
            local formulaEnabled = nodeWin.getChild("parameter_formula_enabled").getValue();
            
            if( formulaEnabled == 1 ) then

                formula = nodeWin.getChild("parameter_formula").getValue();
                
                if( formula ~= "" ) then
					-- Get the 3 parameter numbers to use for substitution into the formula
--					Debug.chat("nodeWin: ", nodeWin);
                    local param1 = DB.getValue(nodeWin, "p1", 0);
                    local param2 = DB.getValue(nodeWin, "p2", 0);
                    local param3 = DB.getValue(nodeWin, "p3", 0);

					
                    if( param1 ~= "" ) then
                        formula = string.gsub(formula, "[(]p1[)]", param1);
                    end
                    
                    if( param2 ~= "" ) then
                        formula = string.gsub(formula, "[(]p2[)]", param2);
                    end

                    if( param3 ~= "" ) then
                        formula = string.gsub(formula, "[(]p3[)]", param3);
                    end

					-- If the Grouped Rolls Extension is installed, allow lookup of an attribute value from the parent of the list 
					local attriblist = nodeWin.getParent();
					local category = attriblist.getParent();
--					local cat_stat = category.getChild("category_stat");
--					if( cat_stat ~= nil ) then
						--Debug.chat("Stat: ", cat_stat.getPath(), cat_stat.getValue() );
--						formula = string.gsub(formula, "[(]att[)]", cat_stat.getValue());
--					end

					-- If reference rolls Extension is installed, allow lookup of the parameters off a referenced roll
					formula = replaceRefValue( nodeWin, formula, "a", "refa_path" );
					formula = replaceRefValue( nodeWin, formula, "b", "refb_path" );
					formula = replaceRefValue( nodeWin, formula, "c", "refc_path" );
					
--					Debug.chat("formula: ", formula);
					myClichatcommand = nodeWin.getChild("clichatcommand");
--					Debug.chat("clichatcommand: ", clichatcommand);
                    nodeWin.getChild("clichatcommand").setValue(formula);
					
                end -- formula not empty
            end -- formula enabled
        end -- formulaEnabled node not nil
    end -- we weren't passed nil for nodeWin
	
	return formula;
end

function replaceRefValue( nodeWin, formula, refLetter, refChild )
	local ref_pathNode = nodeWin.getChild(refChild);
	if( ref_pathNode ~= nil ) then
		
		local ref1_path = ref_pathNode.getValue();
		if( ref_path ~= "" ) then 

			local refgf = nil;
			local refp1 = nil;
			local refp2 = nil;
			local refp3 = nil;

			if( string.sub(ref1_path,1,1) == "." ) then
				refgf = nodeWin.getChild(ref1_path);
				refp1 = nodeWin.getChild(ref1_path .. ".p1");
				refp2 = nodeWin.getChild(ref1_path .. ".p2");
				refp3 = nodeWin.getChild(ref1_path .. ".p3");
			else
				refgf = DB.getChild(ref1_path,".");
				refp1 = DB.getChild(ref1_path,"p1");
				refp2 = DB.getChild(ref1_path,"p2");
				refp3 = DB.getChild(ref1_path,"p3");
			end


			if( refp1 == nil and refgf ~= nil and refgf ~= "" ) then
				local val = refgf.getValue();
				if( val ~= nil and (type(val) == "string" or type(val) == "number") ) then
					formula = string.gsub(formula, "[(]"..refLetter.."[)]", val);
				end
			end

			if( refp1 ~= nil ) then
				formula = string.gsub(formula, "[(]"..refLetter.."1[)]", refp1.getValue());
			end

			if( refp2 ~= nil ) then
				formula = string.gsub(formula, "[(]"..refLetter.."2[)]", refp2.getValue());
			end

			if( refp3 ~= nil ) then
				formula = string.gsub(formula, "[(]"..refLetter.."3[)]", refp3.getValue());
			end					
		end
	end	
	
	return formula;
end