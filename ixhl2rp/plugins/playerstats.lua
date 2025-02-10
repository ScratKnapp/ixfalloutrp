local PLUGIN = PLUGIN
PLUGIN.name = "Player Stats"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "RPG Derived Statistics System."


local charMeta = ix.meta.character

function charMeta:GetMaxHP()
    local endboost = self:GetAttribute("endurance")
    local luckboost = self:GetAttribute("luck")

    return endboost + luckboost
end

function charMeta:GetHP()
    return self:GetData("HP", self:GetMaxHP())
end

function charMeta:DamageHP(amount)
    self:SetData("HP", self:GetHP() - amount)
    if self:GetHP() < 0 then self:SetData("HP", 0) end
end

function charMeta:RestoreHP(amount)
    self:SetData("HP", self:GetHP() + amount)
    if self:GetHP() > self:GetMaxHP() then self:SetData("HP", self:GetMaxHP()) end
end

function charMeta:GetMaxLuckPoints()
    local luckboost = self:GetAttribute("luck")
    return luckboost
end

function charMeta:GetLuckPoints()
    local luckboost = self:GetAttribute("luck")
    return luckboost
end

function charMeta:TakeLuckPoints(amount)
    self:SetData("LuckPoints", self:GetLuckPoints() - amount)
    if self:GetLuckPoints() < 0 then self:SetData("LuckPoints", 0) end
end

function charMeta:RestoreLuckPoints(amount)
    self:SetData("LuckPoints", self:GetMaxLuckPoints())
end

function charMeta:GetAreaResistance(area, type)

    -- This function is unlike GetLocationArmor because it will also include non-armor sources of damage resistance like Perks

    local armorboost = self:GetLocationArmor(area, type)

    return armorboost

end 


ix.command.Add("Status", {
    description = "Check your current HP and other statuses.",
    OnRun = function(self, client)
        local char = client:GetCharacter()
        client:Notify("Health: " .. char:GetHP() .. "/" .. char:GetMaxHP())
        client:Notify("Luck Points: " .. char:GetLuckPoints() .. "/" .. char:GetMaxLuckPoints())
        client:Notify("Damage Resistance: (Physical/Energy/Radiation)")
        client:Notify("Head: " .. char:GetAreaResistance("head", "Physical") .. "/" .. char:GetAreaResistance("head", "Energy") .. "/" .. char:GetAreaResistance("head", "Radiation"))
        client:Notify("Chest: " .. char:GetAreaResistance("chest", "Physical") .. "/" .. char:GetAreaResistance("chest", "Energy") .. "/" .. char:GetAreaResistance("chest", "Radiation"))
        client:Notify("Left Arm: " .. char:GetAreaResistance("armleft", "Physical") .. "/" .. char:GetAreaResistance("armleft", "Energy") .. "/" .. char:GetAreaResistance("armleft", "Radiation"))
        client:Notify("Right Arm: " .. char:GetAreaResistance("armright", "Physical") .. "/" .. char:GetAreaResistance("armright", "Energy") .. "/" .. char:GetAreaResistance("armright", "Radiation"))
        client:Notify("Left Leg: " .. char:GetAreaResistance("legleft", "Physical") .. "/" .. char:GetAreaResistance("legleft", "Energy") .. "/" .. char:GetAreaResistance("legleft", "Radiation"))
        client:Notify("Right Leg: " .. char:GetAreaResistance("legright", "Physical") .. "/" .. char:GetAreaResistance("legright", "Energy") .. "/" .. char:GetAreaResistance("legright", "Radiation"))
     

    end
})

ix.command.Add("CharGiveHP", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
    description = "Add HP to target.",
    OnRun = function(self, client, target, amount)
        if amount < 0 then return "Amount must be a positive number." end
        target:RestoreHP(amount)
        return "Added " .. amount .. " HP to " .. target:GetName() .. "."
    end
})

ix.command.Add("CharTakeHP", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
    description = "Take HP from target.",
    OnRun = function(self, client, target, amount)
        if amount < 0 then return "Amount must be a positive number." end
        target:DamageHP(amount)
        return "Removed " .. amount .. " HP from " .. target:GetName() .. "."
    end
})

ix.command.Add("rest", {
    description = "Heal yourself based on your Stamina and recover your Willpower. Can be used once every 20 hours.",
    OnRun = function(self, client)
        local character = client:GetCharacter()
        local currentTime = os.time()
        local lastUseTime = character:GetData("lastRest", 0)
        local timeSinceLastUse = currentTime - lastUseTime
        if timeSinceLastUse < 60 * 60 * 20 then
            local remainingTime = math.ceil((60 * 60 * 6 - timeSinceLastUse) / 60)
            return "You can only use this command once every 20 hours. Please wait " .. remainingTime .. " minutes."
        end

        local healamount = character:GetAttribute("stamina") + 1
        character:RestoreHP(healamount)
        character:SetData("SpentWP", 0)
        client:Notify("Restored " .. healamount .. "HP and filled Willpower.")
        if character:HasClass("Medic") then
            character:SetData("FreeHeals", 0)
            client:Notify("Gave free uses of /medicheal according to Medic class level.")
        end

        character:SetData("lastRest", currentTime)
    end
})

ix.command.Add("medicheal", {
    description = "Use your WP to heal an ally.",
    OnRun = function(self, client)
        local char = client:GetCharacter()
        local ply = client
        if not char:HasClass("Medic") then return "You need to have the Medic class to use this ability." end
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local target = util.TraceLine(data).Entity
        if not (IsValid(target) and target:IsPlayer() and target:GetCharacter()) then return "You need to be looking at another character." end
        local skill = char:GetSkill("medicine") + char:GetAttribute("intelligence")
        local classLevel = char:HasClass("Medic")
        if char:GetData("FreeHeals", 0) < classLevel then
            char:SetData("FreeHeals", char:GetData("FreeHeals", 0) + 1)
            client:Notify("Your current class level allows you to perform this heal for free. You can do this " .. classLevel - char:GetData("FreeHeals") .. " more times before your next Rest.")
        else
            if char:GetWillpower() == 0 then return "You need at least 1 Willpower to use this ability." end
            char:SetData("SpentWP", char:GetData("SpentWP", 0) + 1)
        end

        local difficulty = 6
        local pass = 0
        local fail = 0
        for i = skill, 1, -1 do
            local diceroll = math.random(1, 10)
            if diceroll == 10 then
                pass = pass + 2
            elseif diceroll == 1 then
                pass = pass - 1
            elseif diceroll >= difficulty then
                pass = pass + 1
            else
                fail = fail + 1
            end
        end

        if pass < 0 then pass = 0 end
        client:Notify("Rolling Medicine + Intelligence: " .. skill .. " dice against Diff 6")
        if pass == 0 then return "0 Successes! Roll Failed." end
        target:GetCharacter():RestoreHP(pass)
        client:Notify("Rolled " .. pass .. " successes. Healing " .. target:GetCharacter():GetName() .. " for " .. pass .. "HP.")
        target:Notify(char:GetName() .. " healed you for " .. pass .. "HP.")
    end
})

