-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

Health = {
	GRIEVOUS = {
		basicStatus = "Dying",
		detailedStatus = "Grievously Wounded",
		basicColor = "404040",
		detailedColor = "404040",
		standing = false
	},	
	MORTAL = {
		basicStatus = "Dying",
		detailedStatus = "Mortally Wounded",
		basicColor = "404040",
		detailedColor = "404040",
		standing = false
	},
	DEAD = {
		basicStatus = "Dead",
		detailedStatus = "Dead",
		basicColor = "404040",
		detailedColor = "404040",
		standing = false
	},
	UNCONSCIOUS = {
		basicStatus = "Unconscious",
		detailedStatus = "Unconscious",
		basicColor = "6C2DC7",
		detailedColor = "6C2DC7",
		standing = false
	},
	CRITICAL = {
		basicStatus = "Heavy",
		detailedStatus = "Critical",
		basicColor = "C11B17",
		detailedColor = "C11B17",
		standing = true
	},
	HEAVY = {
		basicStatus = "Heavy",
		detailedStatus = "Heavy",
		basicColor = "C11B17",
		detailedColor = "E56717",
		standing = true
	},
	MODERATE = {
		basicStatus = "Wounded",
		detailedStatus = "Moderate",
		basicColor = "408000",
		detailedColor = "AF7817",
		standing = true
	},
	LIGHT = {
		basicStatus = "Wounded",
		detailedStatus = "Light",
		basicColor = "408000",
		detailedColor = "408000",
		standing = true
	},
	HEALTHY = {
		basicStatus = "Healthy",
		detailedStatus = "Healthy",
		basicColor = "006600",
		detailedColor = "006600",
		standing = true
	},
	new = function(sNodeType, node) 
		local self = { nHP = 0, nTemp = 0, nWounds = 0, nNonlethal = 0 }
		
		local percentWounded = function()
			if self.nHP > 0 then
				return self.nWounds / self.nHP;
			end
			return 0;
		end
		
		local percentDamaged = function()
			if self.nHP > 0 then
				return (self.nWounds + self.nNonlethal) / (self.nHP + self.nTemp);
			end
			return 0;
		end
		
		if sNodeType == "ct" then
			self.nHP = math.max(DB.getValue(node, "hp", 0), 0);
			self.nTemp = math.max(DB.getValue(node, "hptemp", 0), 0);
			self.nWounds = math.max(DB.getValue(node, "wounds", 0), 0);
			self.nNonlethal = math.max(DB.getValue(node, "nonlethal", 0), 0);
		elseif sNodeType == "pc" then
			self.nHP = math.max(DB.getValue(node, "hp.total", 0), 0);
			self.nTemp = math.max(DB.getValue(node, "hp.temporary", 0), 0);
			self.nWounds = math.max(DB.getValue(node, "hp.wounds", 0), 0);
			self.nNonlethal = math.max(DB.getValue(node, "hp.nonlethal", 0), 0);
		end
		
		local nPercentWounded = percentWounded()
		local nPercentDamaged = percentDamaged()
		
		local health;
		if nPercentWounded > 1 then
			if (self.nWounds - self.nHP) < 7 then
				health = Health.GRIEVOUS;
			elseif (self.nWounds - self.nHP) < 10 then
				health = Health.MORTAL;
			else
				health = Health.DEAD;
			end
		elseif nPercentDamaged >= 1 then
			health = Health.UNCONSCIOUS 
		elseif nPercentDamaged >= .75 then
			health = Health.CRITICAL
		elseif nPercentDamaged >= .5 then
			health = Health.HEAVY
		elseif nPercentDamaged >= .25 then
			health = Health.MODERATE
		elseif nPercentDamaged > 0 then
			health = Health.LIGHT
		else
			health = Health.HEALTHY
		end
		
		function health:percentDamaged()
			return percentDamaged()
		end
		
    function health:isDamaged()
      return percentDamaged() > 0
    end

		function health:percentWounded()
			return percentWounded()
		end
		
		function health:woundBarColor()
			local nRedR = 255;
			local nRedG = 0;
			local nRedB = 0;
			local nYellowR = 255;
			local nYellowG = 191;
			local nYellowB = 0;
			local nGreenR = 0;
			local nGreenG = 255;
			local nGreenB = 0;
			
			local sColor;
      if self:isStanding() then
				local nBarR, nBarG, nBarB;
				if percentDamaged() >= 0.5 then
					local nPercentGrade = (percentDamaged() - 0.5) * 2;
					nBarR = math.floor((nRedR * nPercentGrade) + (nYellowR * (1.0 - nPercentGrade)) + 0.5);
					nBarG = math.floor((nRedG * nPercentGrade) + (nYellowG * (1.0 - nPercentGrade)) + 0.5);
					nBarB = math.floor((nRedB * nPercentGrade) + (nYellowB * (1.0 - nPercentGrade)) + 0.5);
				else
					local nPercentGrade = percentDamaged() * 2;
					nBarR = math.floor((nYellowR * nPercentGrade) + (nGreenR * (1.0 - nPercentGrade)) + 0.5);
					nBarG = math.floor((nYellowG * nPercentGrade) + (nGreenG * (1.0 - nPercentGrade)) + 0.5);
					nBarB = math.floor((nYellowB * nPercentGrade) + (nGreenB * (1.0 - nPercentGrade)) + 0.5);
				end
				sColor = string.format("%02X%02X%02X", nBarR, nBarG, nBarB);
      elseif percentWounded() > 1 then
				sColor = "C0C0C0";
			elseif percentDamaged() > 1 then
				sColor = "8C3BFF";
			end

			return sColor;
		end
		
		function health:isStanding()
			return self.standing
		end
		
		function health:status()
			if OptionsManager.isOption("WNDC", "detailed") then
				return self.detailedStatus
			else
				return self.basicStatus
			end
		end
		
		function health:woundColor()
			if OptionsManager.isOption("WNDC", "detailed") then
				return self.detailedColor
			else
				return self.basicColor
			end
		end
		
		function health:disabled()
			return nPercentDamaged >= 1
		end
		
		return health;
	end
}

