PLUGIN.name = 'Player Stats'
PLUGIN.author = 'Scrat Knapp'
PLUGIN.description = "Adds stats and commands for manging player health, armor, and AP tabletop style."

local playerMeta = FindMetaTable("Player")
-- Create vars for character HP, DT, DR, ET, and AP, with an extra var for each for temporary boosts to these things.

ix.char.RegisterVar("Charcurrenthp", {
    field = "charcurrenthp",
    fieldType = ix.type.number,
    default = 50,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("Charmaxhp", {
    field = "charmaxhp",
    fieldType = ix.type.number,
    default = 50,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("Charmaxhpboost", {
    field = "charmaxhpboost",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})
ix.char.RegisterVar("Chardt", {
    field = "chardt",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("Chardtboost", {
    field = "chardtboost",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("Chardr", {
    field = "chardr",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("Chardrboost", {
    field = "chardrboost",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("Charet", {
    field = "charet",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("charetboost", {
    field = "charetboost",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("charap", {
    field = "charap",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("charapboost", {
    field = "charapboost",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("charradresist", {
    field = "charradresist",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("charradresistboost", {
    field = "charradresistboost",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

ix.char.RegisterVar("charcritchance", {
    field = "charcritchance",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

function playerMeta:GetTotalCharHp()
    local maxhp = self:GetCharacter():GetCharmaxhp() + self:GetCharacter():GetCharmaxhpboost()
   -- self:SetMaxHealth(maxhp)
	return maxhp
end

function playerMeta:GetTotalCharDt()
	return self:GetCharacter():GetChardt() + self:GetCharacter():GetChardtboost()
end

function playerMeta:GetTotalCharDr()
	return self:GetCharacter():GetChardr() + self:GetCharacter():GetChardrboost()
end

function playerMeta:GetTotalCharEt()
	return self:GetCharacter():GetCharet() + self:GetCharacter():GetCharetboost()
end

function playerMeta:GetTotalCharAp()
	return self:GetCharacter():GetCharap() + self:GetCharacter():GetCharapboost()
end

function playerMeta:GetTotalCharAp()
	return self:GetCharacter():GetCharap() + self:GetCharacter():GetCharapboost()
end

function playerMeta:GetTotalCharRadResist()
	return self:GetCharacter():GetCharradresist() + self:GetCharacter():GetCharradresistboost()
end

function playerMeta:GetTotalCharRadResist()
	return self:GetCharacter():GetCharradresist() + self:GetCharacter():GetCharradresistboost()
end

function playerMeta:CalculateBaseHP()
	local char = self:GetCharacter()
    local hpboost = math.floor(char:GetAttribute("endurance") * 5)
    local hp = 50 + hpboost
    return hp
end

function playerMeta:CalculateBaseAP()
	local char = self:GetCharacter()
    local apboost =  math.floor(char:GetAttribute("agility") / 2)
    local ap = 5 + apboost
    return ap
end

function playerMeta:CalculateBaseRadResist()
	local char = self:GetCharacter()
    local radresist =  math.floor(char:GetAttribute("endurance") * 2)
    return radresist
end

function playerMeta:AdjustHealth(type, amount)
    local char = self:GetCharacter()
    local player = self

    -- A player is considered staggered if they're at or below 80% HP, Stunned if at or below 40% HP, and Incapped at 0% HP. Find out what these tresholds are by comparing them to player's max hp.
    maxhp = self:GetTotalCharHp()
    stagger = maxhp * 0.80
    stun = maxhp * 0.40
    incap = 0
	
    -- If hurt, reduce player HP by damage amount. If the amount would drop them below 0, put them to zero as we don't use negative HP here. Script HP already has this in place.
    if type == "hurt" then
        char:SetCharcurrenthp(char:GetCharcurrenthp() - amount)
        if char:GetCharcurrenthp() < 0 then char:SetCharcurrenthp(0) end
        player:SetHealth(player:Health() - amount)
    end 

    -- If heal, increase player HP by damage amount. If the amount would put them above their current maximum, just set them to the maximum as we don't use overheals here.
    if type == "heal" then
        if (char:GetCharcurrenthp() + amount > player:GetTotalCharHp()) then
            char:SetCharcurrenthp(player:GetTotalCharHp())
            player:SetHealth(player:GetTotalCharHp())
        else
            char:SetCharcurrenthp(char:GetCharcurrenthp() + amount)
            player:SetHealth(player:Health() + amount)
        end
    end 

    newhp = char:GetCharcurrenthp()

    -- Based on new health after hurt/heal, give a status message and apply debuffs to stats. If health goes down, remove lighter debuffs and replace with worse ones. As health goes up, reduce 

    if newhp == 0 then
        player:Notify("You're incapacitated and unable to fight, requiring stabilization.")

        if type == "heal" then
            ix.log.Add(client, "damage", char, "healed", amount, "and is currently Incapacitated.")
        else
            ix.log.Add(client, "damage", char, "taken", amount, "and is currently Incapacitated.")
        end 

        char:BuffStat("incap", "endurance", -4)
        char:BuffStat("incap", "agility", -4)
        char:BuffStat("incap", "perception", -4)
        char:BuffStat("incap", "strength", -4)

        char:RemoveBuff("stun", "endurance")
        char:RemoveBuff("stun", "agility")
        char:RemoveBuff("stun", "perception")
        char:RemoveBuff("stun", "strength")
        return

    elseif newhp <= stun then
        player:Notify("You're stunned by incoming damage and take a notable hit to your stats.")
     
        if type == "heal" then
            ix.log.Add(client, "damage", char, "healed", amount, "and is currently Stunned.")
        else
            ix.log.Add(client, "damage", char, "taken", amount, "and is currently Stunned.")
        end 

        char:BuffStat("stun", "endurance", -3)
        char:BuffStat("stun", "agility", -3)
        char:BuffStat("stun", "perception", -3)
        char:BuffStat("stun", "strength", -3)

        char:RemoveBuff("stagger", "endurance")
        char:RemoveBuff("stagger", "agility")
        char:RemoveBuff("stagger", "perception")
        char:RemoveBuff("stagger", "strength")
        
        char:RemoveBuff("incap", "endurance")
        char:RemoveBuff("incap", "agility")
        char:RemoveBuff("incap", "perception")
        char:RemoveBuff("incap", "strength")
        
        return

    elseif newhp <= stagger then
        player:Notify("You're staggered by incoming damage and take a slight hit to your stats.")
       
        if type == "heal" then
            ix.log.Add(client, "damage", char, "healed", amount, "and is currently Staggered.")
        else
            ix.log.Add(client, "damage", char, "taken", amount, "and is currently Staggered.")
        end 

        char:BuffStat("stagger", "endurance", -1)
        char:BuffStat("stagger", "agility", -1)
        char:BuffStat("stagger", "perception", -1)
        char:BuffStat("stagger", "strength", -1)

        char:RemoveBuff("incap", "endurance")
        char:RemoveBuff("incap", "agility")
        char:RemoveBuff("incap", "perception")
        char:RemoveBuff("incap", "strength")
        
        char:RemoveBuff("stun", "endurance")
        char:RemoveBuff("stun", "agility")
        char:RemoveBuff("stun", "perception")
        char:RemoveBuff("stun", "strength")
    
        return

    else
        if type == "heal" then
            ix.log.Add(client, "damage", char, "healed", amount, ".")
        else
            ix.log.Add(client, "damage", char, "taken", amount, ".")
        end 

        char:RemoveBuff("incap", "endurance")
        char:RemoveBuff("incap", "agility")
        char:RemoveBuff("incap", "perception")
        char:RemoveBuff("incap", "strength")
        
        char:RemoveBuff("stun", "endurance")
        char:RemoveBuff("stun", "agility")
        char:RemoveBuff("stun", "perception")
        char:RemoveBuff("stun", "strength")

        char:RemoveBuff("stagger", "endurance")
        char:RemoveBuff("stagger", "agility")
        char:RemoveBuff("stagger", "perception")
        char:RemoveBuff("stagger", "strength")
    end 
end 

function PLUGIN:OnCharacterCreated(client, character)
    -- After char creation, assign initial health, ap, and radresists.

    local char = character

    local hpboost = math.floor(char:GetAttribute("endurance") * 5)
    local hp = 50 + hpboost

    local apboost =  math.floor(char:GetAttribute("agility") / 2)
    local ap = 5 + apboost

    local radresist =  math.floor(char:GetAttribute("endurance") * 2)

    local critchance = char:GetAttribute("luck")

    char:SetCharmaxhp(hp)
    char:SetCharmaxhpboost(0)
    char:SetCharcurrenthp(hp)
    char:SetCharap(ap)
    char:SetCharapboost(0)

    char:SetCharradresist(radresist)
    char:SetCharradresistboost(0)

    char:SetChardt(0)
    char:SetChardtboost(0)
    char:SetCharet(0)
    char:SetCharetboost(0)
    char:SetChardr(0)
    char:SetChardrboost(0)

    char:SetCharcritchance(critchance)




    if character:HasFeat("kamikaze") then
        character:SetChardt(character:GetChardt() - 5)
        character:SetCharet(character:GetCharet() - 5)
        character:SetChardr(character:GetChardr() - 15)
        
        character:SetCharap(character:GetCharap() + 2)
    end 

    if character:HasFeat("pure") then
        character:SetCharmaxhp(character:GetCharmaxhp() + 10)
        character:SetCharradresist(character:GetCharradresist() - 25)
        character:SetCharcurrenthp(character:GetCharmaxhp())
    end 

    if character:GetLineage() == "none" then
        character:SetLineage("wastelander")
        character:AddFeat("wastelander")
    end 

    if character:GetLineage() == "tribal" then

        local unarmedboost = math.clamp(character:GetSkill("unarmed") + 5, 0, 20)
        local meleeboost = math.clamp(character:GetSkill("meleeweapons") + 5, 0, 20)
        local survivalboost = math.clamp(character:GetSkill("survival") + 5, 0, 20)
    end 
   
    
end 

ix.command.Add("Status", {
	description = "View your current health, AP, and resistances.",
	OnRun = function(self, client)
		local str = ""
        local char = client:GetCharacter()
        
        str = str .. "\nHealth: " .. char:GetCharcurrenthp() .. "/" .. client:GetTotalCharHp()
        if char:GetCharmaxhpboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"

        str = str .. "AP: " .. client:GetTotalCharAp()
        if char:GetCharapboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"

        str = str .. "Rad Resistance: " .. client:GetTotalCharRadResist() .. "%"
        if char:GetCharradresistboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"

        str = str .. "DT: " .. client:GetTotalCharDt()
        if char:GetChardtboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"

        str = str .. "ET: " .. client:GetTotalCharEt()
        if char:GetCharetboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"
        
        str = str .. "DR: " .. client:GetTotalCharDr() .. "%"
        if char:GetChardrboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"
        
        return str
	end
})

ix.command.Add("CharGetStatus", {
	description = "View current health, AP, and resistances of given player.",
    adminOnly = true,
    arguments = {ix.type.character},
	OnRun = function(self, client, target)
		local str = target:GetName() .. " has the following stats:"
        local char = target
        local player = target:GetPlayer()
        
        str = str .. "\nHealth: " .. char:GetCharcurrenthp() .. "/" .. player:GetTotalCharHp()
        if char:GetCharmaxhpboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"

        str = str .. "AP: " .. player:GetTotalCharAp()
        if char:GetCharapboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"

        str = str .. "Rad Resistance: " .. player:GetTotalCharRadResist() .. "%"
        if char:GetCharradresistboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"

        str = str .. "DT: " .. player:GetTotalCharDt()
        if char:GetChardtboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"

        str = str .. "ET: " .. player:GetTotalCharEt()
        if char:GetCharetboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"
        
        str = str .. "DR: " .. player:GetTotalCharDr()
        if char:GetChardrboost() > 0 then str = str .. " (+)" end
        str = str .. "\n"
        
        return str
	end
})

ix.command.Add("CharGetAttributes", {
	description = "Get all main SPECIAL attributes of given character.",
    adminOnly = true,
    arguments = {ix.type.character},
	OnRun = function(self, client, target)
		local str = target:GetName() .. " has the following SPECIAL stats:"
        local char = target
        local player = target:GetPlayer()
        
        str = str .. "\nStrength: " .. char:GetAttribute("strength")
        str = str .. "\nPerception: " .. char:GetAttribute("perception")
        str = str .. "\nEndurance: " .. char:GetAttribute("endurance")
        str = str .. "\nCharisma: " .. char:GetAttribute("charisma")
        str = str .. "\nIntelligence: " .. char:GetAttribute("intelligence")
        str = str .. "\nAgility: " .. char:GetAttribute("agility")
        str = str .. "\nLuck: " .. char:GetAttribute("luck")

        
        return str
	end
})

ix.command.Add("CharGetTraits", {
	description = "Get all traits given character has.",
    adminOnly = true,
    arguments = {ix.type.character},
	OnRun = function(self, client, target)
		local str = target:GetName() .. " has the following traits:"
        local char = target
        local player = target:GetPlayer()
        local featTable = char:GetFeats()

        for k, v in pairs(featTable) do
            str = str .. "\n" .. k
        end 

        return str
	end
})

ix.command.Add("CharGiveTrait", {
	description = "Give trait to character.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.string},
	OnRun = function(self, client, target, trait)
        target:AddFeat(trait)
        return "Gave " .. trait .. " to " ..target:GetName()
	end
})

ix.command.Add("CharTakeTrait", {
	description = "Take a trait from a character.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.string},
	OnRun = function(self, client, target, trait)
        target:RemoveFeat(trait)
        return "Removed " .. trait .. " from " ..target:GetName()
	end
})





ix.command.Add("Damage", {
    description = "Inflict damage on a player.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.string, ix.type.number, bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, target, damtype, damage, ap)
        local char = target
        local player = target:GetPlayer()

        -- Get player armor and health stats
        local dt = player:GetTotalCharDt()
        local et = player:GetTotalCharEt()
        local dr = player:GetTotalCharDr()
        local hp = player:GetTotalCharHp()
        local luck = target:GetAttribute("luck")

        local isPowerArmored = target:GetData("inPowerArmor", false)


       

        -- Format entries so that they're ready to work with - lowercase damtype, chop off any decimal points
        local damtype = string.lower(damtype)
        local damage = damage - (damage % 1)
        if (ap) then local ap = ap - (ap % 1) else ap = 0 end

    
        -- Ballistic weapons, blasts, and melee
        if damtype == "physical" then
            player:Notify("You're hit with ".. damage .. " physical damage!")
            if (ap > 0) then player:Notify("It pierces " .. ap .. " points of DT!") end

            -- Subtract DR percentage from damage. Will always be at least 1 point of damage blocked if you have any DR.
            dt = dt - ap 
            if dt < 0 then dt = 0 end

            if dr ~= 0 then 
                local reduction = damage * (dr / 100)
                damage = math.ceil(damage - reduction)
                if damage < 0 then damage = 0 end
                player:Notify("Your DR reduces the damage by " .. dr .. "%!")
            end 

            local minimumdamage = math.ceil(damage * 0.20)

            if dt ~= 0 then 
                damage = damage - dt
                if damage < 0 then damage = 0 end
                player:Notify("Your DT reduces the damage by " .. dt .. " points!")
            end 

            if damage < minimumdamage then
                damage = minimumdamage

                if isPowerArmored then damage = math.ceil(damage/2) end

                client:Notify(target:GetName() .. " has taken " .. damage .. " minimum physical damage!")
                player:Notify("You take " .. damage  .. " minimum damage!")
                player:AdjustHealth("hurt", damage)
            else 
                client:Notify(target:GetName() .. " has taken " .. damage .. " physical damage, piercing their armor.")
                player:Notify("You take " .. damage  .. " damage! Your armor is pierced.")
                player:AdjustHealth("hurt", damage)
              --  player:DamageArmor(target, 1)
            end 

        -- Laser, Plasma, Fire 
        elseif damtype == "energy" then
            player:Notify("You're hit with ".. damage .. " energy damage!")
            if (ap > 0) then player:Notify("It pierces " .. ap .. " points of ET!") end

            -- Subtract AP value from ET value. Since you can't have negative protection, if below 0, make 0.
            et = et - ap 
            if et < 0 then et = 0 end

            if dr ~= 0 then 
                local reduction = damage * (dr / 100)
                damage = math.ceil(damage - reduction)
                if damage < 0 then damage = 0 end
                player:Notify("Your DR reduces the damage by " .. dr .. "%!")
            end 

            local minimumdamage = math.ceil(damage * 0.20)

            if et ~= 0 then 
                damage = damage - et
                if damage < 0 then damage = 0 end
                player:Notify("Your ET reduces the damage by " .. et .. " points!")
            end 

            if damage < minimumdamage then
                damage = minimumdamage

               -- if isPowerArmored == true then damage = math.ceil(damage/2) player:Notify("In power armor") end

                client:Notify(target:GetName() .. " has taken " .. damage .. " minimum energy damage!")
                player:Notify("You take " .. damage  .. " minimum damage!")
                player:AdjustHealth("hurt", damage)
            else 
                client:Notify(target:GetName() .. " has taken " .. damage .. " energy damage, piercing their armor.")
                player:Notify("You take " .. damage  .. " damage! Your armor is pierced.")
                player:AdjustHealth("hurt", damage)
               -- player:DamageArmor(target, 1)
            end 
        
        -- Bleeding damage. Bypasses armor
        elseif damtype == "bleed" then
            client:Notify(target:GetName() .. " has taken " .. damage .. " bleed damage!")
            player:Notify("You have taken " .. damage .. " bleed damage!")
            player:AdjustHealth("hurt", damage)
        
        -- Poison damage. Bypasses armor
        elseif damtype == "poison" then
            client:Notify(target:GetName() .. " has taken " .. damage .. " poison damage!")
            player:Notify("You have taken " .. damage .. " poison damage!")
            player:AdjustHealth("hurt", damage)

        -- Some other form of damage as necessary. Bypasses armor
        elseif damtype == "direct" then
            client:Notify(target:GetName() .. " has taken " .. damage .. " damage!")
            player:Notify("You have taken " .. damage .. " damage!")
            player:AdjustHealth("hurt", damage)
        else 
            return "Invalid damage type. Accepted options: Physical, Energy, Bleed, Poison, Direct"
        end 
    end
})

if (SERVER) then
    ix.log.AddType("damage", function(client, target, actiontype, damage, status)
        return string.format("%s has %s %s damage %s", target:GetName(), actiontype, damage, status)
    end)
end


ix.command.Add("Heal", {
    description = "Heal player by given amount.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, amount)
        local char = target
        local player = target:GetPlayer()

        player:AdjustHealth("heal", amount)
        return "Healed " .. char:GetName() .. " by " .. amount .. " points."

    end
})

ix.command.Add("ResetStats", {
    description = "Debug command - reset player health, chem usage, and armor stats to default.",
    adminOnly = true,
    arguments = {ix.type.character},
    OnRun = function(self, client, target)
        local char = target
        local player = target:GetPlayer()

        local hp = player:CalculateBaseHP()
        local ap = player:CalculateBaseAP()
        local radresist = player:CalculateBaseRadResist()

        char:SetCharmaxhp(hp)
        char:SetCharmaxhpboost(0)
        char:SetCharcurrenthp(hp)

        char:SetCharap(ap)
        char:SetCharapboost(0)

        char:SetCharradresist(radresist)
        char:SetCharradresistboost(0)

        char:SetChardt(0)
        char:SetChardtboost(0)
        char:SetCharet(0)
        char:SetCharetboost(0)
        char:SetChardr(0)
        char:SetChardrboost(0)

        char:SetData("usingRadX", false)
        char:SetData("usingJet", false)
        char:SetData("usingMedX", false)
        char:SetData("usingBuffout", false)
        char:SetData("usingRocket", false)
        char:SetData("usingPsycho", false)
        char:SetData("usingRebound", false)
        char:SetData("usingHydra", false)
        char:SetData("usingHealingpowder", false)
        char:SetData("usingHealingpoultice", false)
        char:SetData("usingCigarette", false)
        char:SetData("usingMentats", false)
        char:SetData("usingSuperStimpak", false)

        local boosts = char:GetBoosts()

		for attribID, v in pairs(boosts) do
			for boostID, _ in pairs(v) do
				char:RemoveBuff(boostID, attribID)
			end
		end

        return "Reset player stats."


    end
})

ix.command.Add("CharSetDT", {
    description = "Set character's current DT to the given number.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, value)
        target:SetChardt(value)
        target:SetChardtboost(0)
        client:Notify("Set DT of " .. target:GetName() .. " to " .. value)
    end
})

ix.command.Add("CharSetET", {
    description = "Set character's current ET to the given number.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, value)
        target:SetCharet(value)
        target:SetCharetboost(0)
        client:Notify("Set ET of " .. target:GetName() .. " to " .. value)
    end
})

ix.command.Add("CharSetDR", {
    description = "Set character's current DR to the given number.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, value)
        target:SetChardr(value)
        target:SetChardrboost(0)
        client:Notify("Set DR of " .. target:GetName() .. " to " .. value)
    end
})

ix.command.Add("CharSetRadResist", {
    description = "Set character's current Radiation Resistance to the given number.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, value)
        target:SetCharradresist(value)
        target:SetCharradresistboost(0)
        client:Notify("Set Rad Resistance of " .. target:GetName() .. " to " .. value)
    end
})

ix.command.Add("CharSetAP", {
    description = "Set character's current AP to the given number.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, value)
        target:SetCharap(value)
        target:SetCharapboost(0)
        client:Notify("Set AP of " .. target:GetName() .. " to " .. value)
    end
})

ix.command.Add("CharSetHP", {
    description = "Set character's current HP to the given number.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, value)
        target:SetCharcurrenthp(value)
        client:Notify("Set HP of " .. target:GetName() .. " to " .. value)
    end
})

ix.command.Add("CharSetMaxHP", {
    description = "Set character's current Maximum HP to the given number.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, value)
        target:SetCharmaxhp(value)
        target:SetCharmaxhpboost(0)
        client:Notify("Set Max HP of " .. target:GetName() .. " to " .. value)
    end
})

ix.command.Add("CharSetCritChance", {
    description = "Set character's current Critical Hit chance % to the given number.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, value)
        target:SetCharcritchance(value)
        client:Notify("Set Crit Chance % of " .. target:GetName() .. " to " .. value)
    end
})

ix.command.Add("CharGetCritChance", {
    description = "Get character's current Critical Hit chance %.",
    adminOnly = true,
    arguments = {ix.type.character},
    OnRun = function(self, client, target)

        chance = target:GetCharcritchance()
        client:Notify("Crit Chance % of " .. target:GetName() .. " is " .. chance)
    end
})






