ITEM.name = "Psycho"
ITEM.description = "A pre-war attempt at a super soldier serum."
ITEM.longdesc = "A pre-war combat drug meant to make soldiers more effective, it effectively immediately and extremely heightens aggression while dampening fear responses, making them a murderous animal that one cannot possibly reason with until its effects pass.\nAdd 25% of damage roll as extra damage"
ITEM.model = "models/fnv/clutter/health/psychochem01.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_using_psycho_01.mp3"
ITEM.weight = 0.05
ITEM.duration = 8
ITEM.addictionChance = 10

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "injects a dose of "..item.name..".", false)
		item.player:GetCharacter():GetInventory():Add("dirtysyringe", 1)

		curplayer = item.player:GetCharacter()
		item.name = item.name
		duration = item.duration
		curplayer:SetData("usingPsycho", true)
		curplayer:DrugHandler(item.player, "Psycho", item.addictionChance)
		

		timer.Create(item.name, item.duration, 1, function() 
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:SetData("usingPsycho", false)
			curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Psycho")
		end)

		timer.Pause(item.name)
		local drugtable = curplayer:GetData("timertable") or {}
		table.insert(drugtable, item.name)
		curplayer:SetData("timertable", drugtable)


		quantity = quantity - 1
		if (quantity >= 1) then
			item:SetData("quantity", quantity)
			return false
		end

		return true
	end,

	OnCanRun = function(item)
		if (curplayer:GetData("usingPsycho")) then 
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