RECIPE.name = ".45 ACP Breakdown"
RECIPE.description = "Disassemble some .45 ACP."
RECIPE.model = "models/mosi/fallout4/ammo/45.mdl"
RECIPE.category = "Ammo"
RECIPE.requirements = {
	["ammo_45autoammo"] = 1
}

RECIPE.results = {
	["leadcan"] = 1,
	["casinglargepistol"] = 1,
	["powderpistol"] = 1,
	["primerlargepistol"] = 1,
}


RECIPE:PostHook("OnCanSee", function(recipeTable, client)
	if (client:GetCharacter():GetSkill("repair", 0) < 10) then 
		return false
	end 

	for _, v in pairs(ents.FindByClass("ix_station_reloadingbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 200 * 40) then
			return true
		end
	end
	return false
end)


