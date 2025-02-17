local PLUGIN = PLUGIN -- Ensure PLUGIN is properly referenced

PLUGIN.name = "Initiative System"
PLUGIN.author = "Sherrogi"
PLUGIN.description = "Adds a turn-based initiative system to Helix."

PLUGIN.turnOrder = {}
PLUGIN.currentTurnIndex = 1
PLUGIN.initiativeActive = false
PLUGIN.playerStartPos = {}
PLUGIN.playerVisibility = {} -- Tracks if players have toggled initiative on for themselves

if SERVER then
    util.AddNetworkString("UpdateTurnOrderHUD")
    util.AddNetworkString("UpdateRangeFinder")
    util.AddNetworkString("PlayTurnSound")
    util.AddNetworkString("UpdatePlayerMovement")
    util.AddNetworkString("SetInitiativeVisible")
end

-- Helper function to sort turn order
local function sortTurnOrder()
    table.sort(PLUGIN.turnOrder, function(a, b)
        return a.roll > b.roll
    end)
end

local function updateTurnOrderHUD()
    if SERVER then
        for _, client in ipairs(player.GetAll()) do
            if PLUGIN.playerVisibility[client] then
                net.Start("UpdateTurnOrderHUD")
                net.WriteBool(PLUGIN.initiativeActive)
                net.WriteTable(PLUGIN.turnOrder)
                net.WriteUInt(PLUGIN.currentTurnIndex, 8)
                net.Send(client)
            end
        end
    end
end

