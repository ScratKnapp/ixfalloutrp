
AddCSLuaFile()

ENT.Base             = "base_gmodentity"
ENT.Type             = "anim"
ENT.PrintName        = "Dumpster"
ENT.Author            = "Scrat"
ENT.Category         = "Fallout Misc"
ENT.Spawnable = true
ENT.AdminOnly = true


if (SERVER) then
    function ENT:Initialize()
        self:SetModel("models/llama/dumpster.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetVar("bHarvested", false)
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
