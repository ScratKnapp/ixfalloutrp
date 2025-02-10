ITEM.name = "Nice name"
ITEM.description = "Nice desc"
ITEM.width = 2
ITEM.height = 2
ITEM.isArmor = true
ITEM.isMisc = true
ITEM.price = 1
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.playermodel = nil
ITEM.isBodyArmor = true
ITEM.resistance = true
ITEM.longdesc = "No longer description available."
ITEM.category = "Armor"
ITEM.skincustom = {}
ITEM.outfitCategory = "model"



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
		
        local char = item.player:GetChar()
        if(char:HasFlags("2")) then
            return (!IsValid(item.entity))
        end
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

function ITEM:RemoveOutfit(client)
	local character = client:GetCharacter()
	local bgroups = {}

	self:SetData("equip", false)
	if (character:GetData("oldModel" .. self.outfitCategory)) then
		character:SetModel(character:GetData("oldModel" .. self.outfitCategory))
		character:SetData("oldModel" .. self.outfitCategory, nil)
	end

	if (self.newSkin) then
		if (character:GetData("oldSkin" .. self.outfitCategory)) then
			client:SetSkin(character:GetData("oldSkin" .. self.outfitCategory))
			character:SetData("oldSkin" .. self.outfitCategory, nil)
		else
			client:SetSkin(0)
		end
	end

	for k, _ in pairs(self.bodyGroups or {}) do
		local index = client:FindBodygroupByName(k)

		if (index > -1) then
			client:SetBodygroup(index, 0)

			local groups = character:GetData("groups" .. self.outfitCategory, {})

			if (groups[index]) then
				groups[index] = nil
				character:SetData("groups" .. self.outfitCategory, groups)
			end
		end
	end


	character:SetData("groups", bgroups)

	if (self.attribBoosts) then
		for k, _ in pairs(self.attribBoosts) do
			character:RemoveBuff(self.uniqueID, k)
		end
	end

	if (self.skillBoosts) then
		for k, _ in pairs(self.skillBoosts) do
			character:RemoveSkillBoost(self.uniqueID, k)
		end
	end


	for k, _ in pairs(self:GetData("outfitAttachments", {})) do
		self:RemoveAttachment(k, client)
	end

	self:OnUnequipped()
end

function ITEM:ModelOff(client)
	local character = client:GetCharacter()
	local bgroups = {}
	
	if (character:GetData("oldModel" .. self.outfitCategory)) then
		character:SetModel(character:GetData("oldModel" .. self.outfitCategory))
		character:SetData("oldModel" .. self.outfitCategory, nil)
	end

	if (self.newSkin) then
		if (character:GetData("oldSkin" .. self.outfitCategory)) then
			client:SetSkin(character:GetData("oldSkin" .. self.outfitCategory))
			character:SetData("oldSkin" .. self.outfitCategory, nil)
		else
			client:SetSkin(0)
		end
	end

	for k, _ in pairs(self.bodyGroups or {}) do
		local index = client:FindBodygroupByName(k)

		if (index > -1) then
			client:SetBodygroup(index, 0)

			local groups = character:GetData("groups" .. self.outfitCategory, {})

			if (groups[index]) then
				groups[index] = nil
				character:SetData("groups" .. self.outfitCategory, groups)
			end
		end
	end

	self.player:GetCharacter():SetData("groups", bgroups)

	

	for k, _ in pairs(self:GetData("outfitAttachments", {})) do
		self:RemoveAttachment(k, client)
	end
end

-- makes another outfit depend on this outfit in terms of requiring this item to be equipped in order to equip the attachment
-- also unequips the attachment if this item is dropped
function ITEM:AddAttachment(id)
	local attachments = self:GetData("outfitAttachments", {})
	attachments[id] = true

	self:SetData("outfitAttachments", attachments)
end

function ITEM:RemoveAttachment(id, client)
	local item = ix.item.instances[id]
	local attachments = self:GetData("outfitAttachments", {})

	if (item and attachments[id]) then
		item:OnDetached(client)
	end

	attachments[id] = nil
	self:SetData("outfitAttachments", attachments)
end

function ITEM:OnInstanced()

	if self.armorHP then
		self:SetData("HP", self.armorHP)
		self:SetData("MaxHP", self.armorHP)
	end
	
end

local function skinset(item, data)
	if data then
		item.player:SetSkin(data[1])
		item:SetData("setSkin", data[1])
		if data[2] then
			--item.player:GetCharacter():SetModel(data[2])
			item:SetData("setSkinOverrideModel", data[2])
		else
			--item.player:GetCharacter():SetModel(item.replacements)
			item:SetData("setSkinOverrideModel", nil)
		end
	end
	return false
end

