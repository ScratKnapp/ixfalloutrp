local PLUGIN = PLUGIN

local characterMeta = ix.meta.character

function characterMeta:GetLocationResistance(area, type)
    local client = self:GetPlayer()
    local inventory = self:GetInventory()
    local resistance = 0
  
    for k, v in pairs (inventory:GetItems()) do
      if not v:GetData("equip", false) then continue end -- Ignore equipped items 
      if not v.coverage then continue end  -- Ignore items without armor coverage
      
      
      if hasEntry(v.coverage, area) or hasEntry(v.coverage, "power" .. area) then 
        local itemresist = v:GetTotalResistances()[type]
        client:Notify(itemresist)
        if resistance < itemresist then resistance = itemresist end 
      end 

      -- Power Armor pieces will always override your personally worn gear, even if it's lower
      if hasEntry(v.coverage, "power" .. area) then 
        resistance = v.damResistances[type]
      end 

      

    end

    return resistance
end 

function characterMeta:InPowerArmor()
  local client = self:GetPlayer()
  local inventory = self:GetInventory()

  for k, v in pairs (inventory:GetItems()) do
    if not v:GetData("equip", false) then continue end -- Ignore equipped items 
    if v.powerFrame then return true end 
  end

  return false
end 



ix.command.Add("GetHighestResistance", {
  description = "Get highest resistance for area and damahge type..",
  arguments = {ix.type.character, ix.type.string, ix.type.string},
  OnRun = function(self, client, target, area, type)

    local res = target:GetLocationResistance(area, type)

    client:Notify(target:GetName() .. " has a highest value of " .. res .. " " .. type .. " protection on their " .. area .. ".")
   
  end
})


function hasEntry(array, entry)
  local hasEntry = false

    for k, v in pairs(array) do
      if entry == v then
        hasEntry = true
        break
      end
    end

  return hasEntry
end