PLUGIN.name = 'Initiative'
PLUGIN.author = 'Scrat Knapp'
PLUGIN.description = "Adds stats and commands for manging player health, armor, and AP tabletop style."

ix.util.AddNetworkString("Party1")


ix.command.Add("PartyInsert", {
    description = "Add stacks of bleed to given player.",
    adminOnly = true,
    OnRun = function(self, client)
      
        local party = ix.util.GetNetworkVar("Party1") or []

        table.insert(party, client:GetCharacter():GetName())

        ix.util.SetNetworkVar("Party1", party)
    end
})

ix.command.Add("PartyGet", {
    description = "Add stacks of bleed to given player.",
    adminOnly = true,
    OnRun = function(self, client)
      
        local party = ix.util.GetNetworkVar("Party1")

        if not party then 
            return "Party empty"
        else 
            return party[1]
        end 


     
    end
})