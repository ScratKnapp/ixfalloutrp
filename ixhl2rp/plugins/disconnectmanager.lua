local PLUGIN = PLUGIN
PLUGIN.name = "Disconnect Manager"
PLUGIN.author = "Scrat Knapp"
PLUGIN.desc = "Handles disconnections to ensure stat changes are not kept between sessions, breaking some buffs."


function PLUGIN:OnCharacterDisconnect(client, character)

	local inventory = character:GetInventory()
	local equippedItems = {} 

	for k, v in pairs (inventory:GetItems()) do
		if(!v:GetData("equip", false)) then continue end --ignores unequipped items

		if v.isArmor then 

			v:RemoveOutfit(client)


			if(v.dT) then
				character:SetChardt(character:GetChardt() - v:GetData("dT"))
			end 
	
			if(v.eT) then
				character:SetCharet(character:GetCharet() - v:GetData("eT"))
			end 
	
			if(v:GetData("dR")) then
				character:SetChardr(character:GetChardr() - v:GetData("dR"))
			end 
	
			if(v:GetData("radResist")) then
				character:SetCharradresist(character:GetCharradresist() - v:GetData("radResist"))
			end 
	
			if(v.healthBoost) then
				character:SetCharmaxhpboost(character:GetCharmaxhpboost() - v.healthBoost)
			end 
	
			if(v.apBoost) then
				character:SetCharapboost(character:GetCharapboost() - v.apBoost)
			end 
	
			if(v:GetData("weightClass")) then
				character:RemoveSkillBoost("lightarmor", "evasion")
				character:RemoveSkillBoost("mediumarmor", "evasion")
				character:RemoveSkillBoost("heavyarmor", "evasion")
				character:RemoveSkillBoost("veryheavyarmor", "evasion")
				character:RemoveSkillBoost("superheavyarmor", "evasion")
			end 
		end 
	end

	character:SetCharapboost(0)
	character:SetCharradresistboost(0)
	character:SetChardtboost(0)
	character:SetCharetboost(0)
	character:SetChardrboost(0)
	character:SetCharmaxhpboost(0)

	character:SetData("usingRadX", false)
	character:SetData("usingJet", false)
	character:SetData("usingMedX", false)
	character:SetData("usingBuffout", false)
	character:SetData("usingRocket", false)
	character:SetData("usingPsycho", false)
	character:SetData("usingRebound", false)
	character:SetData("usingHydra", false)
	character:SetData("usingHealingpowder", false)
	character:SetData("usingHealingpoultice", false)
	character:SetData("usingCigarette", false)
	character:SetData("usingMentats", false)
	character:SetData("usingSuperStimpak", false)
	character:SetData("inPowerArmor", false)

	character:SetData("timertable", {})


	local boosts = character:GetBoosts()

	for attribID, v in pairs(boosts) do
		for boostID, _ in pairs(v) do
			character:RemoveBuff(boostID, attribID)
		end
	end
	
end 


