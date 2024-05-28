FEAT.name = "Jet Addiction"
FEAT.description = "Lethargic feeling and irritable.\n-1 AGi, -1 CHR"
FEAT.icon = "fonvui/hud/icons/message/vaultboy_pain.png"
FEAT.noStartSelection = true
FEAT.statDebuffs = {
	["agility"] = -1,
    ["charisma"] = -1,

}
function FEAT:OnSetup(client)

    local character = client:GetCharacter()

    if self.statDebuffs then 
        for k, v in pairs(self.statDebuffs) do
            character:BuffStat("jetaddiction", k, v)
        end
    end 


end 
