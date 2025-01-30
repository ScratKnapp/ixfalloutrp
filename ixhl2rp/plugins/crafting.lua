local PLUGIN = PLUGIN -- Ensure PLUGIN is properly referenced

PLUGIN.name = "Crafting System"
PLUGIN.author = "YourName"
PLUGIN.description = "A crafting system with blueprint assignments and stackable items."

PLUGIN.craftingBlueprints = PLUGIN.craftingBlueprints or {}

if SERVER then
    util.AddNetworkString("ixCraftingBlueprints")
    util.AddNetworkString("ixAssignCraftingBlueprint")
    util.AddNetworkString("ixCraftItem")
    util.AddNetworkString("ixSendBlueprints")
    util.AddNetworkString("ixOpenCraftWindow")

    local timezoneOffset = -6 -- CST timezone offset (Dallas)

    -- Save blueprints persistently
    function PLUGIN:SaveData()
        self:SetData(self.craftingBlueprints)
    end

    function PLUGIN:LoadData()
        self.craftingBlueprints = self:GetData() or {}
    end

    -- Command for admins to open crafting blueprint editor
    ix.command.Add("CraftingBlueprints", {
        adminOnly = true,
        description = "Open the crafting blueprints editor.",
        OnRun = function(self, client)
            net.Start("ixCraftingBlueprints")
            net.Send(client)
        end
    })

    -- Assign crafting blueprint to an item
    net.Receive("ixAssignCraftingBlueprint", function(len, client)
        local itemID = net.ReadString()
        local materials = net.ReadTable()

        local timestamp = os.date("!%Y-%m-%d %H:%M:%S", os.time() + (timezoneOffset * 3600))
        PLUGIN.craftingBlueprints[itemID] = {materials = materials, assignedAt = timestamp}
        client:Notify("Crafting blueprint for " .. ix.item.list[itemID].name .. " has been assigned.")

        -- Send updated blueprints to players
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetCharacter() then
                net.Start("ixSendBlueprints")
                net.WriteTable(PLUGIN.craftingBlueprints)
                net.Send(ply)
            end
        end
    end)

    -- Craft an item
    net.Receive("ixCraftItem", function(len, client)
        local itemID = net.ReadString()

        if not PLUGIN.craftingBlueprints[itemID] then
            client:Notify("This item has no blueprint.")
            return
        end

        local blueprint = PLUGIN.craftingBlueprints[itemID].materials
        local inventory = client:GetCharacter():GetInventory()
        local hasMaterials = true

        -- Check if player has enough materials
        for materialID, amount in pairs(blueprint) do
            local itemStacks = inventory:GetItemsByID(materialID)

            local totalAmount = 0
            for _, item in pairs(itemStacks) do
                totalAmount = totalAmount + (item:GetData("stack", 1))
            end

            if totalAmount < amount then
                hasMaterials = false
                break
            end
        end

        if hasMaterials then
            -- Deduct materials
            for materialID, amount in pairs(blueprint) do
                local itemStacks = inventory:GetItemsByID(materialID)

                for _, item in pairs(itemStacks) do
                    local stackSize = item:GetData("stack", 1)

                    if amount <= stackSize then
                        item:SetData("stack", stackSize - amount)

                        -- Remove the item if stack is empty
                        if item:GetData("stack", 0) <= 0 then
                            inventory:Remove(item)
                        end
                        break
                    else
                        amount = amount - stackSize
                        inventory:Remove(item)
                    end
                end
            end

            -- Add crafted item to inventory
            inventory:Add(itemID)
            client:Notify("You have crafted: " .. ix.item.list[itemID].name)
        else
            client:Notify("You don't have enough materials.")
        end
    end)

    -- Open crafting confirmation window
    net.Receive("ixOpenCraftWindow", function(len, client)
        local itemID = net.ReadString()
        local blueprint = PLUGIN.craftingBlueprints[itemID]
        if blueprint then
            net.Start("ixOpenCraftWindow")
            net.WriteString(itemID)
            net.WriteTable(blueprint.materials)
            net.Send(client)
        else
            client:Notify("This item does not have a blueprint.")
        end
    end)
