local PLUGIN = PLUGIN
PLUGIN.name = "Damage"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "RPG Derived Damage System."


local charMeta = ix.meta.character

function charMeta:Damage(damage, area, type, modifydr)

    local client = self:GetPlayer()
    local area = string.lower(area)
    local validAreas = {"head", "chest", "armleft", "armright", "legleft", "legright"}
    local validTypes = {"Physical", "Energy", "Radiation"}
    local niceNameTable =
    {
        ["head"] = "Head",
        ["chest"] = "Chest",
        ["armleft"] = "Left Arm",
        ["armright"] = "Right Arm",
        ["legleft"] = "Left Leg",
        ["legright"] = "Right Leg"

    }       
    local type = string.SetChar(type, 1, string.upper(type:sub(1, 1))) -- Converts first letter of type to uppercase
    if not modifydr then modifydr = 0 end 

    -- Exit function if either type or area are not valid
    if not table.HasValue(validAreas, area) then return false end
    if not table.HasValue(validTypes, type) then return false end

    local niceArea = niceNameTable[area]
    local protection = self:GetAreaResistance(area, type)
    local armoritem = self:GetLocationArmorItem(area, type)

    protection = protection + modifydr

    client:Notify("You're hit for " .. damage .. " " .. type .. " damage to the " .. niceArea .. "!" )
    
    if damage > protection then
        -- Pierces armor

        local damageTaken = damage - protection

        -- Power armor takes the health damage instead of you
        if armoritem and armoritem.powerArmor then
            local armorhp = armoritem:GetHP()

            armoritem:SetData("HP", armorhp - damageTaken)

            -- Piece is broken
            if armoritem:GetData("HP") <= 0 then
                armoritem:SetData("HP", 0)
                armoritem:SetData("equip", nil)
                client:Notify("Your " .. armoritem:GetName() .. " takes  " .. damageTaken .. " damage and breaks!")
            else
                client:Notify("Your " .. armoritem:GetName() .. " takes  " .. damageTaken .. " damage! It has " .. armoritem:GetHP() .. "HP left.")
            end 
        else
            self:DamageHP(damageTaken)
            client:Notify("You take " .. damageTaken .. " damage! You have " .. self:GetHP() .. "HP left.")
            return damageTaken
        end 



    else
        client:Notify("Your " .. armoritem:GetName() .. " blocks the damage.")
        return 0
    end 
    
end



ix.command.Add("Damage", {
    description = "Apply damage to a player. Leave area blank to pick random body part.",
    arguments = {ix.type.character, ix.type.number, ix.type.string, bit.bor(ix.type.string, ix.type.optional), bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, target, damage, type, area, modifydr)
       

        local validAreas = {"head", "chest", "armleft", "armright", "legleft", "legright"}
        local validTypes = {"physical", "energy", "radiation"}


        -- If no area is chosen, roll 1 location die to pick randomly
        if not area then 
            area = ix.dice.locationDice(1) 
        end 

        local uglyNameTable = 
        {
            ["Head,"] = "head",
            ["Torso,"] = "chest",
            ["Left Arm,"] = "armleft",
            ["Right Arm,"] = "armright",
            ["Left Leg,"] = "legleft",
            ["Right Leg,"] = "legright"
    
        }  

        area = uglyNameTable[area]

        if not modifydr then modifydr = 0 end 

        if not table.HasValue(validAreas, area) then
            local errorString = ("Invalid area. Valid areas are: ")
            for k, v in pairs(validAreas) do errorString = errorString .. "," .. v end 
            client:Notify(errorString)
        end

        if not table.HasValue(validTypes, string.lower(type)) then
            local errorString = ("Invalid damage type. Valid damage types are are: ")
            for k, v in pairs(validTypes) do errorString = errorString .. "," .. v end 
            client:Notify(errorString)
        end


        local result = target:Damage(damage, area, type, modifydr)

        if result > 0 then
           client:Notify(target:GetName() .. " has taken " .. result .. " damage. They have " .. target:GetHP() .. " HP left.")
        else
            client:Notify(target:GetName() .. " blocks the damage!")
        end 

    end
})

