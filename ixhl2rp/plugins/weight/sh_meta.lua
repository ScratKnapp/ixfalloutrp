-- ITEM META START --
local ITEM = ix.meta.item or {}

function ITEM:GetWeight()
	return self:GetData("weight", nil) or self.weight or nil
end

ix.meta.item = ITEM
-- ITEM META END --

-- CHARACTER META START --
local CHAR = ix.meta.character or {}

function CHAR:GetMaxCarry()
	local base = 150
	local strbonus = (self:GetAttribute("strength") * 10)
	local inventory = self:GetInventory()
	local itembonus = 0

	for k, v in pairs (inventory:GetItems()) do
		if(!v:GetData("equip", false)) then continue end --ignores unequipped items

		if v.weightBonus then 

			if v.isBag then 
				itembonus = itembonus + (v.weightBonus * self:GetAttribute("strength"))
			else 
				itembonus = itembonus + v.weightBonus
			end 
			
		end 

		
		local mods = v:GetData("mod", {})

		if mods then
			for _,v in pairs(mods) do
				local moditem = ix.item.Get(v[1])
				if moditem.weightBonus then
					itembonus = itembonus .. " " .. moditem.weightBonus
				end
			end
		end

		
	end

	return base + strbonus + itembonus

end 

function CHAR:Overweight()
	local carry = self:GetData("carry", 0)
	local maxcarry = self:GetMaxCarry()

	if carry >= (maxcarry * 2) then
		-- Carrying 2x as much stuff as you're able. Can't move, fail all STR and AGI tests, Initiative 0
		return 3
	elseif carry > (maxcarry + 50) then
		-- Carrying 50 pounds over max. +2 difficulty to STR and Agility checks, -2 to Initative
		return 2
	elseif carry > maxcarry then 
		-- Carrying over max, but less than 50 over. +1 difficulty to STR and Agility checks, -1 to Initiative
		return 1
	else
		-- Not carrying over max. All good!
		return 0
	end 
	
	
end

function CHAR:CanCarry(item)
	local itemweight = item:GetWeight()
	local currentcarry = self:GetData("carry", 0)
	local maxcarry = self:GetMaxCarry() * 2

	if currentcarry + itemweight > maxcarry then
		return false
	else
		return true
	end 
end

function CHAR:AddCarry(item)
	self:SetData("carry", math.max(self:GetData("carry", 0) + item:GetWeight(), 0))
end

function CHAR:RemoveCarry(item)
	self:SetData("carry", math.max(self:GetData("carry", 0) - item:GetWeight(), 0))
end

function CHAR:DropWeight(weight)
	self:SetData("carry", math.max(self:GetData("carry", 0) - weight, 0))
end

ix.meta.char = CHAR
-- CHARACTER META END --