-- Notify turn for both players and entities
local function notifyTurn()
    if SERVER and PLUGIN.initiativeActive and #PLUGIN.turnOrder > 0 then
        local currentEntry = PLUGIN.turnOrder[PLUGIN.currentTurnIndex]
        local nextPlayerIndex = (PLUGIN.currentTurnIndex % #PLUGIN.turnOrder) + 1
        local nextEntry = PLUGIN.turnOrder[nextPlayerIndex]

        if currentEntry then
            if currentEntry.player then
                PLUGIN.playerStartPos[currentEntry.player] = currentEntry.player:GetPos()
                net.Start("PlayTurnSound")
                net.WriteString("ork/ork_alert3.mp3")
                net.Send(currentEntry.player)
                currentEntry.player:ChatPrint("It is your turn!")
            elseif currentEntry.combatEntity then
                currentEntry.combatEntity:SetNetVar("isTurn", true)
                currentEntry.combatEntity:Fire("TurnStart", "", 0)
            end
        end

        if nextEntry then
            if nextEntry.player then
                net.Start("PlayTurnSound")
                net.WriteString("ork/ork_idle1.mp3")
                net.Send(nextEntry.player)
                nextEntry.player:ChatPrint("Your turn is next!")
            elseif nextEntry.combatEntity then
                nextEntry.combatEntity:SetNetVar("isNextTurn", true)
            end
        end
    end
end

-- Command for superadmins to turn on the initiative system for everyone
ix.command.Add("initiativeon", {
    description = "Turns on the initiative system for everyone on the server (superadmin only).",
    superAdminOnly = true,
    OnRun = function(self, client)
        if PLUGIN.initiativeActive then
            return "Initiative system is already active."
        end

        PLUGIN.initiativeActive = true
        PLUGIN.turnOrder = {}
        PLUGIN.currentTurnIndex = 1

        for _, ply in ipairs(player.GetAll()) do
            PLUGIN.playerVisibility[ply] = true
        end
        
        updateTurnOrderHUD()

        return "Initiative system activated for everyone on the server."
    end
})

-- Command to toggle initiative visibility for individual players
ix.command.Add("toggleinitiative", {
    description = "Join or leave the initiative system (players only).",
    OnRun = function(self, client)
        if not PLUGIN.initiativeActive then
            return "Initiative is not active."
        end
        
        PLUGIN.playerVisibility[client] = not PLUGIN.playerVisibility[client]
        
        if PLUGIN.playerVisibility[client] then
            updateTurnOrderHUD()
            return "You have joined the initiative."
        else
            return "You have left the initiative."
        end
    end
})

ix.command.Add("centslay", {
    description = "Kills the combat entity you are looking at and removes it from the turn order.",
    adminOnly = true,
    OnRun = function(self, client)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity.combatEntity then
            -- Create damage info for the ragdoll
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(100) -- Arbitrary high damage to ensure the entity dies
            dmgInfo:SetDamageType(DMG_GENERIC)
            dmgInfo:SetAttacker(client)
            dmgInfo:SetInflictor(client)

            -- Turn the entity into a ragdoll
            entity:TakeDamageInfo(dmgInfo)
            entity:BecomeRagdoll(dmgInfo)

            -- Remove the entity from the turn order
            for i, entry in ipairs(PLUGIN.turnOrder) do
                if entry.combatEntity == entity then
                    table.remove(PLUGIN.turnOrder, i)
                    updateTurnOrderHUD()
                    break
                end
            end

            -- Notify the client
            client:Notify(entity:GetNetVar("name", "The entity") .. " has been slain.")
        else
            client:Notify("You must be looking at a combat entity.")
        end
    end
})

-- Command to roll initiative
ix.command.Add("initiative", {
    description = "Rolls initiative for the player.",
    OnRun = function(self, client)
        if not PLUGIN.initiativeActive then
            return "Initiative is not active."
        end

        local character = client:GetCharacter()
        local roll = math.random(1, 10) + character:GetAttribute("wits", 0) + character:GetAttribute("dexterity", 0)

        table.insert(PLUGIN.turnOrder, { name = character:GetName(), roll = roll, player = client })
        sortTurnOrder()
        updateTurnOrderHUD()
        return string.format("%s rolled %d for initiative.", character:GetName(), roll)
    end
})

-- Command to pass a turn
ix.command.Add("pass", {
    description = "Pass your turn.",
    OnRun = function(self, client)
        if not PLUGIN.initiativeActive then return "Initiative is not active." end
        if PLUGIN.turnOrder[PLUGIN.currentTurnIndex].player ~= client then
            return "It is not your turn."
        end

        PLUGIN.currentTurnIndex = (PLUGIN.currentTurnIndex % #PLUGIN.turnOrder) + 1
        PLUGIN.playerStartPos[client] = nil
        updateTurnOrderHUD()
        notifyTurn()
        return "You have passed your turn."
    end
})

-- Command to forcefully pass a turn
ix.command.Add("forcepass", {
    description = "Forces the turn order to pass to the next player or entity.",
    adminOnly = true,
    OnRun = function(self, client)
        if #PLUGIN.turnOrder == 0 then
            return "No one is in the turn order."
        end

        local currentEntry = PLUGIN.turnOrder[PLUGIN.currentTurnIndex]
        if currentEntry.player then
            PLUGIN.playerStartPos[currentEntry.player] = nil
        elseif currentEntry.combatEntity then
            currentEntry.combatEntity:SetNetVar("isTurn", false)
        end

        PLUGIN.currentTurnIndex = (PLUGIN.currentTurnIndex % #PLUGIN.turnOrder) + 1
        updateTurnOrderHUD()
        notifyTurn()
        return "Turn passed to the next player or entity."
    end
})

-- Command to remove a player from the initiative order
ix.command.Add("removeinitiative", {
    description = "Removes a player from the initiative order.",
    adminOnly = true,
    arguments = ix.type.text,
    OnRun = function(self, client, targetName)
        for i, entry in ipairs(PLUGIN.turnOrder) do
            if entry.name == targetName then
                table.remove(PLUGIN.turnOrder, i)
                updateTurnOrderHUD()
                return targetName .. " has been removed from the turn order."
            end
        end

        return "Player not found in the turn order."
    end
})


-- Command for CENT initiative
ix.command.Add("centinitiative", {
    description = "Rolls initiative for the combat entity you are looking at.",
    adminOnly = true,
    OnRun = function(self, client)
        local entity = client:GetEyeTrace().Entity

        if not IsValid(entity) or not entity.combatEntity then
            client:Notify("You must be looking at a combat entity.")
            return
        end

        if not PLUGIN.initiativeActive then
            return "Initiative is not active."
        end

        for _, entry in ipairs(PLUGIN.turnOrder) do
            if entry.combatEntity == entity then
                return "This entity is already in the turn order."
            end
        end

        local roll = math.random(1, 10)
        table.insert(PLUGIN.turnOrder, {
            name = entity:GetNetVar("name", entity.PrintName or "CENT"),
            roll = roll,
            entity = entity
        })

        sortTurnOrder()
        updateTurnOrderHUD()

        return string.format("%s rolled %d for initiative.", entity:GetNetVar("name", entity.PrintName or "CENT"), roll)
    end
})

ix.command.Add("initiativeoff", {
    description = "Turns off the initiative system (admin only).",
    adminOnly = true,
    OnRun = function(self, client)
        PLUGIN.initiativeActive = false
        PLUGIN.turnOrder = {}
        PLUGIN.currentTurnIndex = 1
        updateTurnOrderHUD()
        return "Initiative system deactivated."
    end
})

-- Command to find the range to a player or entity (CENT) by name
ix.command.Add("findrange", {
    description = "Find the range to a player or CENT in the turn order.",
    arguments = ix.type.text,
    OnRun = function(self, client, targetName)
        local target = nil

        for _, entry in ipairs(PLUGIN.turnOrder) do
            if entry.name == targetName then
                target = entry.player or entry.combatEntity
                break
            end
        end

        if not target then
            return "Player or CENT not found in the turn order."
        end

        local distanceUnits = client:GetPos():Distance(target:GetPos())
        local distanceMeters = math.Round(distanceUnits / 50, 2)

        net.Start("UpdateRangeFinder")
        net.WriteString(targetName)
        net.WriteFloat(distanceMeters)
        net.Send(client)

        return string.format("The distance to %s is %.2f meters.", targetName, distanceMeters)
    end
})

ix.command.Add("rangeclear", {
    description = "Clears the rangefinder target and distance.",
    OnRun = function(self, client)
        net.Start("UpdateRangeFinder")
        net.WriteString("")
        net.WriteFloat(0)
        net.Send(client)

        return "Rangefinder target cleared."
    end
})

ix.command.Add("centattack", {
    description = "Makes the CENT entity you are looking at attack the specified target.",
    adminOnly = true,
    arguments = ix.type.text,
    OnRun = function(self, client, targetName)
        -- Get the entity the user is looking at
        local cent = client:GetEyeTrace().Entity

        if not IsValid(cent) or not cent.combatEntity then
            client:Notify("You must be looking at a valid combat-enabled CENT entity.")
            return
        end

        -- Find the target by name in the turn order
        local target = nil
        for _, entry in ipairs(PLUGIN.turnOrder) do
            if entry.name == targetName then
                target = entry.player or entry.combatEntity
                break
            end
        end

        if not target then
            client:Notify("Target not found in the turn order.")
            return
        end

        -- Make the CENT perform the attack
        if cent.PrimaryAttack then
            cent:PrimaryAttack() -- Trigger the primary attack for the CENT
        else
            client:Notify("This CENT does not have a valid attack function.")
            return
        end

        -- Broadcast the message within 1500 units
        local message = string.format("<color=red>%s</color> attacks <color=red>%s</color>", 
            cent:GetNetVar("name", "CENT"), 
            targetName)

        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(cent:GetPos()) <= 1500 then
                ply:ChatPrint(message)
            end
        end

        return string.format("%s has attacked %s.", cent:GetNetVar("name", "CENT"), targetName)
    end
})

ix.command.Add("findrangecent", {
    description = "Find the range to a CENT entity in the turn order.",
    arguments = ix.type.text,
    OnRun = function(self, client, targetName)
        local target = nil

        for _, entry in ipairs(PLUGIN.turnOrder) do
            if entry.combatEntity and entry.name == targetName then
                target = entry.combatEntity
                break
            end
        end

        if not target then
            return "CENT entity not found in the turn order."
        end

        local distanceUnits = client:GetPos():Distance(target:GetPos())
        local distanceMeters = math.Round(distanceUnits / 50, 2)

        net.Start("UpdateRangeFinder")
        net.WriteString(targetName)
        net.WriteFloat(distanceMeters)
        net.Send(client)

        return string.format("The distance to %s is %.2f meters.", targetName, distanceMeters)
    end
})

-- Client-side HUD rendering
if CLIENT then
    surface.CreateFont("VecnaTurnOrder", { font = "Vecna", size = 32, weight = 800 })
    local turnOrder, initiativeActive, currentTurnIndex = {}, false, 1
    local rangeTarget, rangeDistance = "", 0
    local startPos, movedDistance = nil, 0

    -- Receive the turn order HUD update
    net.Receive("UpdateTurnOrderHUD", function()
        initiativeActive = net.ReadBool()
        turnOrder = net.ReadTable()
        currentTurnIndex = net.ReadUInt(8)
    end)

    -- Receive the range finder update
    net.Receive("UpdateRangeFinder", function()
        rangeTarget = net.ReadString()
        rangeDistance = net.ReadFloat()
    end)

    -- Receive the sound for a player's turn
    net.Receive("PlayTurnSound", function()
        local soundPath = net.ReadString()
        surface.PlaySound(soundPath)
    end)

    -- Track the player's movement and update moved distance
    hook.Add("Think", "TrackPlayerMovement", function()
        if initiativeActive and turnOrder[currentTurnIndex] and turnOrder[currentTurnIndex].player == LocalPlayer() then
            if not startPos then
                startPos = LocalPlayer():GetPos()
            end
            movedDistance = math.Round(startPos:Distance(LocalPlayer():GetPos()) / 50, 2)
        else
            startPos, movedDistance = nil, 0
        end
    end)

    -- Draw the turn order and range finder on the HUD
    hook.Add("HUDPaint", "DrawTurnOrderHUD", function()
        if not initiativeActive then return end

        local x, y = 50, 50
        draw.SimpleText("Turn Order", "VecnaTurnOrder", x, y, color_white, TEXT_ALIGN_LEFT)
        y = y + 40

        for i, entry in ipairs(turnOrder) do
    local color = color_white

    if i == currentTurnIndex then
        --if entry.player == LocalPlayer() then
          --  color = Color(0, 255, 0) -- Green for players when it's their turn
           -- draw.SimpleText("It is your turn!", "VecnaTurnOrder", ScrW() / 2, 50, color, TEXT_ALIGN_CENTER)
        if entry.combatEntity then
            color = Color(255, 0, 0) -- Red for CENTs when it's their turn
            draw.SimpleText(entry:GetName() .. " turn", "VecnaTurnOrder", ScrW() / 2, 50, color, TEXT_ALIGN_CENTER)
        end
    elseif i == (currentTurnIndex % #turnOrder) + 1 then
        if entry.player == LocalPlayer() then
            color = Color(255, 255, 0) -- Yellow for players when they are next
            draw.SimpleText("Your turn is next!", "VecnaTurnOrder", ScrW() / 2, 80, color, TEXT_ALIGN_CENTER)
        elseif entry.combatEntity then
            color = Color(255, 165, 0) -- Orange for CENTs when they are next
            draw.SimpleText("CENT is next!", "VecnaTurnOrder", ScrW() / 2, 80, color, TEXT_ALIGN_CENTER)
        end
    end

    draw.SimpleText(string.format("%d. %s (%d)", i, entry.name, entry.roll), "VecnaTurnOrder", x, y, color, TEXT_ALIGN_LEFT)
    y = y + 30
end

        local rangeX, rangeY = ScrW() - 350, 50
        draw.SimpleText("Range Finder", "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
        rangeY = rangeY + 40

        if rangeTarget ~= "" then
            draw.SimpleText(string.format("Target: %s", rangeTarget), "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
            rangeY = rangeY + 30
            draw.SimpleText(string.format("Distance: %.2f meters", rangeDistance), "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
            rangeY = rangeY + 30
        else
            draw.SimpleText("No target", "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
            rangeY = rangeY + 30
        end

        draw.SimpleText(string.format("You've moved: %.2f meters", movedDistance), "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
    end)
end

