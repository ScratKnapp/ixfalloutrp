local PLUGIN = PLUGIN

ENT.Type = "nextbot"
ENT.Base = "ix_combat_base"
ENT.PrintName = "Marked Scout"
ENT.Category = "Helix - Combat Entities - Marked Men"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.name = "Marked Scout"
ENT.description = "A Marked Hunter, agile and devastating at close range."

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
            weapon = "models/halokiller38/fallout/weapons/smgs/bm_127smg.mdl"
            self.name = self.name .. " K-BAR"
            self.description = self.description .. "\nThis one wears the worn remains of an NCR uniform."
        end

        if chosenfaction == "brotherhood" then
            weapon = " " -- Need to composite bonemerge on tribeam
            self.name = self.name .. " SWORD"
            self.description = self.description .. "\nThis one wears a dented up set of Brotherhood Recon Armor."
        end

        if chosenfaction == "legion" then
            weapon = "models/halokiller38/fallout/weapons/shotguns/bm_riotshotgun.mdl"
            self.name = self.name .. " GLADIUS"
            self.description = self.description .. "\nThis one wears the damaged vestments of a Legionary."
        end
        


        self:SetCEntName(self.name)
        self:SetCEntWeaponModel(weapon)
        self:SetDescription(self.description)
        self:SetCombatHealthMax(90)
        self:SetCombatHealth(90)
        self:SetAP(11)
        self:SetDT(8)
        self:SetET(5)
        self:SetDR(5)
        self:SetAttackBoost(10)
        self:SetDodgeBoost(15)

   
    end
end