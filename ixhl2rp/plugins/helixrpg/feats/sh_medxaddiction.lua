FEAT.name = "Med-X Addiction"
FEAT.description = "Cloudy mind, quivering limbs.\n-1 AGi, -1 INT"
FEAT.icon = "fonvui/hud/icons/message/vaultboy_pain.png"
FEAT.noStartSelection = true
FEAT.statDebuffs = {
	["agility"] = -1,
    ["intelligence"] = -1,

}
function FEAT:OnSetup(client)

    local character = client:GetCharacter()

    if self.statDebuffs then 
        for k, v in pairs(self.statDebuffs) do
            character:BuffStat("medxaddiction", k, v)
        end
    end 


end 
