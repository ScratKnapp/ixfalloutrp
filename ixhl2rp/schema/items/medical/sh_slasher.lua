ITEM.name = "Slasher"
ITEM.description = "A modification of the Psycho mixture."
ITEM.longdesc = "With some modifications to the formula, a hit of Psycho can also dull the effects of pain while increasing aggression. Terrifying. \n+25% DR\nAdd 25% of damage roll as extra damage\nDoes not stack with Med-X or Psycho"
ITEM.model = "models/fnv/clutter/health/psychochem01.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_using_psycho_01.mp3"
ITEM.weight = 0.05
ITEM.duration = 5
ITEM.addictionChance = 20

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "injects some "..item.name..".", false)
		item.player:GetCharacter():GetInventory():Add("dirtysyringe", 1)

		curplayer:SetChardrboost(curplayer:GetChardrboost() + 25)
		curplayer:SetData("usingMedX", true)
		curplayer:DrugHandler(item.player, "Psycho", item.addictionChance)

		quantity = quantity - 1
		if (quantity >= 1) then
			item:SetData("quantity", quantity)
			return false
		end

		timer.Create(item.name, item.duration, 1, function() 
			curplayer:SetChardrboost(curplayer:GetChardrboost() - 25)
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:SetData("usingMedX", false)
			curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Psycho")

		end)

		timer.Pause(item.name)
		local drugtable = curplayer:GetData("timertable") or {}
		table.insert(drugtable, item.name)
		curplayer:SetData("timertable", drugtable)

		return true

	end,

	OnCanRun = function(item)
		curplayer = item.player:GetCharacter()
		
		if (curplayer:GetData("usingMedX")) then 
			return false
		else 
			return (!IsValid(item.entity))
		end 
	end
}


function ITEM:GetDescription()
	if (!self.entity or !IsValid(self.entity)) then
		local quant = self:GetData("quantity", self.quantity)
		local str = self.longdesc.."\n \nThere's only "..quant.." uses left."

		return str
	else
		return self.desc
	end
end

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)

		draw.SimpleText(item:GetData("quantity", item.quantity).."/"..item.quantity, "DermaDefault", 3, h - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black)
	end
end