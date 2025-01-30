local PLUGIN = PLUGIN
PLUGIN.name = "Stat Rolling"
PLUGIN.author = "Val"
PLUGIN.description = "cheese.wav"

ix.dice = ix.dice or {}

----= Attributes =----


-- Chat type for rolls
ix.chat.Register("rollstat", {
    format = "** %s rolled for %s: %s Roll + %s Stat Boost %s = %s %s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local att = data.attr or "STR"
        local add = data.additive
        local mod = data.mod
        local total = data.initialroll + add + mod
        local crit = data.crit or false

        if mod ~= 0 then
            mod = "with a Modifier of " .. mod .. " "
        else
            mod = ""
        end

        if crit then
            crit = " !CRITICAL HIT!"
        else 
            crit = ""
        end 
        local translated = L2(self.uniqueID.."Format", speaker:Name(), text)

        chat.AddText(self.color, translated and "** "..translated or string.format(self.format,speaker:Name(), att, text, add, mod, total, crit))
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
        description = "Roll a " .. v.name .. " check on a d20 + Attribute. Optional modifier.",
        arguments = {bit.bor(ix.type.number, ix.type.optional)},
        OnRun = function(self, client, modifier)
            local value = math.random(1, 20)
            local attr = v.name
            local att = client:GetCharacter():GetAttribute(string.lower(v.name))

            local add = att 
            local char = client:GetCharacter()
            local modifier = modifier or 0

             -- If rolled number between 0-100 is less than crit chance, it is a critical hit
            local critical
            local critchance = char:GetCharcritchance() or 0
            local iscrit = math.random(1, 100)
            if critchance >= iscrit then critical = true else critical = false end
                
            ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
                attr = attr,
                additive=add,
                initialroll = value,
                mod = modifier,
                crit = critical
    
            })
    
           ix.log.Add(client, "rollStat", value, attr, add, modifier)
        end
    })
end 


-- math.floor(client:GetCharacter():GetAttribute("endurance") / 2)
----= Skills =----

-- Strength --
ix.command.Add("Unarmed", {
    description = "Roll an Unarmed check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Unarmed"
        local att =  0
        local add = att + math.floor(client:GetCharacter():GetSkill("unarmed") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end


        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Melee", {
    description = "Roll a Melee Weapons check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Melee Weapons"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("meleeweapons") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

-- Perception --
ix.command.Add("Energy", {
    description = "Roll an Energy Weapons check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Energy Weapons"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("energyweapons") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Explosives", {
    description = "Roll an Explosives check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Explosives"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("explosives") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Lockpick", {
    description = "Roll a Lockpick check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Lockpicking"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("lockpicking") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})


-- Endurance --
ix.command.Add("Survival", {
    description = "Roll a Survival check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Survival"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("survival") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end    
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})


-- Charisma --

ix.command.Add("Speech", {
    description = "Roll a Speech check on a d20. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Speech"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("speech") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end   
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Barter", {
    description = "Roll a Barter check on a d20. Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Barter"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("barter") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end   
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

-- Intelligence --
ix.command.Add("Science", {
    description = "Roll a Science check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Science"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("science") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end   
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Medicine", {
    description = "Roll a Medicine check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Medicine"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("medicine") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end   
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Repair", {
    description = "Roll a Repair check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Repair"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("repair") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end   
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})


-- Agility --
ix.command.Add("Guns", {
    description = "Roll a Guns check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Guns"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("guns") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
        })

       ix.log.Add(client, "rollStat", value, attr, add, modifier)
    end
})

ix.command.Add("Evasion", {
    description = "Roll an Evasion check on a d20 . Optional modifier.",
    arguments = {bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier)
        local char = client:GetCharacter()
        local value = math.random(1, 20)
        local attr = "Evasion"
        local att = 0
        local add = att + math.floor(client:GetCharacter():GetSkill("evasion") / 2)
        local modifier = modifier or 0

        -- If rolled number between 0-100 is less than crit chance, it is a critical hit
        local critical
        local critchance = char:GetCharcritchance() or 0
        local iscrit = math.random(1, 100)
        if critchance >= iscrit then critical = true else critical = false end   
        
        ix.chat.Send(client, "rollStat", tostring(value), nil, nil, {
            attr = attr,
            additive=add,
            initialroll = value,
            mod = modifier,
            crit = critical
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

ix.command.Add("combatdice", {
    description = "Roll combat dice.",
    arguments = {ix.type.number},
    OnRun = function(self, client, amount)
        
       local result = ix.dice:combatDice(amount)

       return result.string
    end
})


