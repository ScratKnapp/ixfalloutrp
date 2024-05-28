RECIPE.name = "Scoped Laser Rifle"
RECIPE.description = "Attach a mid-range reflex sight to a laser rifle. This upgrade is irreversible."
RECIPE.model = "models/weapons/laserrifle/w_laserrifle_scoped.mdl"
RECIPE.category = "Attach To Weapon"
RECIPE.requirements = {
	["laserrifle"] = 1,
	["laserriflescope"] = 1

}

RECIPE.results = {
	["laserriflescoped"] = 1
}


RECIPE:PostHook("OnCanSee", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 200 * 40) then
			return true
		end
	end

	return false
	
end)


