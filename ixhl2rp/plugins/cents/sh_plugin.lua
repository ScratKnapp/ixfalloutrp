local FNFF_CE = PLUGIN

FNFF_CE.name = "Combat Entities"
FNFF_CE.description = ""
FNFF_CE.author = ""

FNFF_CE.mainPlugin = FNFF_CE.mainPlugin or {}
FNFF_CE.skillPlugin = FNFF_CE.skillPlugin or {}
FNFF_CE.actions = FNFF_CE.actions or {}

ix.util.Include("cl_observer.lua")
ix.util.Include("sh_centcommands.lua")
ix.util.Include("sh_centchat.lua")
ix.util.Include("sh_centproperties.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sh_centsave.lua")

PLUGIN.savedEnts = PLUGIN.savedEnts or {}

CAMI.RegisterPrivilege({
	Name = "Helix - Manage CEnts",
    MinAccess = "superadmin"
})

function math.ToMeters( num )
    return num * 0.01905
end

function math.ToSU( num )
    return num * 52.49
end



if (CLIENT) then
    function PLUGIN:GetCharacterName(speaker, chatType)
        if speaker.combatEntity then
            return speaker:Name()
        end
    end
end