RECIPE.name = "Saturnite Plate"
RECIPE.description = "Forge some Saturnite Plate to slot into an armor."
RECIPE.model = "models/weapons/w_suitcase_passenger.mdl"
RECIPE.category = "Armor"
RECIPE.requirements = {
	["steel"] = 2,
	["screws"] = 6,
	["adhesive"] = 5,
	["leatherupgrade1"] = 1,
	["metalupgrade1"] = 1,
	["saturnite"] = 2,
}

RECIPE.results = {
	["saturniteplateupgrade"] = 1
}

RECIPE.blueprint = "saturniteplateblueprint"


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


