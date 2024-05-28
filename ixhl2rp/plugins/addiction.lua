local PLUGIN = PLUGIN
PLUGIN.name = "Addiction"
PLUGIN.author = "Scrat Knapp"
PLUGIN.desc = "Handles drug addictions."

local charmeta = ix.meta.character


function charmeta:DrugHandler(client, chemname, addictchance)
	local character = client:GetCharacter()

	-- prepare chem name - remove all spaces between words, make lowercase.
	chemname = string.lower(chemname:gsub("%s+", ""))

	if character:HasFeat(chemname .. "addiction") then 
		
		local addictioneffects = character:GetFeat(chemname .. "addiction")
		
		for k, v in pairs(ix.feats.list) do
			if (k == chemname .. "addiction") then
			
				if v.statDebuffs then 
					for y, z in pairs(v.statDebuffs) do
						character:RemoveBuff(chemname .. "addiction", y)
					end
				end 

			end
		end
	else 

		local getsAddicted = math.random(1, 100)
		if getsAddicted >= (100 - addictchance) then
			character:AddFeat(chemname .. "addiction")
			character:GetPlayer():EmitSound("cwfallout3/ui/medical/addicted.wav")
			character:GetPlayer():NewVegasNotify("You've become addicted to " .. chemname .. "!", "messagePain", 5)

			for k, v in pairs(ix.feats.list) do
				if (v.OnSetup) then
					v:OnSetup(client) -- If there's an OnSetup() function, call it.
				end
			end



		end
	end 


end 

function charmeta:ReapplyAddiction(client, chemname)
	local character = client:GetCharacter()

	-- prepare chem name - remove all spaces between words, make lowercase.
	chemname = string.lower(chemname:gsub("%s+", ""))

	for k, v in pairs(ix.feats.list) do
		if (character:HasFeat(k) and k == chemname .. "addiction") then
			v:OnSetup(client) -- If there's an OnSetup() function, call it.
		end
	end
end 

function charmeta:ReapplyAllAddictions(client)
	local character = client:GetPlayer()
	for k, v in pairs(ix.feats.list) do
		if (character:HasFeat(k) and string.find(k, "addiction")) then
			v:OnSetup(client) -- If there's an OnSetup() function, call it.
		end
	end
end 

function charmeta:PurgeAddictions(client, permanent)
	local character = client:GetCharacter()

	for k, v in pairs(ix.feats.list) do
		if (character:HasFeat(k) and string.find(k, "addiction")) then
			if v.statDebuffs then 
				for y, z in pairs(v.statDebuffs) do
					character:RemoveBuff(k, y)
				end
			end 

			if (permanent) then character:RemoveFeat(k) end
		end
	end
end 


function PLUGIN:PlayerLoadedCharacter(client, character, currentChar) 
	for k, v in pairs(ix.feats.list) do
		if (character:HasFeat(k) and string.find(k, "addiction")) then
			v:OnSetup(client) -- If there's an OnSetup() function, call it.
		end
	end
end 