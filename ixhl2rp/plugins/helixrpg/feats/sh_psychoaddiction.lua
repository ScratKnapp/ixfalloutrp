FEAT.name = "Psycho Addiction"
FEAT.description = "Muscle weakness, hazy vision.\n-1 END, -1 PER"
FEAT.icon = "fonvui/hud/icons/message/vaultboy_pain.png"
FEAT.noStartSelection = true
FEAT.statDebuffs = {
	["endurance"] = -1,
    ["perception"] = -1,

}
function FEAT:OnSetup(client)

    local character = client:GetCharacter()

    if self.statDebuffs then 
        for k, v in pairs(self.statDebuffs) do
            character:BuffStat("psychoaddiction", k, v)
        end
    end 


end 
