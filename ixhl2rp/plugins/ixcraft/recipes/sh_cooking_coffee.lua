RECIPE.name = "Black Coffee"
RECIPE.description = "Brew up a fresh mug of bitter but strong coffee."
RECIPE.model = "models/mosi/fnv/props/junk/coffeemug.mdl"
RECIPE.category = "Food"
RECIPE.requirements = {
	["coffeecup"] = 1,
	["waterclean"] = 1,
	["honeymesquitepod"] = 1,
	["coyotetobaccochew"] = 1,
}

RECIPE.results = {
	["blackcoffee"] = 1
}


RECIPE:PostHook("OnCanSee", function(recipeTable, client)
	if (client:GetCharacter():GetSkill("survival", 0) < 5) then 
		return false
	end 

	for _, v in ipairs(ents.FindByClass("ix_station_cookingfire")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 200 * 40) then
			return true
		end
	
	end
	return false
end)

RECIPE:PostHook("OnCanCraft", function(recipeTable, client)

	if client:GetCharacter():GetMoney() == 0 then
		return false, "You need at least one cap to seal the bottle."
	end
		
end)

RECIPE:PostHook("OnCraft", function(recipeTable, client)
	client:GetCharacter():SetMoney(client:GetCharacter():GetMoney() - 1)
	client:NewVegasNotify("You use one of your caps to seal up the bottle.", "messageNeutral", 4)
	return 
end)


