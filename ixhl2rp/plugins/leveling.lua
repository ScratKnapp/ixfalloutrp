local PLUGIN = PLUGIN
PLUGIN.name = "Leveling"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "Fallout 2d20 leveling system with skill and perk points."
PLUGIN.levelChart = {
    -- How much you need at each level to advance. So if you're Level 1, you need 100xp to level up
    [1] = 100,
    [2] = 300,
    [3] = 600,
    [4] = 1000,
    [5] = 1500,
    [6] = 2100,
    [7] = 2800,
    [8] = 3600,
    [9] = 4500,
    [10] = 5500,
    [11] = 6600,
    [12] = 7800,
    [13] = 9100,
    [14] = 10500,
    [15] = 12000,
    [16] = 13600,
    [17] = 15300,
    [18] = 17100,
    [19] = 19000,
    [20] = 21000,
}


local charMeta = ix.meta.character

function charMeta:GetLevel()
   return self:GetData("Level", 1)
end

function charMeta:IncreaseLevel(amount)
    return self:SetData("Level", self:GetLevel() + amount)
 end

function charMeta:GetXP()
    return self:GetData("XP", 0)
end

function charMeta:GetXPToNextLevel()
    local level = self:GetLevel()
    local xptonext = PLUGIN.levelChart[level]
    return xptonext
end

function charMeta:GetSkillPoints()
    return self:GetData("SkillPoints", 0)
 end
 
function charMeta:AddSkillPoints(amount)
    return self:SetData("SkillPoints", self:GetSkillPoints() + amount)
end

function charMeta:RemoveSkillPoints(amount)
    return self:SetData("SkillPoints", self:GetSkillPoints() - amount)
end

function charMeta:GetPerkPoints()
    return self:GetData("PerkPoints", 0)
 end
 
function charMeta:AddPerkPoints(amount)
    return self:SetData("PerkPoints", self:GetPerkPoints() + amount)
end

function charMeta:RemovePerkPoints(amount)
    return self:SetData("PerkPoints", self:GetPerkPoints() - amount)
end

function charMeta:CanTakePerk(perk)
    local perk = ix.feats.list[perk]

    if not perk then return false end 

    -- You cannot take a perk if you don't meet the required level, required prerequisite perks, or required SPECIAL level.
    if perk.requiredLevel and self:GetLevel() < perk.requiredLevel then return false end

    if perk.requiredPerk and not self:GetFeats()[perk.requiredPerk] then return false end
 

    if perk.requiredSpecial then
        for k, v in pairs(perk.requiredSpecial) do

            -- Using instead of :GetAttribute because we only want 'true' values before buffs or debuffs to count for perks
            if self:GetAttributes()[k] < v then return false end 

        end 
    end


    return true 

 end
 

function charMeta:AddXP(amount)
    local client = self:GetPlayer()
    local level = self:GetLevel()
    local currentXP = self:GetXP()
    local xpToNext = self:GetXPToNextLevel()
    
   
    self:SetData("XP", currentXP + amount)
    if self:GetXP() >= xpToNext then
        self:IncreaseLevel(1)
        client:NewVegasNotify("You recieve " .. amount .. " XP and reach Level " .. self:GetLevel() .. "!", "messageNeutral", 4)
        self:AddSkillPoints(1)
        self:AddPerkPoints(1)
        return true 
    else
        client:NewVegasNotify("You recieve " .. amount .. " XP.", "messageNeutral", 4)
        return false
    end 

end

ix.command.Add("Progress", {
    description = "Check your current level, skill, and perk points.",
    OnRun = function(self, client)
        local char = client:GetCharacter()
        client:Notify("Level: " .. char:GetLevel())
        client:Notify("Next Level In: " .. char:GetXPToNextLevel() - char:GetXP() .. "XP")
        client:Notify("Lifetime XP: " .. char:GetXP())
        client:Notify("Skill Points: " .. char:GetSkillPoints())
        client:Notify("Perk Points: " .. char:GetPerkPoints())

    end
})

ix.command.Add("CharRewardXP", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
    description = "Give XP to target.",
    OnRun = function(self, client, target, amount)
        if amount < 0 then return "Amount must be a positive number." end
     
        -- If the function returns true, they leveled up. If it returns false, they didn't.
        if target:AddXP(amount) then
            client:Notify(target:GetName() .. " recieves " .. amount .. " XP and reaches Level " .. target:GetLevel() .. "!")
        else
            client:Notify(target:GetName() .. " recieves " .. amount .. " XP.")
        end 
    end
})

ix.command.Add("CharAddSkillPoints", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
    description = "Give skill points to target.",
    OnRun = function(self, client, target, amount)
        if amount < 0 then return "Amount must be a positive number." end
        target:AddSkillPoints(amount)
        return "Gave " .. amount .. " skill points to " .. target:GetName() .. "."
    end
})

ix.command.Add("CharAddPerkPoints", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
    description = "Give perk points to target.",
    OnRun = function(self, client, target, amount)
        if amount < 0 then return "Amount must be a positive number." end
        target:AddPerkPoints(amount)
        return "Gave " .. amount .. " perk points to " .. target:GetName() .. "."
    end
})

