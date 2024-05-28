PLUGIN.name = 'Movement'
PLUGIN.author = 'Scrat Knapp'
PLUGIN.description = 'Adds a command to help players tell how much theyve moved for their turn.'


ix.command.Add( "Movement", {
    description = "Begin or Finish counting movement.",
    OnRun = function( self, client )
        char = client:GetCharacter()
        if char:GetVar("isMoving") then
            local startPos = char:GetVar("isMoving")
            local endPos = client:GetPos()
            local distance = endPos:Distance(startPos)

            distance =  distance - (distance % 1)
            distance = (distance / 39.3701) 
            distance =  distance - (distance % 1)

            local apcost = math.ceil(distance / 10)

            client:Notify("You've moved " .. distance .. " Meters.")
            client:Notify("AP Cost: " .. apcost )
            char:SetVar("isMoving", nil)
            ix.log.Add(client, "moveEnd", distance, apcost)


        else 
            client:Notify("You're moving. Use again to calculate distance travelled.")
            local startPos = client:GetPos()
            char:SetVar("isMoving", startPos)
            ix.log.Add(client, "moveStart", client)
        end 
    end
} )

ix.command.Add( "rangefinder", {
    description = "Get range of the place you're looking. ",
    OnRun = function( self, client )
        local char = client:GetCharacter()
    
        local startPos = client:GetPos()
        local endPos = client:GetEyeTrace().HitPos
        local target = client:GetEyeTrace().Entity
        local distance = endPos:Distance(startPos)

        distance =  distance - (distance % 1)
        distance = (distance / 39.3701) 
        distance =  distance - (distance % 1)

        local apcost = math.ceil(distance / 10)

        local str = ""

        if IsValid(target) and target.combatEntity then 
            str = "Target: " .. target:Name() .. "\n"
        end 

        str = str .. "Distance to point: " .. distance .. "m"
        local range
        
        if distance < 15 then range = "Short"
        elseif distance > 15 and distance < 44 then range = "Medium"
        elseif distance > 44 and distance < 74 then range = "Long"
        elseif distance > 74 and distance < 125 then range = "Very Long"
        elseif distance > 125 then range = "Extreme"
        end 

        str = str .. "\nRange: " .. range
        str = str .. "\nMovement Cost: " .. apcost

        

        return str




          

    end
} )

if (SERVER) then
    ix.log.AddType("moveStart", function(client)
        return string.format("%s has begun moving.", client:Name())
    end)

    ix.log.AddType("moveEnd", function(client, distance, apcost)
        return string.format("%s has finished moving. Distance: %sm. AP Cost: %s.", client:Name(), distance, apcost)
    end)
end