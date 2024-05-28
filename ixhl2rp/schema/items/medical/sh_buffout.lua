ITEM.name = "Buffout"
ITEM.description = "A bottle of steroids."
ITEM.longdesc = "A pre war steroid often used by athletes to enhance their physical performance. Abuse tends to result in heart problems."
ITEM.model = "models/mosi/fnv/props/health/chems/buffout.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_eating_mentats.mp3"
ITEM.weight = 0.05
ITEM.duration = 5
ITEM.addictionChance = 10

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "takes some "..item.name..".", false)

		item.player:NewVegasNotify("You feel ready to take on the world! +3 END, +2 STR, +25 Max HP", "messageNeutral", 8)

		curplayer = item.player:GetCharacter()
		item.name = item.name
		duration = item.duration
		curplayer:BuffStat("buffout", "strength", 2)
		curplayer:BuffStat("buffout", "endurance", 2)
		curplayer:SetCharmaxhpboost(curplayer:GetCharmaxhpboost() + 25)
		curplayer:SetData("usingBuffout", true)
		curplayer:DrugHandler(item.player, "Buffout", item.addictionChance)


		timer.Create(item.name, item.duration, 1, function()  
			curplayer:RemoveBuff("buffout", "strength")
			curplayer:RemoveBuff("buffout", "endurance")
			curplayer:SetCharmaxhpboost(curplayer:GetCharmaxhpboost() - 25)
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:SetData("usingBuffout", false)
			curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Buffout")
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
		curplayer = item.player:GetCharacter()
		
		if (curplayer:GetData("usingBuffout")) then 
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