function getHealth(sNodeType, node)
	return Health.new(sNodeType, node);
end

function getAbilityEffectsBonus(rActor, sAbility)
	if not rActor or not sAbility then
		return 0, 0;
	end
	
	local sAbilityEffect = GameSystem.ability_ltos[sAbility];
	if not sAbilityEffect then
		return 0, 0;
	end
	
	local nEffectMod, nAbilityEffects = EffectManager.getEffectsBonus(rActor, sAbilityEffect, true);
	
	local nAbilityMod = 0;
	local nAbilityScore = getAbilityScore(rActor, sAbility);
	local nAffectedScore = math.max(nAbilityScore + nEffectMod, 0);
		
	local nCurrentBonus = GameSystem.getAbilityBonus(nAbilityScore);
	local nAffectedBonus = GameSystem.getAbilityBonus(nAffectedScore);
		
	nAbilityMod = nAffectedBonus - nCurrentBonus;

	return nAbilityMod, nAbilityEffects;
end

function getAbilityScore(rActor, sAbility)
	if not sAbility then
		return -1;
	end
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if not nodeActor then
		return -1;
	end
	
	local nStatScore = -1;
	
	local sShort = string.sub(string.lower(sAbility), 1, 3);
	if sActorType == "pc" then
		if sShort == "str" then
			nStatScore = DB.getValue(nodeActor, "abilities.strength.score", 0);
		elseif sShort == "dex" then
			nStatScore = DB.getValue(nodeActor, "abilities.dexterity.score", 0);
		elseif sShort == "con" then
			nStatScore = DB.getValue(nodeActor, "abilities.constitution.score", 0);
		elseif sShort == "int" then
			nStatScore = DB.getValue(nodeActor, "abilities.intelligence.score", 0);
		elseif sShort == "wis" then
			nStatScore = DB.getValue(nodeActor, "abilities.wisdom.score", 0);
		elseif sShort == "cha" then
			nStatScore = DB.getValue(nodeActor, "abilities.charisma.score", 0);
		end
	else
		if DB.getValue(nodeActor, "monster", "") == "false" then
			if sShort == "str" then
				nStatScore = DB.getValue(nodeActor, "strength", 0);
			elseif sShort == "dex" then
				nStatScore = DB.getValue(nodeActor, "dexterity", 0);
			elseif sShort == "con" then
				nStatScore = DB.getValue(nodeActor, "constitution", 0);
			elseif sShort == "int" then
				nStatScore = DB.getValue(nodeActor, "intelligence", 0);
			elseif sShort == "wis" then
				nStatScore = DB.getValue(nodeActor, "wisdom", 0);
			elseif sShort == "cha" then
				nStatScore = DB.getValue(nodeActor, "charisma", 0);
			end
		end
	end
	
	return nStatScore;
