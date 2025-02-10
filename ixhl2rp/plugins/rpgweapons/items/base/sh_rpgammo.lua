
ITEM.name = 'Stackable Items Base'
ITEM.description = 'Stackable Item'
ITEM.category = 'Stackable'
ITEM.model = 'models/props_c17/TrapPropeller_Lever.mdl'
ITEM.maxStacks = 30
ITEM.isAmmo = true 
ITEM.quantity = 1
ITEM.price = 0
ITEM.weight = 0
ITEM.foundAmount = 
{
	["Base"] = 0,
	["Extra"] = 0
}


if CLIENT then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(
			item:GetData("quantity", 1), 'DermaDefault', w - 5, h - 5,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black
		)
	end
end

ITEM.functions.combine = {
	OnRun = function(firstItem, data)
        local firstItemStacks = firstItem:GetData("quantity", 1)
        local secondItem = ix.item.instances[data[1]]
        local secondItemStacks = secondItem:GetData("quantity", 1)
		local totalStacks = secondItemStacks + firstItemStacks

        if (firstItem.uniqueID ~= secondItem.uniqueID) then return false end
        if (totalStacks > firstItem.maxStacks) then return false end

		firstItem:SetData("quantity", totalStacks, ix.inventory.Get(firstItem.invID):GetReceivers())
		secondItem:Remove()
		

		return false
	end,
	OnCanRun = function(firstItem, data)
		return true
	end
}

ITEM.functions.split = {
	name = "Split",
	icon = "icon16/arrow_divide.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local itemUniqueID = item.uniqueID
		local stacks = item:GetData("quantity", 1)
		client:RequestString('Split', 'Please enter how many items you want to split', function(splitStack)
			if !isnumber(tonumber(splitStack)) then client:Notify('Please enter a `number`') return false end
			local cleanSplitStack = math.Round(math.abs(tonumber(splitStack)))
			if (cleanSplitStack >= stacks) then return false end
			local stackedCount = (stacks - cleanSplitStack)

			if !character:GetInventory():Add(itemUniqueID, 1, {quantity = cleanSplitStack}) then
				ix.item.Spawn(itemUniqueID, client, nil, angle_zero, {quantity = cleanSplitStack})
				
			end

			character:SetData("carry", ix.weight.CalculateWeight(character))
			item:SetData("quantity", stackedCount, ix.inventory.Get(item.invID):GetReceivers())
		end, '1')

		return false
	end,
	OnCanRun = function(item)
		return (item:GetData("quantity", 1) ~= 1)
	end
}

function ITEM:OnInstanced()

end

function ITEM:GetQuantity()
	return self:GetData("quantity", 1)
end 

function ITEM:GetWeight()
	return self.weight * self:GetQuantity()
end 

function ITEM:GetPrice()
	return self.price * self:GetQuantity()
end 