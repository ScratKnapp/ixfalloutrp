local PLUGIN = PLUGIN
PLUGIN.name = "Stat Rolling"
PLUGIN.author = "Val"
PLUGIN.description = "cheese.wav"


ix.chat.Register("combatDice", {
    format = "** %s rolled %s Combat Dice: %s\nTotal: %s\nEffects: %s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280) * 2,
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local translated = L2(self.uniqueID.."Format", speaker:Name(), text)
        chat.AddText(self.color, translated and "** "..translated or string.format(self.format, speaker:Name(), data.numdice, data.rollstring, data.total, data.effects))
    end
})

 if (SERVER) then
    ix.log.AddType("combatDice", function(client, numdice, total, effects)
        return string.format("%s rolled %s Combat Dice. Total: %s Effects: %s", client:GetName(), numdice, total, effects)
    end)
end

ix.chat.Register("locationDice", {
    format = "** %s rolled %s Location Dice: %s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280) * 2,
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local translated = L2(self.uniqueID.."Format", speaker:Name(), text)
        chat.AddText(self.color, translated and "** "..translated or string.format(self.format, speaker:Name(), data.numdice, data.rollstring))
    end
})

 if (SERVER) then
    ix.log.AddType("locationDice", function(client, rollstring, numdice)
        return string.format("%s rolled %s Location Dice: %s", client:GetName(), numdice, rollstring)
    end)
end

ix.chat.Register("rollSkillCheck", {
    format = "** %s rolled a %s %s check, difficulty %s with %sd20: %s\nTarget Number:%s\nSuccesses:%s\nComplications:%s\n%s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280) * 2,
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local translated = L2(self.uniqueID.."Format", speaker:Name(), text)
        chat.AddText(self.color, translated and "** "..translated or string.format(self.format, speaker:Name(), data.skill, data.tagged, data.difficulty, data.numdice, data.rollstring, data.targetnumber, data.success, data.complication, data.passfail))
    end
})

 if (SERVER) then
    ix.log.AddType("skillCheck", function(client, numdice, skill, difficulty, success, complication, passfail)
        return string.format("%s rolled %sd20 %s Check Difficulty %s: %s Successes, %s Complications, %s", client:GetName(), numdice, skill, difficulty, success, complication, passfail)
    end)
end











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
       local result = combatDice(amount)

        
        ix.chat.Send(client, "combatDice", tostring(amount), nil, nil, {
        numdice = amount,
        rollstring = result.string,
        total = result.total,
        effects = result.effects
        })

        ix.log.Add(client, "combatDice", amount, result.total, result.effects)


    end
})

ix.command.Add("locationdice", {
    description = "Roll location dice.",
    arguments = {ix.type.number},
    OnRun = function(self, client, amount)
       local result = locationDice(amount)
       
        ix.chat.Send(client, "locationDice", tostring(amount), nil, nil, {rollstring = result, numdice = amount})
        ix.log.Add(client, "locationDice", result, amount)
    end
})

for k, v in pairs (ix.skills.list) do 
    ix.command.Add(k, {
        description = "Roll a " .. v.name .. " check with a target number based on skill and " .. v.attribute .. " level.",
        arguments = {ix.type.number, bit.bor(ix.type.number, ix.type.optional)},
        OnRun = function(self, client, difficulty, extradice)

            if not extradice then extradice = 0 end 

            if difficulty < 0 then return "Difficulty cannot be negative." end  
            if extradice < -1 then return "Cannot take away both of the default dice." end 

            local char = client:GetCharacter()

            local result = char:RollSkillCheck(k, v.attribute, difficulty, 2 + extradice)
            local targetnumber = char:GetAttribute(v.attribute) + char:GetSkill(k)

            if result.pass == true then
                result.pass = "Success!"
            else
                result.pass = "Failed!"
            end 

            local tagged

            if v.tagged then
                tagged = "[Tagged]"
            else
                tagged = ""
            end 
            

            ix.chat.Send(client, "rollSkillCheck", tostring(difficulty), nil, nil, {
                
                numdice = 2 + extradice, 
               skill = v.name,
               difficulty = difficulty,
               targetnumber = targetnumber,
               success = result.successes,
               complication = result.complications,
               passfail = result.pass,
               rollstring = result.string,
               tagged = tagged

               
            })
    
           ix.log.Add(client, "skillCheck", 2 + extradice, v.name, difficulty, result.successes, result.complications, result.pass)
        end
    })
end 

local charMeta = ix.meta.character

function charMeta:RollSkillCheck(skill, attribute, difficulty, dice)
    local result =
	{
        string = "",
		successes = 0,
		complications = 0,
		pass = false
	}

    local successmodifier = 1
    if ix.skills.list[skill] then successmodifier = 2 end 

    local targetNumber = self:GetAttribute(attribute) + self:GetSkill(skill)


    for i= dice, 1 ,-1 do 
        local roll = math.random(1,20)

        result.string = result.string .. roll .. ", "

        if roll == 20 then
            result.complications = result.complications + 1
            continue
        end

        if roll == 1 then
            result.successes = result.successes + 2
            continue
        end

        -- TODO: Change this when Tagged Skills are added
        if roll <= targetNumber and ix.skills.list[skill].tagged then
            result.successes = result.successes + 2
            continue
        end

        if roll <= targetNumber then
            result.successes = result.successes + 1
            continue
        end
    end

    if result.successes >= difficulty then result.pass = true end 

    return result 


end


function combatDice(amount)

	local result =
	{
		total = 0,
		effects = 0,
		string = ""
	}

	
	
	for i= amount, 1 ,-1 do 
       local roll = math.random(1,6)

		if roll == 1 then 
			result.total = result.total + 1
			result.string = result.string .. "1,"
		elseif roll == 2 then
			result.total = result.total + 2
			result.string = result.string .. "2,"
	   	elseif roll == 3 then
			result.string = result.string .. "0,"
		elseif roll == 4 then
			result.string = result.string .. "0,"
		elseif roll == 5 then
			result.total = result.total + 1
			result.effects = result.effects + 1
			result.string = result.string .. "1+Effect,"
		elseif roll == 6 then
			result.total = result.total + 1
			result.effects = result.effects + 1
			result.string = result.string .. "1+Effect,"
		end 
    end

	return result
	
end

function locationDice(amount)

    local result = ""

	for i=amount, 1 ,-1 do 
       local number = math.random(1,20)

	   	if number >= 1 and number <= 2 then
        	result = result .. "Head,"
    	elseif number >= 3 and number <= 8 then
        	result = result .. "Torso,"
    	elseif number >= 9 and number <= 11 then
        	result = result .. "Left Arm,"
    	elseif number >= 12 and number <= 14 then
        	result = result .. "Right Arm,"
    	elseif number >= 15 and number <= 17 then
			result = result .. "Left Leg,"
    	elseif number >= 18 and number <= 20 then
        	result = result .. "Right Leg,"
    	else
        	return "Error"
    	end
    end

	return result
	
end



