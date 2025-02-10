ITEM.base = "base_weapons"
ITEM.name = "Weapon Base"
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.description = "A weapon base"
ITEM.longdesc = "None"
ITEM.category = "weapons"
ITEM.rpgWeapon = true 
ITEM.weight = 1
ITEM.price = 0

function ITEM:GetName()
	local name = self.name

	local mods = self:GetData("mod", {})

	if mods then
		for _,v in pairs(mods) do
			local moditem = ix.item.Get(v[1])
			if moditem.prefix then
				name = moditem.prefix .. " " .. name
			end
		end
	end

	
	
	local customData = self:GetData("custom", {})
	if(customData.name) then
		name = customData.name
	end
	
	return name
end

function ITEM:GetDescription()

	local mods = self:GetData("mod", {})
    local str = ""
    str = str .. self.description
    str = str .. "\n\n" .. self.longdesc

	if self.ammo then
		str = str .. "\n\nUses " .. ix.item.Get("ammo_" .. self.ammo).name
	end


	str = str .. "\n\nStats:"

	local stats = self:GetStats()

	stats["Range"] = rangeNumberToText(stats["Range"])



	for k, v in pairs(stats) do

		-- Don't print 'ammo per shot' unless it's more than 1, as that's assumed by default
		if k == "Ammo Per Shot" and v < 2 then continue end 
		
		str = str .. "\n" .. k .. ": " .. v

	end

	local qualities = self:GetQualities()

	if #qualities > 0 then
		str = str .. "\n\nQualities:"
		for k,v in pairs(qualities) do
			str = str .. "\n • " .. v
		end
	end

	local effects = self:GetEffects()

	if #effects > 0 then
		str = str .. "\n\nEffects:"
		for k,v in pairs(effects) do
			str = str .. "\n • " .. v
		end
	end


	


    local mods = self:GetData("mod", {})

	if #mods > 0 then
		str = str .. "\n\nModifications:"
		for _,v in pairs(mods) do
			local moditem = ix.item.Get(v[1])
			str = str .. "\n" .. moditem.name
		end
	end


	if (self.entity) then
		return (self.description)
	else
        return (str)
	end
end


ITEM:Hook("drop", function(item)
	if (item:GetData("equip")) then
		item.player.armor[item.armorclass] = nil
		local character = item.player:GetChar()
		item:SetData("equip", nil)
	
		item.player:SetNetVar(item.armorclass, nil)
		if (item.armorclass != "helmet") then
			item.player:SetModel(item.player:GetChar():GetModel())
		end
	end
end)

ITEM.functions.RemoveUpgrade = {
	name = "Remove Upgrade",
	tip = "Remove",
	icon = "icon16/wrench.png",
    isMulti = true,
    multiOptions = function(item, client)
	
	local targets = {}

	for k, v in pairs(item:GetData("mod", {})) do
		local attTable = ix.item.list[v[1]]
		local niceName = attTable:GetName()
		table.insert(targets, {
			name = niceName,
			data = {k},
		})
    end
    return targets
end,
	OnCanRun = function(item)
		if (table.Count(item:GetData("mod", {})) <= 0) then
			return false
		end
	    
		if item:GetData("equip") then
			return false
		end

        return (!IsValid(item.entity))
		
	end,
	OnRun = function(item, data)
		local client = item.player
		
		if (data) then
			local char = client:GetChar()

			if (char) then
				local inv = char:GetInv()

				if (inv) then
					local mods = item:GetData("mod", {})
					local attData = mods[data[1]]

					if (attData) then
						inv:Add(attData[1])
						mods[data[1]] = nil
                        
                        curPrice = item:GetData("RealPrice")
                	    if !curPrice then
                		    curPrice = item.price
                		end
                		
						local targetitem = ix.item.list[attData[1]]
						
                        item:SetData("RealPrice", (curPrice - targetitem.price))
                        
						if (table.Count(mods) == 0) then
							item:SetData("mod", nil)
						else
							item:SetData("mod", mods)
						end

						-- If HP is greater than max because we removed an upgrade that increased the max, set it to the new max.
						if item.armorHP then 
							if item:GetHP() > item:GetMaxHP() then
								item:SetData("HP", item:GetMaxHP())
							end
						end 
						
						char:SetData("carry", ix.weight.CalculateWeight(char))
						
						client:EmitSound("cw/holster4.wav")
					else
						client:NotifyLocalized("notAttachment")
					end
				end
			end
		else
			client:NotifyLocalized("detTarget")
		end
	return false
end,
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	OnRun = function(item)
		item:Equip(item.player)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		if item.skill == "explosives" then return false end 
		
		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false
	end
}

