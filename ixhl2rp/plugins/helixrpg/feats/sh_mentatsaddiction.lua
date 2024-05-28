FEAT.name = "Mentats Addiction"
FEAT.description = "Horrible migraines obstructing thought and focus.\n-1 INT, -1 PER"
FEAT.icon = "fonvui/hud/icons/message/vaultboy_pain.png"
FEAT.noStartSelection = true
FEAT.statDebuffs = {
	["intelligence"] = -1,
    ["perception"] = -1,

}
function FEAT:OnSetup(client)

    local character = client:GetCharacter()

    if self.statDebuffs then 
        for k, v in pairs(self.statDebuffs) do
            character:BuffStat("mentatsaddiction", k, v)
        end
    end 


end 
