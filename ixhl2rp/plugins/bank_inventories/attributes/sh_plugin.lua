PLUGIN.name = "Attributes"
PLUGIN.author = "Scrat Knapp"
PLUGIN.desc = "SPECIAL stats for a Fallout RP with extra config and commands"

ix.command.Add("CharShowSpecial", {
	description = "List the SPECIAL stats of given player.",
	adminOnly = true,
	arguments = {
		ix.type.character
	},

	OnRun = function(self, client, target)
	
		local str = ""
		str = str.. target:GetName().. " has the following SPECIAL stats:"
        str = str.. "\n Strentgh: " ..target:GetAttribute("strength", 0)
        str = str.. "\n Perception: " ..target:GetAttribute("perception", 0)
        str = str.. "\n Endurance: " ..target:GetAttribute("endurance", 0)
        str = str.. "\n Charisma: " ..target:GetAttribute("charisma", 0)
        str = str.. "\n Intelligence: " ..target:GetAttribute("intelligence", 0)
		str = str.. "\n Agility: " ..target:GetAttribute("agility", 0)
		str = str.. "\n Luck: " ..target:GetAttribute("agility", 0)

		
		return str
	end 
	})
