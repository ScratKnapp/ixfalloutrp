local PLUGIN = PLUGIN
PLUGIN.name = "Skills"
PLUGIN.author = "Scrat Knapp"
PLUGIN.desc = "Define and upgrade skills."



function PLUGIN:OnCharacterCreated(client, character)
    -- If we don't give skill or attribute points on the char creation screen, we need to initialize them manually
   
    for k, v in pairs(ix.skills.list) do
        character:SetSkill(k, 0)
    end 

    for k, v in pairs(ix.attributes.list) do
        character:SetAttrib(k, 4)
    end


    
end 



ix.command.Add("CharAddSkillpoints", {
    description = "Add skill points to a character.",
    adminOnly = true,
    arguments = {
    ix.type.character, 
    ix.type.number},
    OnRun = function(self, client, target, points)
        local currentpoints = target:GetSkillPoints()
        target:SetSkillPoints(currentpoints + points)
        client:Notify(target:GetName() .. " now has " .. tostring(currentpoints + points .. " skill points."))
    end
})

ix.command.Add("CharSetSkill", {
    description = "Set char's given skill to given level directly.",
    adminOnly = true,
    arguments = {
    ix.type.character, 
    ix.type.string,
    ix.type.number},
    OnRun = function(self, client, target, skill, level)

        if not target:GetSkill(skill) then return "Invalid skill." end

        target:SetSkill(skill, level)
        client:Notify(target:GetName() .. " now has a " ..skill.. " level of " .. target:GetSkill(skill) )
    end
})