ITEM.functions.ModelOff = { 
	name = "Model Off",
	tip = "useTip",
	icon = "icon16/wrench.png",
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetData("equip")
	end,
	
	OnRun = function(item)
		item:ModelOff(item.player)
		return false
	end,
}

ITEM.functions.zCustomizeSkin = {
	name = "Customize Skin",
	tip = "useTip",
	icon = "icon16/wrench.png",
	isMulti = true,
	multiOptions = function(item, client)
		local targets = {}

		for k, v in pairs(item.skincustom) do
			table.insert(targets, {
				name = v.name,
				data = {v.skingroup, v.modelOverride or nil},
			})
		end

		return targets
	end,
	OnCanRun = function(item)				
		return (!IsValid(item.entity) and #item.skincustom > 0 and item:GetData("equip") == true and item:GetOwner():GetCharacter():GetInventory():HasItem("paint") and item:GetOwner():GetCharacter():GetFlags("T"))
	end,
	OnRun = function(item, data)
		if !data[1] then
			return false
		end

		return skinset(item, data)
	end,
}

ITEM:Hook("drop", function(item)
	local client = item.player
	local character = client:GetCharacter()

	if (item:GetData("equip")) then
		item:RemoveOutfit(item:GetOwner())
	end
end)

function ITEM:RemovePart(client)
	local char = client:GetCharacter()

	self:SetData("equip", false)


	if (self.attribBoosts) then
		for k, _ in pairs(self.attribBoosts) do
			char:RemoveBuff(self.uniqueID, k)
		end
	end

	
	if (self.skillBoosts) then
		for k, _ in pairs(self.skillBoosts) do
			char:RemoveSkillBoost(self.uniqueID, k)
		end
	end
end

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cancel.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
				
		item:RemoveOutfit(item.player)
		
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
			hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/accept.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local items = character:GetInventory():GetItems()

		if item.powerArmor and not character:InPowerArmor() then 
			client:Notify("You need to equip a Power Armor Frame to equip Power Armor.")
			return false
		end


		local coverage = item.coverage 

	
		if item.coverage then 

			for k, v in pairs(items) do


				if not v:GetData("equip") then continue end 
				if not v.coverage then continue end 

				if (v.isClothing and item.isOutfit) or (v.isOutfit and item.isClothing) then
					client:Notify("You can't wear a piece of Clothing and an Outfit at the same time.")
					return false
				end 

				if v.isClothing and item.isClothing then
					client:Notify("You can only wear one clothing article.")
					return false 
				end

				if not v.IsClothing and not item.isClothing and armorSlotsConflict(item.coverage, v.coverage) then
					client:Notify("You already have " .. v:GetName() .. " occupying this slot.")
					return false
				end


			end
		end 

		
		
	
		

		item:SetData("equip", true)

		if (item.attribBoosts) then
			for k, v in pairs(item.attribBoosts) do
				character:BuffStat(item.uniqueID, k, v)
			end
		end

			
		if (item.skillBoosts) then
			for k, v in pairs(item.skillBoosts) do
				character:AddSkillBoost(item.uniqueID, k, v)
			end
		end

		if item.powerFrame then
			local strengthtogive = 11 - character:GetAttribute("strength")
			if strengthtogive > 11 then strengthtogive = 0 end 
			character:AddBoost("powerassist", "strength", strengthtogive)
		end

		

	
		local mods = item:GetData("mod")
		
		if mods then
			for k,v in pairs(mods) do
				local upgitem = ix.item.Get(v[1])
			end
		end
		
	
		item:OnEquipped()
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		local client = self.player
		local character = client:GetCharacter()
		if self.newSkin then
			client:SetSkin( self.newSkin )
		end
		
	
		local mods = self:GetData("mod")
		
		if mods then
			for k,v in pairs(mods) do
				local upgitem = ix.item.Get(v[1])
			end
		end
		
	end
end

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

function ITEM:OnRemoved()
	local inventory = ix.item.inventories[self.invID]
	local owner = inventory.GetOwner and inventory:GetOwner()

	if (IsValid(owner) and owner:IsPlayer()) then
		if (self:GetData("equip")) then
		end
	end
end

function ITEM:OnEquipped()

	local character = self.player:GetCharacter()
	if self.powerFrame then
		local strengthtogive = 11 - character:GetAttribute("strength")
		if strengthtogive > 11 then strengthtogive = 0 end 
		character:AddBoost("powerassist", "strength", strengthtogive)
		character:SetData("carry", ix.weight.CalculateWeight(character))
	end


end

function ITEM:OnUnequipped()
	local character = self.player:GetCharacter()

	if self.powerFrame then
		character:RemoveBoost("powerassist", "strength")
		character:SetData("carry", ix.weight.CalculateWeight(character))
	end
	character:RemoveBoost("powerassist", "strength")
	character:SetData("carry", ix.weight.CalculateWeight(character))
end

ITEM.functions.Inspect = {
	name = "Inspect",
	tip = "Inspect this item",
	icon = "icon16/picture.png",
	OnClick = function(item, test)
		local customData = item:GetData("custom", {})

		local frame = vgui.Create("DFrame")
		frame:SetSize(540, 680)
		frame:SetTitle(item.name)
		frame:MakePopup()
		frame:Center()

		frame.html = frame:Add("DHTML")
		frame.html:Dock(FILL)
		
		local imageCode = [[<img src = "]]..customData.img..[["/>]]
		
		frame.html:SetHTML([[<html><body style="background-color: #000000; color: #282B2D; font-family: 'Book Antiqua', Palatino, 'Palatino Linotype', 'Palatino LT STD', Georgia, serif; font-size 16px; text-align: justify;">]]..imageCode..[[</body></html>]])
	end,
	OnRun = function(item)
		return false
	end,
	OnCanRun = function(item)
		local customData = item:GetData("custom", {})
	
		if(!customData.img) then
			return false
		end
		
		if(item.entity) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/money.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item:GetData("RealPrice") or item.price
		sellprice = math.Round((sellprice*(item:GetData("durability",0)/100))*0.75)
		if item:GetData("durability",0) < 50 then
			client:Notify("Must be Repaired")
			return false
		end
		client:Notify( "Sold for "..(sellprice).." rubles." )
		client:GetCharacter():GiveMoney(sellprice)
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = item:GetData("RealPrice") or item.price
		sellprice = math.Round((sellprice*(item:GetData("durability",0)/100))*0.75)
		if item:GetData("durability",0) < 50 then
			client:Notify("Must be Repaired")
			return false
		end
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}

function ITEM:GetDescription()
	local quant = self:GetData("quantity", 1)
	local str = self.description.."\n\n"..self.longdesc or ""




	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end

	if (customData.longdesc) then
		str = str.. "\n\n" ..customData.longdesc 
	end	



	local totalres = self:GetTotalResistances()

	str = str .. "\n\nPhysical Protection:  " .. totalres["Physical"]
	str = str .. "\nEnergy Protection:  " .. totalres["Energy"]
	str = str .. "\nRadiation Protection: " .. totalres["Radiation"]


	if self.armorHP then
		str = str .. "\n\nArmor HP: " .. self:GetHP() .. "/" .. self:GetMaxHP()
	end
	
	local mods = self:GetData("mod", {})

	if mods then
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

	-- Ignore weight of PA frames and armor pieces if the frame is equipped
	if self.player then 
		local character = self.player:GetCharacter()

		if character:InPowerArmor()then
			
			if self.powerArmor then weight = 0 end
			if self.powerFrame then weight = 0 end
		end 
	end

	return weight


end 

function ITEM:GetTotalResistances()
	local resistances =
	{
		["Physical"] = 0,
		["Energy"] = 0,
		["Radiation"] = 0 
	}

	if self.damResistances then
		for k,v in pairs(self.damResistances) do
			if resistances[k] then
				resistances[k] = resistances[k] + v
			end
		end
	end

	local mods = self:GetData("mod")

	if mods then
		for x,y in pairs(mods) do
			local moditem = ix.item.Get(y[1])
			local modres = moditem.damResistances
			
			if modres then
				for k,v in pairs(modres) do
					if resistances[k] then
						resistances[k] = resistances[k] + v
					end
				end 
			end	
		end
	end

	return resistances


end 

function ITEM:GetHP()
	local basehp = self:GetData("HP")
	return basehp
end

function ITEM:GetMaxHP()
	local basemax = self.armorHP
	local modmax = 0
	
	local mods = self:GetData("mod")

	if mods then
		for x,y in pairs(mods) do
			local moditem = ix.item.Get(y[1])
			local modhp = moditem.armorHP
			if modhp then 
				modmax = modmax + moditem.armorHP
			end 
		end
	end

	return basemax + modmax


end


ITEM.functions.Clone = {
	name = "Clone",
	tip = "Clone this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local client = item.player	
	
		client:requestQuery("Are you sure you want to clone this item?", "Clone", function(text)
			if text then
				local inventory = client:GetCharacter():GetInventory()
				
				if(!inventory:Add(item.uniqueID, 1, item.data)) then
					client:Notify("Inventory is full")
				end
			end
		end)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}

ITEM.functions.Custom = {
	name = "Customize",
	tip = "Customize this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)		
		ix.plugin.list["customization"]:startCustom(item.player, item)
		
		return false
	end,
	
	OnCanRun = function(item)
		local client = item.player
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}

function armorSlotsConflict(array1, array2)
    local elements = {}
    for _, value in ipairs(array1) do
        elements[value] = true
    end
    for _, value in ipairs(array2) do
        if elements[value] then
            return true
        end
    end
    return false
end 

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