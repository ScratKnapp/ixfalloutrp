local PLUGIN = PLUGIN
PLUGIN.name = "Radiation"
PLUGIN.author = "Some body onc-"
PLUGIN.desc = "Radiation System"

ix.util.Include("cl_plugin.lua")

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

ix.char.RegisterVar("Rads", {
    field = "rads",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("RadImmune", {
    field = "radimmune",
    fieldType = ix.type.boolean,
    default = false,
    isLocal = true,
    bNoDisplay = true
})

function playerMeta:GetRads()
	return self:GetCharacter():GetRads()
end

function playerMeta:GetRadsPercent()
	return math.Clamp(self:GetCharacter():GetRads()/100, 0 ,1)
end

function playerMeta:addRadiation(amount)
	local curRadiation = self:GetCharacter():GetRads()
	self:setRadiation(math.Clamp(math.min(curRadiation) + amount, 0, 1000))
end


function playerMeta:radDebuffHandler(debuff)
	char = self:GetCharacter()
	-- Handle all buffs/debuffs here and call in each rad level check further down.
	if debuff == "NONE" then
		char:RemoveBoost("minorrad", "endurance")

		char:RemoveBoost("advancedrad", "endurance")
		char:RemoveBoost("advancedrad", "agility")

		char:RemoveBoost("criticalrad", "endurance")
		char:RemoveBoost("criticalrad", "agility")
		char:RemoveBoost("criticalrad", "strength")

		char:RemoveBoost("deadlyrad", "endurance")
		char:RemoveBoost("deadlyrad", "agility")
		char:RemoveBoost("deadlyrad", "strength")
	end

	if debuff == "MINOR" then
		char:AddBoost("minorrad", "endurance", -1)

		char:RemoveBoost("advancedrad", "endurance")
		char:RemoveBoost("advancedrad", "agility")

		char:RemoveBoost("criticalrad", "endurance")
		char:RemoveBoost("criticalrad", "agility")
		char:RemoveBoost("criticalrad", "strength")

		char:RemoveBoost("deadlyrad", "endurance")
		char:RemoveBoost("deadlyrad", "agility")
		char:RemoveBoost("deadlyrad", "strength")
	end

	if debuff == "ADVANCED" then
		char:RemoveBoost("minorrad", "endurance")

		char:AddBoost("advancedrad", "endurance", -2)
		char:AddBoost("advancedrad", "agility", -1)

		char:RemoveBoost("criticalrad", "endurance")
		char:RemoveBoost("criticalrad", "agility")
		char:RemoveBoost("criticalrad", "strength")

		char:RemoveBoost("deadlyrad", "endurance")
		char:RemoveBoost("deadlyrad", "agility")
		char:RemoveBoost("deadlyrad", "strength")
	end

	if debuff == "CRITICAL" then
		char:RemoveBoost("minorrad", "endurance")

		char:RemoveBoost("advancedrad", "endurance")
		char:RemoveBoost("advancedrad", "agility")

		char:AddBoost("criticalrad", "endurance", -3)
		char:AddBoost("criticalrad", "agility", -2)
		char:AddBoost("criticalrad", "strength", -1)

		char:RemoveBoost("deadlyrad", "endurance")
		char:RemoveBoost("deadlyrad", "agility")
		char:RemoveBoost("deadlyrad", "strength")
	end

	if debuff == "DEADLY" then
		char:RemoveBoost("minorrad", "endurance")

		char:RemoveBoost("advancedrad", "endurance")
		char:RemoveBoost("advancedrad", "agility")

		char:RemoveBoost("criticalrad", "endurance")
		char:RemoveBoost("criticalrad", "agility")
		char:RemoveBoost("criticalrad", "strength")

		char:AddBoost("deadlyrad", "endurance", -3)
		char:AddBoost("deadlyrad", "agility", -2)
		char:AddBoost("deadlyrad", "strength", -2)
	end


end

function playerMeta:setRadiation(amount)
	local char = self:GetCharacter()


	if char:GetRadImmune() == true then
		amount = 0
	end

	char:SetRads((math.Clamp(amount, 0, 1000)))

		-- Less than 200 rads, no effects, make sure to remove all debuffs related to rad posioning.
	if char:GetRads() < 200 then
		self:radDebuffHandler("NONE")

		-- 200-399 Rads: Minor Rad Poisoning, -1 END
	elseif char:GetRads() > 199 and char:GetRads() < 400 then
		self:radDebuffHandler("MINOR")
		char:GetPlayer():NewVegasNotify("You are sick with Minor Radiation Poisoning.", "messageSad", 5)

		-- 400-599 Rads: Advanced Rad Poisoning, -2 END, -1 AGI
	elseif char:GetRads() > 399 and char:GetRads() < 600 then
		self:radDebuffHandler("ADVANCED")
		char:GetPlayer():NewVegasNotify("You are sick with Advanced Radiation Poisoning.", "messageSad", 5)

		-- 600-799 Rads: Critical Rad Poisoning, -3 END, -2 AGI, -1 STR
	elseif char:GetRads() > 599 and char:GetRads() < 800 then
		self:radDebuffHandler("CRITICAL")
		char:GetPlayer():NewVegasNotify("You are sick with Critical Radiation Poisoning.", "messageSad", 5)

		-- 800+ Rads: Deadly Rad Poisoning -3 END, -2 AGI, -2 STR
	elseif char:GetRads() >= 800 then
		self:radDebuffHandler("DEADLY")
		char:GetPlayer():NewVegasNotify("You are sick with Deadly Radiation Poisoning.", "messageSad", 5)
	end

end

function playerMeta:hasGeiger()
	local char = self:GetChar()
	local geigercounter = self:GetNetVar("ixhasgeiger")

	if !geigercounter then
		return false
	else
		return true
	end
end

function PLUGIN:PostPlayerLoadout(client)
	if client:GetData("ixhasgeiger", false) then
		client:SetNetVar("ixhasgeiger", true)
	end
end





-- Register HUD Bars.
if (CLIENT) then
	local char = LocalPlayer():GetCharacter()
	local color = Color(39, 174, 96)
	function PLUGIN:RenderScreenspaceEffects()
			-- Advanced Poisoning.
		if char:GetRads() > 399 and char:GetRads() < 600 then
			DrawMotionBlur(0.05, 0.25, 0.001)

			-- Critical Poisoning.
		elseif char:GetRads() > 599 and char:GetRads() < 800 then
			DrawMotionBlur(0.05, 0.25, 0.001)

			-- Deadly Poisoning.
		elseif char:GetRads() >= 800 then
			DrawMotionBlur(0.1, 0.35, 0.001)
		end
    end
else
	local PLUGIN = PLUGIN
	
	function PLUGIN:CharacterPreSave(character)
		local savedRads = math.Clamp(character.player:GetRads(), 0, 1000)
		character:SetData("radiation", savedRads)
	end

	function PLUGIN:PostPlayerLoadout(client)
		if (client:GetCharacter():GetRads()) then
			client:SetRads(client:GetRads())
		else
			client:SetRads(0)
		end
	end

	function PLUGIN:PlayerDeath(client)
		client.resetRads = false
	end

	function PLUGIN:PlayerSpawn(client)
		if (client.resetRads) then
			client:SetRads(0)
			client.resetRads = false
		end
	end
end

ix.command.Add("CharSetRadiation", {
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.number,
	},
	OnRun = function(self, client, target, radiation)
		local radiation = tonumber(radiation)

		if target:GetRadImmune() == true then
			return client:Notify(target:GetName() .. " is set to be immune to radiation.")
		end

		target:GetPlayer():setRadiation(radiation)

		if client == target:GetPlayer() then
            client:Notify("You have set your radiation to "..radiation)
        else
            client:Notify("You have set "..target:GetName().."'s radiation to "..radiation)
            target:Notify(client:Name().." has set your radiation to "..radiation)
        end
	end
})

ix.command.Add("CharAddRadiation", {
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.number,
	},
	OnRun = function(self, client, target, radiation)
		local radiation = tonumber(radiation)

		if target:GetRadImmune() == true then
			return client:Notify(target:GetName() .. " is set to be immune to radiation.")
		end

		target:GetPlayer():addRadiation(radiation)

		if client == target:GetPlayer() then
            client:Notify("You have added "..radiation.. " Rads to yourself. You now have " .. target:GetRads() .. " Rads.")
        else
            client:Notify("You have added "..radiation.. " to " .. target:GetName() .. ". They now have " .. target:GetRads() .. " Rads.")
            target:Notify(client:Name().." has added " .. radiation.. "to your Rads. You now have" .. target:GetRads() .. " Rads.")
        end
	end
})

ix.command.Add("CharSetRadImmune", {
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.bool,
	},
	OnRun = function(self, client, target, radimmune)
		
		target:SetRadImmune(radimmune)
		
		if (target:GetRadImmune() == true) then
			target:SetRads(0)
			return client:Notify(target:GetName() .. "has been set to be immune to radiation.")
		end

		if (target:GetRadImmune() == false) then
			return client:Notify(target:GetName() .. "has been set to be vulnerable to radiation.")
		end
	end
})