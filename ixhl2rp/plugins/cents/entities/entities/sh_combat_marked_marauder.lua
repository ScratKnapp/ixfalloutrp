local PLUGIN = PLUGIN

ENT.Type = "nextbot"
ENT.Base = "ix_combat_base"
ENT.PrintName = "Marked Marauder"
ENT.Category = "Helix - Combat Entities - Marked Men"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.name = "Marked Ravager"
ENT.description = "A Marked Marauder, with improved skill and gear, commonly used as squad leaders."

ENT.models = {
    "models/lazarusroleplay/heads/ghoul_default.mdl",
}
ENT.WalkAnim = "walkalerthold_ar2_all1"
ENT.RunAnim = "run_holding_ar2_all"
ENT.IdleAnim = "idle_relaxed_ar2_"..math.random(1, 9)
ENT.AttackAnim = "shoot_ar2"
ENT.CrouchAnim = "crouch_idled"
ENT.StandAnim = "crouchtostand"

function ENT:OnTakeDamage(dmgInfo)
    return 0
end

local factions = {
    "legion",
    "brotherhood",
    "ncr"
}


if (SERVER) then
    function ENT:CustomInitialize()

        local chosenfaction = table.Random(factions)
        local weapon

        if chosenfaction == "ncr" then
            weapon = " " -- Need to composite bonemerge on the LMG. I hate it here
            self.name = self.name .. " K-BAR"
            self.description = self.description .. "\nThis one wears the worn remains of an NCR uniform."
        end

        if chosenfaction == "brotherhood" then
            weapon = "models/halokiller38/fallout/weapons/energy weapons/bm_laserpdw.mdl" 
            self.name = self.name .. " SWORD"
            self.description = self.description .. "\nThis one wears a dented up set of Brotherhood Combat Armor."
        end

        if chosenfaction == "legion" then
            weapon = "models/halokiller38/fallout/weapons/rifles/bm_brushgun.mdl"
            self.name = self.name .. " GLADIUS"
            self.description = self.description .. "\nThis one wears the damaged vestments of a Legionary."
        end
        


        self:SetCEntName(self.name)
        self:SetCEntWeaponModel(weapon)
        self:SetDescription(self.description)
        self:SetCombatHealthMax(100)
        self:SetCombatHealth(100)
        self:SetAP(10)
        self:SetDT(14)
        self:SetET(8)
        self:SetDR(10)
        self:SetAttackBoost(15)
        self:SetDodgeBoost(15)

   
    end
end