else
    -- Receive blueprints from server
    net.Receive("ixSendBlueprints", function()
        PLUGIN.craftingBlueprints = net.ReadTable()
    end)

    -- Open the admin crafting blueprint editor
    net.Receive("ixCraftingBlueprints", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Crafting Blueprints")
        frame:SetSize(800, 600)
        frame:Center()
        frame:MakePopup()

        local searchBar = vgui.Create("DTextEntry", frame)
        searchBar:Dock(TOP)
        searchBar:SetPlaceholderText("Search items...")

        local itemList = vgui.Create("DScrollPanel", frame)
        itemList:Dock(FILL)

        local function populateList(filter)
            itemList:Clear()

            for itemID, item in pairs(ix.item.list) do
                if item.category == "weapon" or item.category == "Armor" then
                    if not filter or item.name:lower():find(filter) then
                        local itemPanel = vgui.Create("DPanel", itemList)
                        itemPanel:Dock(TOP)
                        itemPanel:SetTall(70)
                        itemPanel:DockMargin(5, 5, 5, 0)

                        local icon = vgui.Create("DImage", itemPanel)
                        icon:SetSize(48, 48)
                        icon:SetPos(5, 5)
                        icon:SetImage(item.category == "weapon" and "path/to/weapon_icon.png" or "models/ordoredactus/props/40k_christmas/prop_crate_gift_3.mdl")

                        local blueprintData = PLUGIN.craftingBlueprints[itemID]
                        local blueprintStatus = blueprintData and "| Blueprint Assigned" or "| Blueprint Unassigned"
                        local timestamp = blueprintData and " | Assigned At: " .. blueprintData.assignedAt or ""

                        local nameLabel = vgui.Create("DLabel", itemPanel)
                        nameLabel:SetText(item.name .. " " .. blueprintStatus .. timestamp)
                        nameLabel:Dock(TOP)
                        nameLabel:DockMargin(60, 0, 0, 0)
                        nameLabel:SetFont("DermaDefaultBold")

                        local assignButton = vgui.Create("DButton", itemPanel)
                        assignButton:SetText(blueprintData and "Change Blueprint" or "Assign Blueprint")
                        assignButton:SetWide(100)
                        assignButton:SetPos(600, 40) -- Adjusted position
                        assignButton.DoClick = function()
                            openAssignMaterialsWindow(itemID, item)
                        end
                    end
                end
            end
        end

        searchBar.OnChange = function()
            populateList(searchBar:GetValue():lower())
        end

        populateList()
    end)

    -- Crafting Confirmation Window
    net.Receive("ixOpenCraftWindow", function()
        local itemID = net.ReadString()
        local recipe = net.ReadTable()

        local frame = vgui.Create("DFrame")
        frame:SetTitle("Craft Item: " .. ix.item.list[itemID].name)
        frame:SetSize(400, 600)
        frame:Center()
        frame:MakePopup()

        local icon = vgui.Create("DImage", frame)
        icon:SetSize(64, 64)
        icon:SetPos(frame:GetWide() / 2 - 32, 40)
        icon:SetImage("path/to/item/icon.png") -- Adjust to proper path

        local recipeList = vgui.Create("DScrollPanel", frame)
        recipeList:SetPos(20, 120)
        recipeList:SetSize(frame:GetWide() - 40, frame:GetTall() - 200)

        for materialID, amount in pairs(recipe) do
            local label = vgui.Create("DLabel", recipeList)
            label:SetText(ix.item.list[materialID].name .. " x" .. amount)
            label:Dock(TOP)
            label:DockMargin(5, 5, 5, 0)
        end

        local craftButton = vgui.Create("DButton", frame)
        craftButton:SetText("Craft Item")
        craftButton:SetSize(120, 30)
        craftButton:SetPos(frame:GetWide() / 2 - 60, frame:GetTall() - 50)
        craftButton.DoClick = function()
            net.Start("ixCraftItem")
            net.WriteString(itemID)
            net.SendToServer()

            frame:Close()
        end
    end)
end
