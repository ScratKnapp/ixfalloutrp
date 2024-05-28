RECIPE.name = "Suppressed Sniper Rifle"
RECIPE.description = "Attach a noise-reducing suppressor to a Sniper Rifle. This upgrade is irreversible."
RECIPE.model = "models/weapons/tfa_fallout/w_fallout_sniper_rifle_suppressed.mdl"
RECIPE.category = "Attach To Weapon"
RECIPE.requirements = {
	["sniperrifle"] = 1,
	["sniperriflesuppressor"] = 1

}

RECIPE.results = {
	["suppressedsniperrifle"] = 1
}


RECIPE:PostHook("OnCanSee", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 200 * 40) then
			return true
		end
	end

	return false
	
end)


