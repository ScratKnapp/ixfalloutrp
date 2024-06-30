local PLUGIN = PLUGIN
PLUGIN.name = "Loot Stamina"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "Adds a stamina system for looting, or any other uses for such a thing."
local charmeta = ix.meta.character

ix.char.RegisterVar("Stamina", {
    field = "Stamina",
    fieldType = ix.type.number,
    default = 5,
    isLocal = true,
    bNoDisplay = true
})

if SERVER then

function charmeta:AddStamina(amount)
    local char = self

    if char:GetStamina() + amount > 5 then
        return
    else 
        char:SetStamina(char:GetStamina() + amount)
    end
end 

function charmeta:TakeStamina(amount)
    local char = self
    if char:GetStamina() - amount < 0 then
        char:SetStamina(0)
        return
    else 
        char:SetStamina(char:GetStamina() - amount)
    end
end 

local ticktimer = 0
	
function PLUGIN:PlayerTick(ply)
    
    if ticktimer > CurTime() then return end
    ticktimer = CurTime() + 1
    
    local char = ply:GetCharacter()
    
    if ply:GetNetVar("staminatick", 0) <= CurTime() then
        ply:SetNetVar("staminatick", 1800 + CurTime())
        char:AddStamina(1)
    end
end





end 

ix.command.Add("MyStamina", {
	description = "View your current health, AP, and resistances.",
	OnRun = function(self, client)
        local char = client:GetCharacter()
        return "You currently have " .. char:GetStamina() .. " stamina."
	end
})

ix.command.Add("CharGiveStamina", {
	description = "Give Stamina to player.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
	OnRun = function(self, client, target, amount)
        target:AddStamina(amount)
        return "You added " ..amount.. " stamina to " .. target:GetName() .. ". They now have " .. target:GetStamina()
	end
})

ix.command.Add("CharTakeStamina", {
	description = "Take Stamina from a player.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
	OnRun = function(self, client, target, amount)
        target:TakeStamina(amount)
        return "You took " ..amount.. " stamina from " .. target:GetName() .. ". They now have " .. target:GetStamina()
	end
})




