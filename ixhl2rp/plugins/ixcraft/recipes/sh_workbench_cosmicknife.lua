RECIPE.name = "Cosmic Knife"
RECIPE.description = "Forge a super-sharp knife from Saturnite."
RECIPE.model = "models/mosi/fnv/props/junk/kitchenknife.mdl"
RECIPE.category = "Melee Weapons"
RECIPE.requirements = {
	["steel"] = 4,
	["screws"] = 2,
	["adhesive"] = 5,
	["saturnite"] = 2,
}

RECIPE.results = {
	["cosmicknife"] = 1
}

RECIPE.blueprint = "cosmicknifeblueprint"


RECIPE:PostHook("OnCanSee", function(recipeTable, client)

	if (client:GetCharacter():GetSkill("repair", 0) < 25) then 
		return false
	end 

	for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 200 * 40) then
			return true
		end
	end

	return false
	
end)