ix.command.Add("UpgradeSkill", {
    description = "Spend a Skill Point to upgrade a Skill of your choosing.",
    arguments = {ix.type.string},
    OnRun = function(self, client, skill)
        local char = client:GetCharacter()


        if char:GetSkillPoints() <= 0 then 
            client:Notify("You don't have any skill points to spend.")
            return
        end 

        if not ix.skills.list[skill]  then
           client:Notify("Skill name " .. skill .. "not found")
           return
        end

        if char:GetSkill(skill) >= 6 then 
            client:Notify("You cannot upgrade a skill beyond Rank 6.")
            return
        end 

        char:UpdateSkill(skill, 1)
        char:RemoveSkillPoints(1)
        client:NewVegasNotify(ix.skills.list[skill].name .. " upgraded to Level " .. char:GetSkill(skill), "messageNeutral", 4)


    end
})








if SERVER then
    util.AddNetworkString("AddPerk")
    util.AddNetworkString("SendPerksList")

    function SendPerksToClient(client)
        local perksToSend = {}
        
        for key, perk in pairs(ix.feats.list) do

            if perk.noStartSelection then continue end 

            if not client:GetCharacter():CanTakePerk(key) then continue end 

            if not client:GetCharacter():HasFeat(key) then
                table.insert(perksToSend, { key = key, name = perk.name, description = perk.description, icon = perk.icon })
            end
        end
        
        net.Start("SendPerksList")
        net.WriteTable(perksToSend)
        net.Send(client)
    end
    
    net.Receive("AddPerk", function(len, ply)
        local perkKey = net.ReadString()
        ply:GetCharacter():AddFeat(perkKey)
        ply:GetCharacter():RemovePerkPoints(1)
    end)

    
end 

if CLIENT then

    local perksList = {}

    net.Receive("SendPerksList", function()
        perksList = net.ReadTable()
    end)

    function OpenPerkMenu()
        local PANEL = {}
   

       
        

        function PANEL:Init()

            
         
    
            self:SetSize(800, 600)
            self:Center()
            self:SetTitle("Perk Menu")
            self:MakePopup()



            self.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255)) -- Fully opaque black background
            end 

            local selectedPerk = nil
            
            self.PerksList = self:Add("DScrollPanel")
            self.PerksList:SetSize(200, 560)
            self.PerksList:SetPos(10, 30)

            self.Description = self:Add("DLabel")
            self.Description:SetText("Select a perk for more information...")
            self.Description:SetPos(300, 200) -- Place the description below the picture
            self.Description:SetSize(350, 450) 
            self.Description:SetWrap(true)
            self.Description:SetFont("CustomFontLarge")
            self.Description:SetTextColor(Color(0, 100, 0))

            self.Picture = self:Add("DImage")
            self.Picture:SetPos(400, 100) 
            self.Picture:SetSize(200, 200)
            self.Picture:SetContentAlignment(6)

            self.SubmitButton = self:Add("DButton")
            self.SubmitButton:SetPos(220, 540)
            self.SubmitButton:SetSize(100, 40)
            self.SubmitButton:SetText("Submit")
            self.SubmitButton:SetEnabled(false)
            self.SubmitButton.DoClick = function()
                if selectedPerk then
                
                    surface.PlaySound("fx/ui/menu/ui_menu_ok.wav")
                    net.Start("AddPerk")
                    net.WriteString(selectedPerk)
                    net.SendToServer()
                    self:Close()
                end
            end

            self.CloseButton = self:Add("DButton")
            self.CloseButton:SetPos(330, 540)
            self.CloseButton:SetSize(100, 40)
            self.CloseButton:SetText("Close")
            self.CloseButton.DoClick = function()
                surface.PlaySound("fx/ui/menu/ui_menu_cancel.wav")
                self:Close()
            end

            for _, perk in ipairs(perksList) do
                local perkButton = self.PerksList:Add("DButton")
                perkButton:SetText(perk.name)
                perkButton:SetFont("CustomFontDefault")
                perkButton:SetTall(40)
                perkButton:Dock(TOP)
                perkButton.DoClick = function()
                    surface.PlaySound("fx/ui/menu/ui_menu_prevnext.wav")
                    selectedPerk = perk.key
                     self.Description:SetText(perk.description)
                    self.Picture:SetImage(perk.icon)
                    self.SubmitButton:SetEnabled(true)
                end

                perkButton.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255)) -- Background color
                    surface.SetDrawColor(0, 255, 0, 255) -- Green color
                    surface.DrawOutlinedRect(0, 0, w, h, 2) -- Draw border
                end
            end
        end

        vgui.Register("PerkMenu", PANEL, "DFrame")

        vgui.Create("PerkMenu")
    end

    
end 

ix.command.Add("chooseperk", {
    description = "Opens the perk selection menu.",
    OnRun = function(self, client)

        local perkpoints = client:GetCharacter():GetPerkPoints()
        if perkpoints <= 0 then return "You don't have any Perk Points to spend." end 

        SendPerksToClient(client)
        client:SendLua("OpenPerkMenu()")
    end
})