end

function getAbilityBonus(rActor, sAbility)
	if not sAbility then
		return 0;
	end
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if not nodeActor then
		return 0;
	end
	
	local nStatScore = getAbilityScore(rActor, sStat);
	if nStatScore < 0 then
		return 0;
	end

	local nStatVal = 0;
	if StringManager.contains(GameSystem.abilities, sAbility) then
		nStatVal = GameSystem.getAbilityBonus(nStatScore);
		if sActorType == "pc" then
			nStatVal = nStatVal + DB.getValue(nodeActor, "abilities." .. sAbility .. ".bonusmodifier", 0);
		end
	end
	
	return nStatVal;
end

function getSpellDefense(rActor)
	local nSR = 0;
	
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		if sActorType == "ct" then
			nSR = DB.getValue(nodeActor, "sr", 0);
		elseif sActorType == "pc" then
			nSR = DB.getValue(nodeActor, "defenses.sr.total", 0);
		else
			local sSpecialQualities = string.lower(DB.getValue(nodeActor, "sa", ""));
			local sSpellResist = string.match(sSpecialQualities, "sr (%d+)");
			if sSpellResist then
				nSR = tonumber(sSpellResist) or 0;
			end
		end
	end
	
	return nSR;
end

function getBaseAttackBonus(rActor)
	local nBTH = 0;
	
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		if sActorType == "ct" then
			nBTH = DB.getValue(nodeActor, "bth", 0);
		elseif sActorType == "pc" then
			nBTH = DB.getValue(nodeActor, "attackbonus.base", 0);
		else
			if DB.getValue(nodeActor, "monster", "") == "false" then
				nBTH = DB.getValue(nodeActor, "bth", 0);
			else
				nBTH = DB.getValue(nodeActor, "monsterbth", 0);
			end
		end
	end
		
	return nBTH;
end

