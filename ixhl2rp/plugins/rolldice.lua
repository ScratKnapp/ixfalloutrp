local PLUGIN = PLUGIN
PLUGIN.name = "RollDice"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "General purpose dice rolls of however many dice, with optional modifier."


----= Attributes =----


ix.command.Add("Rolldice", {
    description = "Given amount of dice with given number of sides, and optionally a modifier.",
    arguments = {ix.type.number, ix.type.number, bit.bor(ix.type.number, ix.type.optional), bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, dice, sides, modifier, critchance)
       
        local rollstring = ""
        local roll = 0
        local total = 0
        local isCrit

        if dice > 10 then dice = 10 end

        if not modifier then modifier = 0 end

        if not critchance then 
            isCrit = false
        else 
            if math.random(1, 100) <= critchance then isCrit = true end
        end 

        for i = 1, dice do
			roll = math.random(1, sides)
            total = total + roll

            if i == 1 then
                rollstring = rollstring .. roll
            else
                rollstring = rollstring .. "+" .. roll
            end 
		end        
        
        ix.chat.Send(client, "rollDice", tostring(value), nil, nil, {
            rollstring = rollstring,
            total = total,
            modifier = modifier,
            dice = dice,
            sides = sides,
            isCrit = isCrit

        })
        
        ix.log.Add(client, "rollDice", dice, sides, modifier, total)
    end
})

-- Chat type for rolls
ix.chat.Register("rolldice", {
    format = "** %s rolled for %dd%d: %s%s= %d %s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        
        local dice = data.dice
        local sides = data.sides
        local modifier = data.modifier
        local total = data.total
        local rollstring = data.rollstring
        local crit = data.isCrit

        total = total + modifier

        if modifier ~= 0 then
            modifier = " with a Modifier of " .. modifier .. " "
        else
            modifier = ""
        end

        if crit == true then crit = " !CRITICAL HIT!" else crit = "" end

        local translated = L2(self.uniqueID.."Format", speaker:Name(), text)

        chat.AddText(self.color, translated and "** "..translated or string.format(self.format,speaker:Name(), dice, sides, rollstring, modifier, total, crit))
    end
})

if (SERVER) then
    ix.log.AddType("rollDice", function(client, dice, sides, modifier, total)

        total = total + modifier
        if modifier > 0 then modifier = " with a modifier of " .. modifier else modifier = "" end
        return string.format("%s has rolled %dd%d%s: %d total", client:Name(), dice, sides, modifier, total)
    end)
end