local PLUGIN = PLUGIN
PLUGIN.name = "Stat Rolling"
PLUGIN.author = "Val"
PLUGIN.description = "cheese.wav"


----= Attributes =----


-- Chat type for rolls
ix.chat.Register("rollstat", {
    format = "** %s rolled for %s: %s Roll + %s Stat Boost %s = %s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local att = data.attr or "STR"
        local add = data.additive
        local mod = data.mod
        local total = data.initialroll + add + mod

        if mod ~= 0 then
            mod = "with a Modifier of " .. mod .. " "
        else
            mod = ""
        end

        local translated = L2(self.uniqueID.."Format", speaker:Name(), text)

        chat.AddText(self.color, translated and "** "..translated or string.format(self.format,speaker:Name(), att, text, add, mod, total))
    end
})

 if (SERVER) then
    ix.log.AddType("rollStat", function(client, value, attrib, add, mod)

        total = value + add + mod
        return string.format("%s has rolled for %s: %s with a %s Stat Bonus and %s modifier = %s", client:Name(), attrib, value, add, mod, total)
    end)
end

-- Go through each attribute and make a command of the same that rolls a d10, then adds stat value to it.
for k, v in pairs(ix.attributes.list) do

    ix.command.Add(string.lower(v.name), {
        description = "Roll a " .. v.name .. " check on a d10 + Attribute. Optional modifier.",
        arguments = {bit.bor(ix.type.number, ix.type.optional)},
        OnRun = function(self, client, modifier)
            local value = math.random(0, 10)
            local attr = v.name
            local att = client:GetCharacter():GetAttribute(string.lower(v.name))

            local add = att 
            local char = client:GetCharacter()
            local modifier = modifier or 0
            
            ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
                attr = attr,
                additive=add,
                initialroll = value,
                mod = modifier
    
            })
    
           ix.log.Add(client, "rollStat", value, attr, add, modifier)
        end
    })
end 



----= Skills =----

-- Strength --
ix.command.Add("Unarmed", {
    description = "Roll an Unarmed check on a d10 + Strength. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Unarmed"
        local att =  math.floor(client:GetCharacter():GetAttribute("strength") / 2)
        local add = att + char:GetUnarmed()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Melee", {
    description = "Roll a Melee Weapons check on a d10 + Strength. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Melee Weapons"
        local att = math.floor(client:GetCharacter():GetAttribute("strength") / 2)
        local add = att + char:GetMelee()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

-- Perception --
ix.command.Add("Energy", {
    description = "Roll an Energy Weapons check on a d10 + Perception. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Energy Weapons"
        local att = math.floor(client:GetCharacter():GetAttribute("perception") / 2)
        local add = att + char:GetEnergyWeapons()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Explosives", {
    description = "Roll an Explosives check on a d10 + Perception. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Perception"
        local att = math.floor(client:GetCharacter():GetAttribute("perception") / 2)
        local add = att + char:GetExplosives()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Lockpick", {
    description = "Roll a Lockpick check on a d10 + Perception. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Lockpicking"
        local att = math.floor(client:GetCharacter():GetAttribute("perception") / 2)
        local add = att + char:GetLockpick()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})


-- Endurance --
ix.command.Add("Survival", {
    description = "Roll a Survival check on a d10 + Endurance. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Survival"
        local att = math.floor(client:GetCharacter():GetAttribute("endurance") / 2)
        local add = att + char:GetSurvival()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})


-- Charisma --


-- Intelligence --
ix.command.Add("Science", {
    description = "Roll a Science check on a d10 + Intelligence. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Science"
        local att = math.floor(client:GetCharacter():GetAttribute("intelligence") / 2)
        local add = att + char:GetScience()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Medicine", {
    description = "Roll a Medicine check on a d10 + Intelligence. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Medicine"
        local att =math.floor(client:GetCharacter():GetAttribute("intelligence") / 2)
        local add = att + char:GetMedicine()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Repair", {
    description = "Roll a Repair check on a d10 + Intelligence. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Repair"
        local att = math.floor(client:GetCharacter():GetAttribute("intelligence") / 2)
        local add = att + char:GetRepair()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})


-- Agility --
ix.command.Add("Guns", {
    description = "Roll a Guns check on a d10 + Agility. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Guns"
        local att = math.floor(client:GetCharacter():GetAttribute("agility") / 2)
        local add = att + char:GetGuns()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Evasion", {
    description = "Roll an Evasion check on a d10 + Agility. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(0, 10)
        local attr = "Evasion"
        local att = math.floor(client:GetCharacter():GetAttribute("agility") / 2)
        local add = att + char:GetEvasion()
        local modifier = modifier or 0
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})




-- Luck --







ix.command.Add("Rollstatmodifier", {
    description = "Roll a number out of the given maximum and add the given amount to it.",
    arguments = {ix.type.number, bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier, maximum)
        maximum = math.Clamp(maximum or 100, 0, 1000000)

        local value = math.random(0, maximum)
        local modifier = modifier or 0
        local total = value + modifier
     
        
        ix.chat.Send(client, "rollStatModifier", tostring(value), nil, nil, {
            val = value,
            mod = modifier,
            max = maximum,
            tot = total
            
        })

       ix.log.Add(client, "rollStatModifier", value, total, modifier, maximum)
    end
})

ix.chat.Register("rollStatModifier", {
    format = "** %s rolled %s + %s = %s out of %s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local max = data.max or 100
        local mod = data.mod or 0
        local val = data.val
        local tot = data.tot
     
        --local total = add + data.initialroll
        local translated = L2(self.uniqueID.."Format", speaker:Name(), text, max)

        chat.AddText(self.color, translated and "** "..translated or string.format(self.format,speaker:Name(), val, mod, tot, max))
    end
})



