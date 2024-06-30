ITEM.name = "Saturnite Power Fist"
ITEM.description = "A pneumatic power fist with its metal casing replaced by the space-age Saturnite alloy. The material is significantly lighter, allowing for quicker, less cumbersome striking, but is less dense than the solid steel used origonally."
ITEM.model = "models/mosi/fallout4/props/weapons/melee/powerfist.mdl"
ITEM.class = "aus_m_fists_powerfist"
ITEM.weaponCategory = "melee"
ITEM.price = 5000
ITEM.flag = "1"
ITEM.height = 3
ITEM.width = 2
ITEM.category = "Melee"
ITEM.canAttach = false
ITEM.repairCost = ITEM.price/100*1
ITEM.weight = 3
ITEM.modifier = 5
ITEM.isPLWeapon = true
ITEM.Dmg = "1d10+2"
ITEM.Pen = 2
ITEM.Special = "UnBal, Tool"


function ITEM:OnInstanced(invID, x, y)
	if !self:GetData("durability") then
		self:SetData("durability", 10000)
	end
end

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		if (self:GetData("equip")) then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end
	end
end