local PLUGIN = PLUGIN

local characterMeta = ix.meta.character

function characterMeta:DeductAmmo(type, amt)

  local client = self:GetPlayer()
  local ammotype = "ammo_" .. type
  local founditem = false 



  for k,v in pairs(self:GetInv():GetItemsByUniqueID(ammotype)) do

    local ammoItem = v
    if ammoItem:GetQuantity() < amt then continue end

    ammoItem:SetData("quantity", ammoItem:GetQuantity()- amt)
    if ammoItem:GetData("quantity", 0) <= 0 then ammoItem:Remove() end
    self:SetData("carry", ix.weight.CalculateWeight(self))
    founditem = v.name 
    break 

  end

  return founditem 
end 



ix.command.Add("RandomizeAmmoQuantity", {
  description = "Set quantity of ammo item you're looking at based on the item to match how much would generally be sold or looted from one source.",
  adminOnly = true,
  OnRun = function(self, client)

    local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local stasheditem = ix.item.instances

		for k, v in pairs( stasheditem ) do
			if v:GetEntity() then
			local dist = hitpos:Distance(client:GetPos())
			local distance = v:GetEntity():GetPos():Distance( hitpos )
				if distance <= 32 and v.isAmmo then

					local base = v.foundAmount["Base"]
          local extra = ix.dice.combatDice(v.foundAmount["Extra"]).total

          local total = base + extra

          if v.name == "5mm" or v.name == "electronchargepack" then
            total = (total * 10)  
          end

          v:SetData("quantity", total)
          client:Notify("Set quantity of " .. v.name .. " to " .. total)
				end
			end
		end
   
  end
})

ix.command.Add("DeductAmmo", {
  description = "Manually deduct ammo of given type from player.",
  arguments = {ix.type.character, ix.type.string, ix.type.number},
  adminOnly = true,
  OnRun = function(self, client, target, type, amt)

    local foundammo = target:DeductAmmo(type, amt)
    if foundammo then
      client:Notify("Deducted " .. amt .. " ammo of type " .. foundammo .. " from " .. target:GetName())
    else
      client:Notify("Could not find enough ammo of type " .. type .. " on " .. target:GetName())
    end 

   
  end
})


