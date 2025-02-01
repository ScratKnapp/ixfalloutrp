PLUGIN.name = 'Initiative'
PLUGIN.author = 'Scrat Knapp'
PLUGIN.description = "Adds stats and commands for manging player health, armor, and AP tabletop style."

if SERVER then
    util.AddNetworkString("AddPerk")
    util.AddNetworkString("SendPerksList")

    function SendPerksToClient(client)
        local perksToSend = {}
        
        for key, perk in pairs(ix.feats.list) do
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
            self.Description:SetPos(220, 200) -- Place the description below the picture
            self.Description:SetSize(970, 400) 
            self.Description:SetWrap(true)
            self.Description:SetFont("CustomFontLarge")
            self.Description:SetTextColor(Color(0, 100, 0))
            self.Description:SetContentAlignment(6)

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
        SendPerksToClient(client)
        client:SendLua("OpenPerkMenu()")
    end
})