function ITEM:GetQualities()

    local qualities = {}

	if self.qualities then 
		for k,v in pairs(self.qualities) do qualities[k] = v end
	end 

    local mods = self:GetData("mod", {})

	if mods then
		for _,v in pairs(mods) do
			local moditem = ix.item.Get(v[1])
			if moditem.qualities then
				for x,y in pairs(moditem.qualities) do table.insert(qualities, y) end
			end 

			-- If an attachment is meant to merely remove a quality, do it. IE: Removes 'inaccurate', but doesn't make it accurate

			if moditem.removequalities then
				for k, v in pairs(moditem.removequalities) do 
					if table.HasValue(qualities, v) then 
						table.RemoveByValue(qualities, v) 
					end 
				end
			end 
			
		end
	end

	-- Incompatible qualities that will just cancel each other out

	if table.HasValue(qualities, "Inaccurate") and table.HasValue(qualities, "Accurate") then
		table.RemoveByValue(qualities, "Inaccurate")
		table.RemoveByValue(qualities, "Accurate")
	end

	
	if table.HasValue(qualities, "Unreliable") and table.HasValue(qualities, "Reliable") then
		table.RemoveByValue(qualities, "Unreliable")
		table.RemoveByValue(qualities, "Reliable")
	end

	return qualities
end 

function ITEM:GetEffects()

    local effects = {}

	if self.effects then 
		for k,v in pairs(self.effects) do effects[k] = v end
	end 

    local mods = self:GetData("mod", {})

	if mods then
		for _,v in pairs(mods) do
			local moditem = ix.item.Get(v[1])
			if moditem.effects then
				for x,y in pairs(moditem.effects) do table.insert(effects, y) end
			end 

			-- If an attachment is meant to merely remove an effect, do it. 

			if moditem.removeeffects then
				for k, v in pairs(moditem.removeeffects) do 
					if table.HasValue(effects, v) then 
						table.RemoveByValue(effects, v) 
					end 
				end
			end 
			
		end
	end

	return effects
end 

function ITEM:GetStats()

    local stats = {
		["Damage"] = 0,
		["Range"] = 0,
		["Rate Of Fire"] = 0,
		["Ammo Per Shot"] = 0,
	
	}

	if self.stats then
		for k,v in pairs(self.stats) do
			if stats[k] then
				stats[k] = stats[k] + v
			end
		end
	end


	local mods = self:GetData("mod")

	if mods then
		for x,y in pairs(mods) do
			local moditem = ix.item.Get(y[1])
			local modstats = moditem.stats
			
			if modstats then
				for k,v in pairs(modstats) do
					if stats[k] then
						stats[k] = stats[k] + v
					end
				end 
			end	
		end
	end

	return stats

	
		


	





end 

function ITEM:GetWeight()
	local weight = self.weight
	local mods = self:GetData("mod", {})

	if mods then
		for _,v in pairs(mods) do
			local moditem = ix.item.Get(v[1])
			if moditem.weight then 
				weight = weight + moditem.weight
			end 
		end
	end

	return weight


end 

function rangeNumberToText(range)

	if range < 0 then range = 0 end
	if range > 4 then range = 4 end 


	local rangeTable = {
		[0] = "Reach",
		[1] = "Close",
		[2] = "Medium",
		[3] = "Long",
		[4] = "Extreme"
	}

	return rangeTable[range]



end 

function ITEM:Equip(client, bNoSelect, bNoSound)
	local items = client:GetCharacter():GetInventory():GetItems()

	client.carryWeapons = client.carryWeapons or {}

	for _, v in pairs(items) do
		if (v.id != self.id) then
			local itemTable = ix.item.instances[v.id]

			if (!itemTable) then
				client:NotifyLocalized("tellAdmin", "wid!xt")

				return false
			else
				if (itemTable.isWeapon and client.carryWeapons[self.weaponCategory] and itemTable:GetData("equip")) then
					client:NotifyLocalized("weaponSlotFilled", self.weaponCategory)

					return false
				end
			end
		end
	end

	if (client:HasWeapon(self.class)) then
		client:StripWeapon(self.class)
	end

	local weapon = client:Give(self.class, !self.isGrenade)

	if (IsValid(weapon)) then
		local ammoType = weapon:GetPrimaryAmmoType()

		client.carryWeapons[self.weaponCategory] = weapon

		if (!bNoSelect) then
			client:SelectWeapon(weapon:GetClass())
		end

		if (!bNoSound) then
			client:EmitSound(self.useSound, 80)
		end

		-- Remove default given ammo.
		if (client:GetAmmoCount(ammoType) == weapon:Clip1() and self:GetData("ammo", 0) == 0) then
			client:RemoveAmmo(weapon:Clip1(), ammoType)
		end

		-- assume that a weapon with -1 clip1 and clip2 would be a throwable (i.e hl2 grenade)
		-- TODO: figure out if this interferes with any other weapons
		if (weapon:GetMaxClip1() == -1 and weapon:GetMaxClip2() == -1 and client:GetAmmoCount(ammoType) == 0) then
			client:SetAmmo(1, ammoType)
		end

		self:SetData("equip", true)

		if (self.isGrenade) then
			weapon:SetClip1(1)
			client:SetAmmo(0, ammoType)
		else
			client:SetAmmo(99, ammoType)
			weapon:SetClip1(0)
		end

		weapon.ixItem = self

		if (self.OnEquipWeapon) then
			self:OnEquipWeapon(client, weapon)
		end
	else
		print(Format("[Helix] Cannot equip weapon - %s does not exist!", self.class))
	end
end


if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end

	function ITEM:PopulateTooltip(tooltip)
		if (self:GetData("equip")) then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end
	end
end