function getDefenseValue(rAttacker, rDefender, rRoll)
	-- VALIDATE
	if not rDefender or not rRoll then
		return nil, 0, 0;
	end
	
	local sAttack = rRoll.sDesc;
	
	-- DETERMINE ATTACK TYPE AND DEFENSE
	local sAttackType = string.match(sAttack, "%[ATTACK.*%((%w+)%)%]");
	local bTouch = string.match(sAttack, "%[TOUCH%]");
	local bFlatFooted = string.match(sAttack, "%[FF%]");
	local nCover = tonumber(string.match(sAttack, "%[COVER %-(%d)%]")) or 0;
	local nConceal = tonumber(string.match(sAttack, "%[CONCEAL %-(%d)%]")) or 0;
	local bAttackerBlinded = string.match(sAttack, "%[BLINDED%]");

	-- Determine the defense database node name
	local nDefense = 10;
	local nFlatFootedMod = 0;
	local nTouchMod = 0;

	local sDefenderType, nodeDefender = ActorManager.getTypeAndNode(rDefender);
	if not nodeDefender then
		return nil, 0, 0;
	end

	if sDefenderType == "pc" then
		nDefense = DB.getValue(nodeDefender, "ac.totals.general", 10);
		nFlatFootedMod = nDefense - DB.getValue(nodeDefender, "ac.totals.flatfooted", 10);
		nTouchMod = nDefense - DB.getValue(nodeDefender, "ac.totals.touch", 10);
	elseif sDefenderType == "ct" then
		nDefense = DB.getValue(nodeDefender, "ac_final", 10);
		nFlatFootedMod = nDefense - DB.getValue(nodeDefender, "ac_flatfooted", 10);
		nTouchMod = nDefense - DB.getValue(nodeDefender, "ac_touch", 10);
	else
		if DB.getValue(nodeDefender, "monster", "") == "false" then
			nDefense = DB.getValue(nodeDefender, "ac", 10);
		else
			local sAC = DB.getValue(nodeDefender, "monsterac", "");
			nDefense = tonumber(string.match(sAC, "^%s*(%d+)")) or 10;
		end
		nFlatFootedMod = 0;
		nTouchMod = nDefense - 10;
	end
	if nTouchMod < 0 then
		nTouchMod = 0;
	end
	if nFlatFootedMod < 0 then
		nFlatFootedMod = 0;
	end
	
	-- APPLY FLAT-FOOTED AND TOUCH ADJUSTMENTS
	if bTouch then
		nDefense = nDefense - nTouchMod;
	end
	if bFlatFooted then
		nDefense = nDefense - nFlatFootedMod;
	end
	
	nDefenseStatMod = getAbilityBonus(rDefender, "dexterity");
	
	-- EFFECT MODIFIERS
	local nAttackEffectMod = 0;
	local nDefenseEffectMod = 0;
	if ActorManager.hasCT(rDefender) then
		-- SETUP
		local nBonusAC = 0;
		local nBonusStat = 0;
		local nBonusSituational = 0;
		
		-- BUILD ATTACK FILTER 
		local aAttackFilter = {};
		if sAttackType == "M" then
			table.insert(aAttackFilter, "melee");
		elseif sAttackType == "R" then
			table.insert(aAttackFilter, "ranged");
		end

		-- Get attacker attack modifiers specific to target
		local aBonusTargetedAttackDice, nBonusTargetedAttack = EffectManager.getEffectsBonus(rAttacker, "ATK", false, aAttackFilter, rDefender, true);
		nAttackEffectMod = nAttackEffectMod + StringManager.evalDice(aBonusTargetedAttackDice, nBonusTargetedAttack);
					
		-- Get defender AC modifiers
		local nACMod, nACEffectCount = EffectManager.getEffectsBonus(rDefender, "AC", true, aAttackFilter, rAttacker);
		nBonusAC = nBonusAC + nACMod;
		
		-- Get defender ability modifiers
		nBonusStat = getAbilityEffectsBonus(rDefender, sDefenseStat);

		-- Get defender condition modifiers
		if EffectManager.hasEffectCondition(rDefender, "Prone") then
			nBonusSituational = nBonusSituational - 5;
		end
		if EffectManager.hasEffectCondition(rDefender, "Blinded") then
			nBonusSituational = nBonusSituational - 5;
		end
		if EffectManager.hasEffectCondition(rDefender, "Stunned") then
			nBonusSituational = nBonusSituational - 2;
		end
		if EffectManager.hasEffectCondition(rDefender, "Cowering") then
			nBonusSituational = nBonusSituational - 2;
		end
		
		-- Get defender concealment modifiers
		if not bAttackerBlinded then
			if EffectManager.hasEffect(rDefender, "Invisible", rAttacker) then
				nBonusSituational = nBonusSituational + 10;
			elseif EffectManager.hasEffect(rDefender, "CONC4", rAttacker) then
				nBonusSituational = nBonusSituational + 10;
			elseif EffectManager.hasEffect(rDefender, "CONC3", rAttacker) then
				nBonusSituational = nBonusSituational + 6;
			elseif EffectManager.hasEffect(rDefender, "CONC2", rAttacker) then
				nBonusSituational = nBonusSituational + 4;
			elseif EffectManager.hasEffect(rDefender, "CONC1", rAttacker) then
				nBonusSituational = nBonusSituational + 2;
			end
		end
		
		-- Get defender cover modifiers
		if EffectManager.hasEffect(rDefender, "COVER4", rAttacker) then
			nBonusSituational = nBonusSituational + 10;
		elseif EffectManager.hasEffect(rDefender, "COVER3", rAttacker) then
			nBonusSituational = nBonusSituational + 6;
		elseif EffectManager.hasEffect(rDefender, "COVER2", rAttacker) then
			nBonusSituational = nBonusSituational + 4;
		elseif EffectManager.hasEffect(rDefender, "COVER1", rAttacker) then
			nBonusSituational = nBonusSituational + 2;
		end
		
		-- ADD IN EFFECT MODIFIERS
		nDefenseEffectMod = nBonusAC + nBonusStat + nBonusSituational;
	end
	
	-- Return the final defense value
	return nDefense + nDefenseEffectMod - nAttackEffectMod, nAttackEffectMod, nDefenseEffectMod;
end
