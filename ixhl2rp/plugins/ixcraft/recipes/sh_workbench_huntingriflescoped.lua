RECIPE.name = "Scoped Hunting Rifle"
RECIPE.description = "Attach a long-range telescopic sight to a hunting rifle. This upgrade is irreversible."
RECIPE.model = "models/weapons/tfa_fallout/w_fallout_hunting_scoped_rifle.mdl"
RECIPE.category = "Attach To Weapon"
RECIPE.requirements = {
	["huntingrifle"] = 1,
	["huntingriflescope"] = 1

}

RECIPE.results = {
	["huntingriflescoped"] = 1
}


RECIPE:PostHook("OnCanSee", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 200 * 40) then
			return true
		end
	end

	return false
	
end)


