FEAT.name = "Buffout Addiction"
FEAT.description = "Muscle weakness and cramping.\n-1 END, -1 STR"
FEAT.icon = "fonvui/hud/icons/message/vaultboy_pain.png"
FEAT.noStartSelection = true
FEAT.statDebuffs = {
	["strength"] = -1,
    ["endurance"] = -1,

}
function FEAT:OnSetup(client)

    local character = client:GetCharacter()

    if self.statDebuffs then 
        for k, v in pairs(self.statDebuffs) do
            character:BuffStat("buffoutaddiction", k, v)
        end
    end 


end 
