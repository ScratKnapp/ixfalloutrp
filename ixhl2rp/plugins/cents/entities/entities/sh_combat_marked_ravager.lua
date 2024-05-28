local PLUGIN = PLUGIN

ENT.Type = "nextbot"
ENT.Base = "ix_combat_base"
ENT.PrintName = "Marked Ravager"
ENT.Category = "Helix - Combat Entities - Marked Men"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.name = "Marked Ravager"
ENT.description = "A Marked Ravager, a beefy melee unit."

ENT.models = {
    "models/lazarusroleplay/heads/ghoul_default.mdl",
}
ENT.WalkAnim = "luggage_walk_all"
ENT.RunAnim = "run_all"
ENT.IdleAnim = "idle_subtle"
ENT.AttackAnim = "idle_angry_melee"
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
            weapon = "" -- Need to composite bonemerge on sledgehammer
            self.name = self.name .. " K-BAR"
            self.description = self.description .. "\nThis one wears the worn remains of an NCR uniform."
        end

        if chosenfaction == "brotherhood" then
            weapon = " " -- Need to composite bonemerge on dual rippers
            self.name = self.name .. " SWORD"
            self.description = self.description .. "\nThis one wears a dented up set of Brotherhood Recon Armor."
        end

        if chosenfaction == "legion" then
            weapon = "models/halokiller38/fallout/weapons/melee/bm_fireaxe.mdl"
            self.name = self.name .. " GLADIUS"
            self.description = self.description .. "\nThis one wears the damaged vestments of a Legionary."
        end
        


        self:SetCEntName(self.name)
        self:SetCEntWeaponModel(weapon)
        self:SetDescription(self.description)
        self:SetCombatHealthMax(100)
        self:SetCombatHealth(100)
        self:SetAP(10)
        self:SetDT(10)
        self:SetET(6)
        self:SetDR(8)
        self:SetAttackBoost(15)
        self:SetDodgeBoost(10)

   
    end
end