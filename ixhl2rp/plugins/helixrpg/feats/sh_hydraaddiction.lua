FEAT.name = "Hydra Addiction"
FEAT.description = "Severe muscle weakness, increased pain sensitivity\n-3 END"
FEAT.icon = "fonvui/hud/icons/message/vaultboy_pain.png"
FEAT.noStartSelection = true
FEAT.statDebuffs = {
	["endurance"] = -3,

}
function FEAT:OnSetup(client)

    local character = client:GetCharacter()

    if self.statDebuffs then 
        for k, v in pairs(self.statDebuffs) do
            character:BuffStat("jetaddiction", k, v)
        end
    end 


end 
