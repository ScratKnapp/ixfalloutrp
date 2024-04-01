FACTION.name = "Wastelanders"
FACTION.description = "Unaffiliated wasteland denziens."
FACTION.color = Color(244, 164, 96)
FACTION.isDefault = true
FACTION.models = {
	"models/thespireroleplay/humans/group004/female_01.mdl",
	"models/thespireroleplay/humans/group004/female_02.mdl",
	"models/thespireroleplay/humans/group004/female_03.mdl", 
	"models/thespireroleplay/humans/group004/female_04.mdl", 
	"models/thespireroleplay/humans/group004/female_05.mdl", 
	"models/thespireroleplay/humans/group004/female_06.mdl", 
	"models/thespireroleplay/humans/group004/female_07.mdl", 
	"models/thespireroleplay/humans/group004/female_08.mdl", 
	"models/thespireroleplay/humans/group004/female_09.mdl", 
	"models/thespireroleplay/humans/group004/female_10.mdl", 
	"models/thespireroleplay/humans/group004/female_11.mdl", 
	"models/thespireroleplay/humans/group004/female_12.mdl", 
	"models/thespireroleplay/humans/group004/male_01.mdl", 
	"models/thespireroleplay/humans/group004/male_02.mdl", 
	"models/thespireroleplay/humans/group004/male_03.mdl", 
	"models/thespireroleplay/humans/group004/male_04.mdl", 
	"models/thespireroleplay/humans/group004/male_05.mdl", 
	"models/thespireroleplay/humans/group004/male_06.mdl", 
	"models/thespireroleplay/humans/group004/male_07.mdl", 
	"models/thespireroleplay/humans/group004/male_08.mdl", 
	"models/thespireroleplay/humans/group004/male_09.mdl", 
	"models/thespireroleplay/humans/group004/male_10.mdl", 
	"models/thespireroleplay/humans/group004/male_11.mdl", 
	"models/thespireroleplay/humans/group004/male_12.mdl", 
	"models/thespireroleplay/humans/group004/male_13.mdl", 
	"models/thespireroleplay/humans/group004/male_14.mdl", 
	"models/thespireroleplay/humans/group004/male_15.mdl", 
	"models/thespireroleplay/humans/group004/male_16.mdl", 
	"models/thespireroleplay/humans/group004/male_17.mdl", 
	"models/thespireroleplay/humans/group004/male_18.mdl", 
}

FACTION_WASTELAND = FACTION.index


function FACTION:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()
	inventory:Add("paper", 1)

end