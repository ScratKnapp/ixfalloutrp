
AddCSLuaFile()

ENT.Base             = "base_gmodentity"
ENT.Type             = "anim"
ENT.PrintName        = "Scrap Pile"
ENT.Author            = "Scrat"
ENT.Category         = "Fallout Misc"
ENT.Spawnable = true
ENT.AdminOnly = true


if (SERVER) then
    function ENT:Initialize()
        

        local pileModels = {
            "models/fallout_nv/architecture/megaton_sized/debris/groundlitterpile01.mdl",
            "models/mccarran/garbage/metdebrishall02.mdl",
            "models/mccarran/garbage/metdebrishall01.mdl",
            "models/mccarran/garbage/metdebrisplatform01.mdl",
            "models/mccarran/garbage/metdebrispillar01.mdl",
            "models/props_fallout/rubble02.mdl",
            "models/mccarran/garbage/indrubblepilelg01.mdl",
            "models/mccarran/garbage/indrubblepilelg02.mdl",
            "models/mccarran/garbage/indrubblepilesm01.mdl",
            "models/mccarran/garbage/rubblepile01.mdl",
            "models/mccarran/garbage/rubblepile01.mdl",
            "models/fallout_nv/architecture/suburban/rubblepiles/suburbanrubblepilelg01.mdl",
            "models/fallout_nv/architecture/suburban/rubblepiles/suburbanrubblepilereg03.mdl",
            "models/mccarran/garbage/rubblepile05.mdl",
            "models/props_fallout/rubbleurb03.mdl",
            "models/props_fallout/subrubble2.mdl"
        }

        self:SetModel(table.Random(pileModels))


        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
    end
end



function ENT:Use(activator)
    if (activator:IsPlayer()) then
       local  target = activator:GetCharacter()

       if target:GetStamina() < 1 then activator:NewVegasNotify("You're too tired to scavenge. You need at least 1 Stamina.", "messageSad", 4) return end

        local junktable = {
            "kitscrapboxbasic",
            "emptybottle",
            "ducttape",
            "dishrag",
            "soap",
            "rustedcannister",
            "prewarmoney",
            "coffeecup",
            "blastradius",
            "homemadebattery",
            "leadcan",
            "globe",
            "buttercuptoy",
            "wonderglue",
            "tincan",
            "alarmclock",
            "bowlingball",
            "babyrattle",
            "5lbweight",
            "10lbweight",
            "abraxo",
            "bowl",
            "bowlingball",
            "camera",
            "baseball",
            "clipboard",
            "jangles",
            "nails",
            "kitmodelrobots",
            "rustedcannister",
            "medicalsaw",
            "teddybear",
            "fuse",
            "antifreeze",
            "blowtorch",
            "babybottle",
            "ashtray",
            "ovenmitt",
            "turpentine",
            "fertilizerbag",
            "drainedecp",
            "drainedmfc",
            "biometricscanner",
            "distresspulser",
            "kitmodelrobots",
            "microscope",
            "fusioncore",
            "casingsmallpistol",
            "casingshotgun",
            "casinglargepistol",
            "powderpistol",
            "primershotshell",
            "primersmallpistol",
            "primerlargepistol",
            "leadcan",
            "casinglargerifle",
            "powderrifle",
            "primersmallrifle",
            "primerlargerifle",
        }

        local selecteditem = table.Random(junktable)
        local itemname = ix.item.Get(selecteditem)
        target:GetInventory():Add(selecteditem, 1)
        activator:EmitSound("fosounds/fix/ui_items_generic_up_02.mp3")

        activator:NewVegasNotify("You find a " .. itemname.name .. "!", "messageNeutral", 4)
        target:TakeStamina(1)
    
     
    end 
end

if (CLIENT) then
    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")
    
        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText(self.PrintName)
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()    
    end
end
