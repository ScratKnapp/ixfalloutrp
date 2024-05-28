local PLUGIN = PLUGIN

ENT.Type = "nextbot"
ENT.Base = "ix_combat_base"
ENT.PrintName = "Brotherhood Senior Paladin"
ENT.Category = "Helix - Combat Entities - Brotherhood of Steel"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.name = "Brotherhood Senior Paladin"
ENT.description = "A Brotherhood Senior Paladin, pretty close to death incarnate."

ENT.models = {
    "models/fallout/player/t51bpowerarmor.mdl"

}
ENT.WalkAnim = "2hraim_walk"
ENT.RunAnim = "2hrrun"
ENT.IdleAnim = "2hrposture"
ENT.AttackAnim = "2hrpostureis"
ENT.CrouchAnim = "sneak2hraim"
ENT.StandAnim = "2hrpostureis"



function ENT:OnTakeDamage(dmgInfo)
    return 0
end

local weapons = {
    "models/fallout/weapons/c_gatlinglaser.mdl",
    "models/fallout/weapons/c_plasmacaster.mdl",
    "models/fallout/weapons/w_supersledge.mdl",
    "models/fallout/weapons/w_missilelauncher.mdl"
}


local names = {
"Smith",
"Marshall",
"Brown",
"Stevenson",
"Wilson",
"Wood",
"Thomson",
"Sutherland",
"Robertson",
"Craig",
"Campbell",
"Wright",
"Stewart",
"Mckenzie",
"Anderson",
"Kennedy",
"Macdonald",
"Jones",
"Scott",
"Burns",
"Jones",
"Williams",
"Davies",
"Evans",
"Thomas",
"Roberts",
"Hughes",
"Lewis",
"Morgan",
"Griffiths",
"Richards",
"Powell",
"Parry",
"John",
"Watkins",
"Howells",
"Pritchard",
"Rogers",
"Matthews",
"Rowlands",
"Smith",
"Jones",
"Williams",
"Taylor",
"Brown",
"Davies",
"Evans",
"Wilson",
"Thomas",
"Johnson",
"Roberts",
"Robinson",
"Thompson",
"Wright",
"Walker",
"White",
"Edwards",
"Hughes",
"Green",
"Hall",
"Edwards",
"Owen",
"James",
"Morris",
"Price",
"Rees",
"Phillips",
"Jenkins",
"Harris",
"Lloyd",
"Humphries",
"Pugh",
"Ellis",
"Bowen",
"Hopkins",
"Martin",
"Bennett",
"Bevan",
"Pearse",
"Adams"
}

if (SERVER) then
    function ENT:CustomInitialize()

        local chosenweapon = table.Random(weapons)
        self:SetCEntWeaponModel(chosenweapon)

        if string.find(chosenweapon, "caster") or string.find(chosenweapon, "gatling") then
            self.IdleAnim = "2hhaim"
            self.AttackAnim = "2hhaim"
            self.RunAnim = "2hhaim_run"
            self.WalkAnim = "2hhaim_walk"
            self.CrouchAnim = "sneak2hraim"
        end

        if string.find(chosenweapon, "melee") then
            self.IdleAnim = "2hmaim"
            self.AttackAnim = "2hmaim"
            self.RunAnim = "2hmaim_run"
            self.WalkAnim = "2hmaim_walk"
            self.CrouchAnim = "sneak2hmaim"
        end

        if string.find(chosenweapon, "launcher") then
            self.IdleAnim = "2hlaim"
            self.AttackAnim = "2hlaim"
            self.RunAnim = "2hlaim_run"
            self.WalkAnim = "2hlaim_walk"
            self.CrouchAnim = "sneak2hlaim"
        end

        self:SetCEntName(self.name .. " " .. table.Random(names))
        self:SetCombatHealthMax(100)
        self:SetCombatHealth(100)
        self:SetAP(10)
        self:SetDT(31)
        self:SetET(25)
        self:SetDR(30)
        self:SetAttackBoost(20)
        self:SetDodgeBoost(15)
       
    end
end