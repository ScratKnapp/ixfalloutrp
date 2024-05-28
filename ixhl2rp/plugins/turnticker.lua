PLUGIN.name = "Turn Ticker"
PLUGIN.description = "A very haphazard turn system for counting down drug effects."
PLUGIN.author = "Scrat Knapp"






ix.command.Add("Turn", {
    description = "Tick down any turn timers on you by 1.",
    OnRun = function(self, client)
        local turntable = client:GetCharacter():GetData("timertable")
        if next(turntable) == nil then
          client:Notify("You have no current turn timers.")
        end
        
        for i, v in pairs(turntable) do
            timer.Toggle(v)
            local currenttime = timer.TimeLeft(v)
            timer.Adjust(v, currenttime - 1 )
            local newtime = timer.TimeLeft(v)

            if newtime >= 1 then
              timer.Toggle(v)
              client:Notify(v..  " now has " ..math.floor(newtime) .. " turns of effect left.")
              ix.log.Add(client, "drugTick", v, client:GetCharacter(), math.floor(newtime))

            else
              client:Notify(v .. " has expired.")
              turntable[i] = nil
              client:GetCharacter():SetData("timertable", turntable)
              ix.log.Add(client, "drugExpire", v, client)
            end 
        end
    end
})

ix.command.Add("PlayerTurn", {
  description = "Tick a player's turn timers by one.",
  adminOnly = true,
  arguments = {ix.type.character},
  OnRun = function(self, client, target)
    local targetplayer = target:GetPlayer()

    local turntable = target:GetData("timertable")
    if next(turntable) == nil then
      client:Notify(target:GetName() .. " has no current turn timers.")
    end
      
    for i, v in pairs(turntable) do
        timer.Toggle(v)
        local currenttime = timer.TimeLeft(v)
        timer.Adjust(v, currenttime - 1 )
        local newtime = timer.TimeLeft(v)

        if newtime >= 1 then
          timer.Toggle(v)
          client:Notify(target:GetName() .. "'s "..v..  " now has " ..math.floor(newtime) .. " turns of effect left.")
          targetplayer:Notify(v..  " now has " ..math.floor(newtime) .. " turns of effect left.")
          ix.log.Add(client, "drugTick", v, target, math.floor(newtime))

        else
          client:Notify(target:GetName() .. "'s ".. v .. " has expired.")
          targetplayer:Notify(v .. " has expired.")
          turntable[i] = nil
          target:SetData("timertable", turntable)
          ix.log.Add(client, "drugExpire", v, targetplayer)
        end 
    end
  end
})

if (SERVER) then
  ix.log.AddType("drugExpire", function(client, drug)
      return string.format("The %s of %s has expired.", drug, client:Name())
  end)

  ix.log.AddType("drugTick", function(client, drug, target, turns)
    return string.format("The %s of %s has %s turns of effect left.", drug, target:GetName(), turns)
end)


end

