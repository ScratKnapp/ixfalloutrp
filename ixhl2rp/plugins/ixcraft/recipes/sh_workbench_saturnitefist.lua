RECIPE.name = "Saturnite Power Fist"
RECIPE.description = "Replace the outer casing of a Power Fist with Saturnite for a much quicker weapon."
RECIPE.model = "models/mosi/fallout4/props/weapons/melee/powerfist.mdl"
RECIPE.category = "Melee Weapons"
RECIPE.requirements = {
	["screws"] = 4,
	["powerfist"] = 4,
	["adhesive"] = 3,
	["saturnite"] = 2,
}

RECIPE.results = {
	["powerfist_saturnite"] = 1
}

RECIPE.blueprint = "saturnitepowerfistblueprint"


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


